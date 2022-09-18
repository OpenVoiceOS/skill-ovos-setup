# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import time
from threading import Lock
from time import sleep
from uuid import uuid4

from adapt.intent import IntentBuilder
from mycroft.api import DeviceApi, is_paired, check_remote_pairing
from mycroft.configuration import LocalConf, USER_CONFIG
from mycroft.identity import IdentityManager
from mycroft.messagebus.message import Message
from mycroft.skills.core import intent_handler
from ovos_workshop.skills import OVOSSkill
from ovos_workshop.decorators import killable_event
from selene_api.pairing import PairingManager
from ovos_utils.network_utils import is_connected
from ovos_utils.gui import can_use_gui, can_use_local_gui
from ovos_utils.log import LOG
from enum import Enum


class SetupState(str, Enum):
    FIRST_BOOT = "first"
    LOADING = "loading"
    INACTIVE = "inactive"
    SELECTING_WIFI = "wifi"
    SELECTING_BACKEND = "backend"
    SELECTING_STT = "stt"
    SELECTING_TTS = "tts"
    PAIRING = "pairing"


class PairingMode(str, Enum):
    VOICE = "voice"  # voice only
    GUI = "gui"  # gui - click buttons
    HYBRID = "hybrid"  # gui but no input capabilities - select with voice


class BackendType(str, Enum):
    OFFLINE = "offline"
    PERSONAL = "personal"
    SELENE = "selene"


class SetupManager:
    """ helper class to perform setup actions"""
    def __init__(self, bus):
        self.bus = bus
        self.config_lock = Lock()

    # config handling
    def update_user_config(self, config):
        with self.config_lock:
            conf = LocalConf(USER_CONFIG)
            conf.merge(config)
            conf.store()
            self.bus.emit(Message("configuration.patch",
                                  {"config": conf}))

    def change_to_mimic(self):
        self.update_user_config({
            "tts": {
                "module": "ovos-tts-plugin-mimic",
                "ovos-tts-plugin-mimic": {"voice": "ap"}
            }
        })

    def change_to_mimic2(self):
        self.update_user_config({
            "tts": {
                "module": "ovos-tts-plugin-mimic2",
                "ovos-tts-plugin-mimic2": {"voice": "kusal"}
            }
        })

    def change_to_larynx(self):
        self.update_user_config({
            "tts": {
                "module": "neon-tts-plugin-larynx-server",
                "neon-tts-plugin-larynx-server": {
                    "host": "http://tts.neon.ai",
                    "voice": "mary_ann",
                    "vocoder": "hifi_gan/vctk_small"
                }
            }
        })

    def change_to_pico(self):
        self.update_user_config({
            "tts": {
                "module": "ovos-tts-plugin-pico",
                "ovos-tts-plugin-pico": {}
            }
        })

    def change_to_chromium(self):
        self.update_user_config({
            "stt": {
                "module": "ovos-stt-plugin-server",
                "fallback_module": "ovos-stt-plugin-vosk",
                # vosk model path not set, small model for lang auto downloaded to XDG directory
                # en-us already bundled in OVOS image
                "ovos-stt-plugin-vosk": {},
                "ovos-stt-plugin-server": {
                    "url": "https://stt.openvoiceos.com/stt"
                }
            }
        })

    def change_to_vosk(self):
        self.update_user_config({
            "stt": {
                "module": "ovos-stt-plugin-vosk-streaming",
                "fallback_module": "",  # disable fallback STT to avoid loading vosk twice
                # vosk model path not set, small model for lang auto downloaded to XDG directory
                # en-us already bundled in OVOS image
                "ovos-stt-plugin-vosk": {},
                "ovos-stt-plugin-vosk-streaming": {}
            }
        })

    def change_to_selene(self):
        config = {
            "stt": {"module": "ovos-stt-plugin-selene"},
            "server": {
                "url": "https://api.mycroft.ai",
                "version": "v1",
                "disabled": False
            },
            "listener": {
                "wake_word_upload": {
                    "url": "https://training.mycroft.ai/precise/upload"
                }
            }
        }
        self.update_user_config(config)

    def change_to_local_backend(self, url="http://0.0.0.0:6712"):
        config = {
            "stt": {"module": "ovos-stt-plugin-selene"},
            "server": {
                "url": url,
                "version": "v1",
                "disabled": False
            },
            "listener": {
                "wake_word_upload": {
                    "url": f"{url}/precise/upload"
                }
            }
        }
        self.update_user_config(config)
        self.create_dummy_identity()

    def change_to_no_backend(self):
        config = {
            "server": {
                "disabled": True
            }
        }
        self.update_user_config(config)
        self.create_dummy_identity()

    # backend actions
    @staticmethod
    def create_dummy_identity():
        # create pairing file with dummy data
        login = {"uuid": uuid4(),
                 "access": "OVOSdbF1wJ4jA5lN6x6qmVk_QvJPqBQZTUJQm7fYzkDyY_Y=",
                 "refresh": "OVOS66c5SpAiSpXbpHlq9HNGl1vsw_srX49t5tCv88JkhuE=",
                 "expires_at": time.time() + 999999}
        IdentityManager.save(login)

    @staticmethod
    def update_device_attributes_on_backend():
        """Communicate version information to the backend.

        The backend tracks core version, enclosure version, platform build
        and platform name for each device, if it is known.
        """
        LOG.info('Sending updated device attributes to the backend...')
        try:
            api = DeviceApi()
            api.update_version()
        except Exception:
            pass


class PairingSkill(OVOSSkill):

    def __init__(self):
        super(PairingSkill, self).__init__("PairingSkill")
        self.reload_skill = False
        self.nato_dict = None
        self.setup = None
        self.pairing = None
        self.mycroft_ready = False
        self.state = SetupState.LOADING
        self.pairing_mode = PairingMode.VOICE

    # startup
    def initialize(self):
        self.setup = SetupManager(self.bus)
        self.pairing = PairingManager(self.bus, self.enclosure,
                                      code_callback=self.on_pairing_code,
                                      success_callback=self.on_pairing_success,
                                      end_callback=self.on_pairing_end,
                                      start_callback=self.on_pairing_start,
                                      restart_callback=self.handle_pairing,
                                      error_callback=self.on_pairing_error)

        self.add_event("mycroft.not.paired", self.not_paired)
        self.add_event("ovos.setup.state", self.handle_get_setup_state)

        # events for GUI interaction
        self.gui.register_handler("mycroft.device.set.backend", self.handle_backend_selected_event)
        self.gui.register_handler("mycroft.device.confirm.backend", self.handle_backend_confirmation_event)
        self.gui.register_handler("mycroft.device.local.setup.host.address", self.handle_personal_backend_url)
        self.gui.register_handler("mycroft.return.select.backend", self.handle_return_event)
        self.gui.register_handler("mycroft.device.confirm.stt", self.handle_stt_selected)
        self.gui.register_handler("mycroft.device.confirm.tts", self.handle_tts_selected)
        self.nato_dict = self.translate_namedvalues('codes')

        if not can_use_gui(self.bus):
            # ask for options in a loop
            self.pairing_mode = PairingMode.VOICE
        # TODO - add keynav support to GUI, allow using a keyboard for all steps
        # this removes the need for Hybrid mode and makes the skill simpler
        # elif can_use_local_gui() and can_use_touch_mouse():
        #    # display gui + skip the annoying voice prompts loop
        #    self.pairing_mode = PairingMode.GUI
        else:
            # display gui + ask for options in a loop
            self.pairing_mode = PairingMode.GUI

        # uncomment this line for debugging
        # will always trigger setup on boot
        self.selected_backend = None

        if not is_connected():
            self.state = SetupState.SELECTING_WIFI
            # trigger pairing after wifi
            self.bus.once("ovos.wifi.setup.completed",
                          self.handle_wifi_finish)
            self.bus.once("ovos.phal.wifi.plugin.skip.setup",
                          self.handle_wifi_skip)
        elif not self.selected_backend:
            self.state = SetupState.FIRST_BOOT
            self.make_active()  # to enable converse
            self.bus.emit(Message("mycroft.not.paired"))
        elif not is_paired():
            # trigger pairing
            self.state = SetupState.SELECTING_BACKEND
            self.bus.emit(Message("mycroft.not.paired"))
        else:
            self.state = SetupState.INACTIVE
            self.handle_display_manager("LoadingSkills")
            self.setup.update_device_attributes_on_backend()

    @property
    def backend_type(self):
        url = self.settings.get("pairing_url", "").split("://")[-1]
        if not url:
            return BackendType.OFFLINE
        if url == "home.mycroft.ai":
            return BackendType.SELENE
        return BackendType.PERSONAL

    @property
    def selected_backend(self):
        return self.settings.get("selected_backend")

    @selected_backend.setter
    def selected_backend(self, value):
        self.settings["selected_backend"] = value
        self.settings.store()

    @property
    def selected_stt(self):
        return self.settings.get("selected_stt")

    @selected_stt.setter
    def selected_stt(self, value):
        self.settings["selected_stt"] = value
        self.settings.store()

    @property
    def selected_tts(self):
        return self.settings.get("selected_tts")

    @selected_tts.setter
    def selected_tts(self, value):
        self.settings["selected_tts"] = value
        self.settings.store()

    def handle_get_setup_state(self, message):
        self.bus.emit(message.response({"state": self.state}))

    def handle_wifi_finish(self, message):
        self.handle_display_manager("LoadingScreen")
        if not is_paired() or not self.selected_backend:
            self.state = SetupState.SELECTING_BACKEND
            self.bus.emit(message.forward("mycroft.not.paired"))
        else:
            self.state = SetupState.INACTIVE

    def handle_wifi_skip(self, message):
        LOG.info("Offline mode selected, setup will resume on restart")
        self.handle_display_manager("OfflineMode")
        self.state = SetupState.INACTIVE

    def send_stop_signal(self, stop_event=None):
        # TODO move this one into default OVOSkill class
        # stop the previous event execution
        if stop_event:
            self.bus.emit(Message(stop_event))

        # STT might continue recording and screw up the next get_response
        self.bus.emit(Message('recognizer_loop:record_stop'))
        # stop TTS
        self.bus.emit(Message("mycroft.audio.speech.stop"))

        # special non-ovos handling
        try:
            from mycroft.version import OVOS_VERSION_STR
        except ImportError:
            # NOTE: mycroft does not have an event to stop recording
            # this attempts to force a stop
            self.bus.emit(Message('mycroft.mic.mute'))
            sleep(1.5)  # the silence from muting should make STT stop recording
            self.bus.emit(Message('mycroft.mic.unmute'))

    def handle_intent_aborted(self):
        LOG.info("killing all dialogs")

    def not_paired(self, message):
        self.make_active()  # to enable converse
        # If the device isn't paired catch mycroft.ready to release gui
        self.bus.once("mycroft.ready", self.handle_mycroft_ready)
        if not message.data.get('quiet', True):
            self.speak_dialog("pairing.not.paired")
        self.handle_pairing()

    def handle_mycroft_ready(self, message):
        """Catch info that skills are loaded and ready."""
        self.mycroft_ready = True
        # clear gui, either the pairing page or the initial loading page
        self.gui.remove_page("ProcessLoader.qml")
        self.bus.emit(Message("mycroft.gui.screen.close",
                              {"skill_id": self.skill_id}))
        self.state = SetupState.INACTIVE

    # voice events
    def converse(self, message):
        if self.state != SetupState.INACTIVE or \
                self.state != SetupState.FIRST_BOOT:
            # capture all utterances until paired
            # prompts from this skill are handled with get_response
            return True
        return False

    @intent_handler(IntentBuilder("PairingIntent")
                    .require("PairingKeyword").require("DeviceKeyword"))
    def handle_pairing(self, message=None):
        self.state = SetupState.SELECTING_BACKEND

        if self.selected_backend and check_remote_pairing(ignore_errors=True):
            # Already paired!
            if message:  # intent
                self.speak_dialog("already.paired")
            self.state = SetupState.INACTIVE
            self.show_pairing_success()
        elif not self.pairing.data:
            self.handle_backend_menu()

    # pairing callbacks
    def on_pairing_start(self):
        self.state = SetupState.PAIRING
        self.show_pairing_start()

        if self.backend_type == BackendType.SELENE:
            self.speak_dialog("pairing.intro")

    def on_pairing_code(self, code):
        data = {"code": '. '.join(map(self.nato_dict.get, code)) + '.'}
        self.show_pairing(code)
        self.speak_dialog("pairing.code", data)

    def on_pairing_success(self):
        self.show_pairing_success()

        if self.mycroft_ready:
            # Tell user they are now paired
            self.speak_dialog("pairing.paired", wait=True)

        # allow gui page to linger around a bit
        sleep(5)
        self.handle_display_manager("LoadingSkills")
        self.setup.update_device_attributes_on_backend()
        self.state = SetupState.INACTIVE

    def on_pairing_error(self, quiet):
        if not quiet:
            self.speak_dialog("unexpected.error.restarting")
        self.show_pairing_fail()

    def on_pairing_end(self, error_dialog):
        if error_dialog:
            self.speak_dialog(error_dialog)
        self.state = SetupState.INACTIVE

    # Pairing GUI events
    #### Backend selection menu
    @killable_event(msg="pairing.backend.menu.stop")
    def handle_backend_menu(self):
        self.state = SetupState.SELECTING_BACKEND
        self.send_stop_signal("pairing.confirmation.stop")
        self.handle_display_manager("BackendSelect")
        self.speak_dialog("backend_intro")
        if self.pairing_mode != PairingMode.VOICE:
            self.speak_dialog("select_option_gui")

        if self.pairing_mode != PairingMode.GUI:
            self.speak_dialog("select_backend", wait=True)
            self.speak_dialog("backend", wait=True)
            self._backend_menu_voice()

    def _backend_menu_voice(self, wait=0):
        sleep(int(wait))
        answer = self.get_response("choose_backend", num_retries=0)
        if answer:
            LOG.info("ANSWER: " + answer)
            if self.voc_match(answer, "no_backend") or self.voc_match(answer, "local_backend"):
                self.bus.emit(Message(f"{self.skill_id}.mycroft.device.set.backend",
                                      {"backend": BackendType.OFFLINE}))
                return
            elif self.voc_match(answer, "selene"):
                self.bus.emit(Message(f"{self.skill_id}.mycroft.device.set.backend",
                                      {"backend": BackendType.SELENE}))
                return
            else:
                self.speak_dialog("no_understand_backend", wait=True)

        sleep(1)  # time for abort to kick in
        # (answer will be None and return before this is killed)
        self._backend_menu_voice(wait=3)

    def handle_backend_selected_event(self, message):
        self.send_stop_signal("pairing.backend.menu.stop")
        self.handle_backend_confirmation(message.data["backend"])

    def handle_return_event(self, message):
        self.send_stop_signal("pairing.confirmation.stop")
        page = message.data.get("page", "")
        self.handle_backend_menu()

    ### Backend confirmation
    @killable_event(msg="pairing.confirmation.stop",
                    callback=handle_intent_aborted)
    def handle_backend_confirmation(self, selection):
        if selection == BackendType.SELENE:
            self.speak_dialog("selene_intro")
        elif selection == BackendType.PERSONAL:
            self.speak_dialog("local_backend_intro")
        elif selection == BackendType.OFFLINE:
            self.speak_dialog("no_backend_intro")

        if self.pairing_mode != PairingMode.VOICE:
            if selection == BackendType.SELENE:
                self.handle_display_manager("BackendMycroft")
                self.speak_dialog("selene_confirm_gui")
            elif selection == BackendType.PERSONAL:
                self.handle_display_manager("BackendLocal")
                self.speak_dialog("local_backend_confirm_gui")
            elif selection == BackendType.OFFLINE:
                self.handle_display_manager("NoBackend")
                self.speak_dialog("no_backend_confirm_gui")
        if self.pairing_mode != PairingMode.GUI:
            self._backend_confirmation_voice(selection)

    def _backend_confirmation_voice(self, selection):
        if selection == BackendType.SELENE:
            self.speak_dialog("selected_mycroft_backend", wait=True)
            # NOTE response might be None
            answer = self.ask_yesno("confirm_backend",
                                    {"backend": "mycroft"})
            if answer == "yes":
                self.bus.emit(Message(f"{self.skill_id}.mycroft.device.confirm.backend",
                                      {"backend": BackendType.SELENE}))
                return
            elif answer == "no":
                self.bus.emit(Message(f"{self.skill_id}.mycroft.return.select.backend",
                                      {"page": BackendType.PERSONAL}))
                return
        else:
            self.speak_dialog("selected_no_backend", wait=True)
            # NOTE response might be None
            answer = self.ask_yesno("confirm_backend",
                                    {"backend": "offline"})
            if answer == "yes":
                self.bus.emit(Message(f"{self.skill_id}.mycroft.device.confirm.backend",
                                      {"backend": BackendType.OFFLINE}))
                return
            if answer == "no":
                self.bus.emit(Message(f"{self.skill_id}.mycroft.return.select.backend",
                                      {"page": BackendType.OFFLINE}))
                return
        sleep(3)  # time for abort to kick in
        # (answer will be None and return before this is killed)
        self._backend_confirmation_voice(selection)

    def handle_backend_confirmation_event(self, message):
        self.send_stop_signal("pairing.confirmation.stop")
        if message.data["backend"] == BackendType.PERSONAL:
            self.handle_local_backend_selected(message)
        elif message.data["backend"] == BackendType.SELENE:
            self.handle_selene_selected(message)
        else:
            self.handle_no_backend_selected(message)

    def handle_selene_selected(self, message):
        self.pairing.pairing_url = self.settings["pairing_url"] = "home.mycroft.ai"  # scroll in mk1 faceplate
        self.pairing.set_api_url("api.mycroft.ai")
        # selene selected
        self.setup.change_to_selene()
        # continue to normal pairing process
        self.state = SetupState.PAIRING
        self.selected_backend = BackendType.SELENE
        self.pairing.kickoff_pairing()

    def handle_local_backend_selected(self, message):
        self.handle_display_manager("BackendPersonalHost")
        self.speak_dialog("local_backend_url_prompt")

    def handle_personal_backend_url(self, message):
        host = message.data["host_address"]
        self.pairing.pairing_url = self.settings["pairing_url"] = host
        self.pairing.set_api_url(host)
        self.selected_backend = BackendType.PERSONAL
        self.setup.change_to_local_backend(host)
        # continue to normal pairing process
        self.state = SetupState.PAIRING
        self.pairing.kickoff_pairing()

    def handle_no_backend_selected(self, message):
        self.pairing.pairing_url = self.settings["pairing_url"] = ""
        self.pairing.data = None
        self.selected_backend = BackendType.OFFLINE
        self.setup.change_to_no_backend()
        self.handle_stt_menu()

    ### STT selection
    @killable_event(msg="pairing.stt.menu.stop",
                    callback=handle_intent_aborted)
    def handle_stt_menu(self):
        self.state = SetupState.SELECTING_STT
        self.handle_display_manager("BackendLocalSTT")
        self.send_stop_signal("pairing.confirmation.stop")
        self.speak_dialog("stt_intro")
        if self.pairing_mode != PairingMode.VOICE:
            self.speak_dialog("select_option_gui")
        if self.pairing_mode != PairingMode.GUI:
            self._stt_menu_voice()

    def _stt_menu_voice(self):
        self.speak_dialog("select_mycroft_stt")
        # TODO - get from .voc for lang support
        options = ["online with google", "offline with vosk"]
        ans = self.ask_selection(options, min_conf=0.35)
        if ans and self.ask_yesno("confirm_stt", {"stt": ans}) == "yes":
            if "google" in ans or "online" in ans:
                ans = "google"
            elif "vosk" in ans or "offline" in ans:
                ans = "vosk"
            self.bus.emit(Message(f"{self.skill_id}.mycroft.device.confirm.stt",
                                  {"engine": ans}))
        else:
            self.speak_dialog("choice-failed")
            self._stt_menu_voice()

    def handle_stt_selected(self, message):
        self.selected_stt = message.data["engine"]
        if self.selected_stt == "google":
            self.setup.change_to_chromium()
        else:
            self.setup.change_to_vosk()

        self.send_stop_signal("pairing.stt.menu.stop")
        self.handle_tts_menu()

    ### TTS selection
    @killable_event(msg="pairing.tts.menu.stop",
                    callback=handle_intent_aborted)
    def handle_tts_menu(self):
        self.state = SetupState.SELECTING_TTS
        self.handle_display_manager("BackendLocalTTS")
        self.send_stop_signal("pairing.stt.menu.stop")
        self.speak_dialog("tts_intro")
        if self.pairing_mode != PairingMode.VOICE:
            self.speak_dialog("select_option_gui")
        if self.pairing_mode != PairingMode.GUI:
            self._tts_menu_voice()

    def _tts_menu_voice(self):
        self.speak_dialog("select_mycroft_tts")
        options = ["online male", "offline male", "offline female", "online female"]
        ans = self.ask_selection(options, min_conf=0.35)
        if ans and self.ask_yesno("confirm_tts", {"tts": ans}) == "yes":
            tts = "mimic2"
            if ans == "offline male":
                tts = "mimic"
            if ans == "online female":
                tts = "larynx"
            if ans == "offline female":
                tts = "pico"
            self.bus.emit(Message(f'{self.skill_id}.mycroft.device.confirm.tts',
                                  {"engine": tts}))
        else:
            self.speak_dialog("choice-failed")
            self._tts_menu_voice()

    def handle_tts_selected(self, message):
        self.selected_tts = message.data["engine"]
        if self.selected_tts == "mimic":
            self.setup.change_to_mimic()
        elif self.selected_tts == "mimic2":
            self.setup.change_to_mimic2()
        elif self.selected_tts == "pico":
            self.setup.change_to_pico()
        elif self.selected_tts == "larynx":
            self.setup.change_to_larynx()

        self.send_stop_signal("pairing.tts.menu.stop")
        self.handle_display_manager("LoadingSkills")
        self.state = SetupState.INACTIVE

    # GUI
    def handle_display_manager(self, state):
        self.gui["state"] = state
        self.gui.show_page(
            "ProcessLoader.qml",
            override_idle=True,
            override_animations=True)

    def show_pairing_start(self):
        self.handle_display_manager("PairingStart")
        # self.gui.show_page("pairing_start.qml", override_idle=True,
        # override_animations=True)

    def show_pairing(self, code):
        # self.gui.remove_page("pairing_start.qml")
        # TODO - system theme
        self.gui["txtcolor"] = self.settings.get("color") or "#FF0000"
        self.gui["backendurl"] = self.settings.get("pairing_url") or "home.mycroft.ai"
        self.gui["code"] = code
        self.handle_display_manager("Pairing")
        # self.gui.show_page("pairing.qml", override_idle=True,
        # override_animations=True)

    def show_pairing_success(self):
        # self.gui.remove_page("pairing.qml")
        self.gui["status"] = "Success"
        self.gui["label"] = "Device Paired"
        self.gui["bgColor"] = "#40DBB0"
        # self.gui.show_page("status.qml", override_idle=True,
        # override_animations=True)
        self.handle_display_manager("Status")

    def show_pairing_fail(self):
        self.gui.release()
        self.gui["status"] = "Failed"
        self.gui["label"] = "Pairing Failed"
        self.gui["bgColor"] = "#FF0000"
        self.handle_display_manager("Status")
        sleep(5)

    def shutdown(self):
        self.pairing.shutdown()


def create_skill():
    return PairingSkill()
