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
import logging
import time
from threading import Timer, Lock
from time import sleep
from uuid import uuid4

import mycroft.audio
from adapt.intent import IntentBuilder
from mycroft.api import DeviceApi, is_paired, check_remote_pairing
from mycroft.configuration import LocalConf, USER_CONFIG
from mycroft.identity import IdentityManager
from mycroft.messagebus.message import Message
from mycroft.skills.core import intent_handler
from ovos_workshop.skills import OVOSSkill
from ovos_workshop.decorators import killable_event
from requests import HTTPError
from ovos_utils.network_utils import is_connected
from ovos_utils.gui import can_use_gui
from ovos_utils.log import LOG
from enum import Enum


_default_stt_config = {
    'ovos-stt-plugin-vosk-streaming': {},
    'ovos-stt-plugin-server': {
        "url": "https://stt.openvoiceos.com/stt"
    }
}


_default_tts_config = {
    "ovos-tts-plugin-pico": {},
    "neon-tts-plugin-larynx-server": {
        "host": "http://tts.neon.ai",
        "voice": "mary_ann",
        "vocoder": "hifi_gan/vctk_small"
    },
    "ovos-tts-plugin-mimic2": {"voice": "kusal"},
    "ovos-tts-plugin-mimic": {"voice": "ap"}
}


class SetupState(str, Enum):
    FIRST_BOOT = "first"
    LOADING = "loading"
    INACTIVE = "inactive"
    SELECTING_WIFI = "wifi"
    SELECTING_BACKEND = "backend"
    SELECTING_STT = "stt"
    SELECTING_TTS = "tts"
    PAIRING = "pairing"


class PairingSkill(OVOSSkill):
    poll_frequency = 5  # secs between checking server for activation

    def __init__(self):
        super(PairingSkill, self).__init__("PairingSkill")
        self.reload_skill = False
        self.api = DeviceApi()
        self.data = None
        self.time_code_expires = None
        self.uuid = str(uuid4())
        self.activator = None
        self.activator_lock = Lock()
        self.activator_cancelled = False
        self.config_lock = Lock()
        self.counter_lock = Lock()
        self.count = -1  # for repeating pairing code. -1 = not running

        self.nato_dict = None
        self.mycroft_ready = False
        self.num_failed_codes = 0

        self.state = SetupState.LOADING

    # startup
    def initialize(self):
        # specific distros/vendors can override this
        if "pairing_url" not in self.settings:
            self.settings["pairing_url"] = "home.mycroft.ai"
        if "color" not in self.settings:
            self.settings["color"] = "#FF0000"

        self.add_event("mycroft.not.paired", self.not_paired)
        self.add_event("ovos.setup.state", self.handle_get_setup_state)

        # events for GUI interaction
        self.gui.register_handler("mycroft.device.set.backend", self.handle_backend_selected_event)
        self.gui.register_handler("mycroft.device.confirm.backend", self.handle_backend_confirmation_event)
        self.gui.register_handler("mycroft.return.select.backend", self.handle_return_event)
        self.gui.register_handler("mycroft.device.confirm.stt", self.select_stt)
        self.gui.register_handler("mycroft.device.confirm.tts", self.select_tts)
        self.nato_dict = self.translate_namedvalues('codes')

        # uncomment this line for debugging
        # will always trigger setup on boot
        # self.selected_backend = None

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
            if self.settings.get('selected_stt') is None:
                LOG.info(f"Handle STT First Setup")
                self.bus.once('mycroft.ready', self.handle_stt_menu)
            elif not self.settings.get('selected_tts') is None:
                LOG.info(f"Handle TTS First Setup")
                self.bus.once('mycroft.ready', self.handle_tts_menu)
            self.state = SetupState.INACTIVE
            self.handle_display_manager("LoadingSkills")
            self.update_device_attributes_on_backend()

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
        elif self.settings.get('selected_stt') is None:
            LOG.info(f"Handle STT First Setup")
            self.handle_stt_menu()
        elif not self.settings.get('selected_tts') is None:
            LOG.info(f"Handle TTS First Setup")
            self.handle_tts_menu()
        else:
            self.state = SetupState.INACTIVE

    def handle_wifi_skip(self, message):
        self.log.info("Offline mode selected, setup will resume on restart")
        self.handle_display_manager("OfflineMode")
        self.state = SetupState.INACTIVE

    def send_stop_signal(self, stop_event=None, should_sleep=True):
        # TODO move this one into default OVOSkill class
        # stop the previous event execution
        if stop_event:
            self.bus.emit(Message(stop_event))
        # stop TTS
        self.bus.emit(Message("mycroft.audio.speech.stop"))
        if should_sleep:
            # STT might continue recording and screw up the next get_response
            # TODO make mycroft-core allow aborting recording in a sane way
            self.bus.emit(Message('mycroft.mic.mute'))
            sleep(0.5)  # if TTS had not yet started
            self.bus.emit(Message("mycroft.audio.speech.stop"))
            sleep(1.5)  # the silence from muting should make STT stop recording
            self.bus.emit(Message('mycroft.mic.unmute'))

    def handle_intent_aborted(self):
        self.log.info("killing all dialogs")

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

        if not can_use_gui():
            if message:  # intent
                self.speak_dialog("screen.required")
            self.state = SetupState.INACTIVE
            return

        if self.selected_backend and check_remote_pairing(ignore_errors=True):
            # Already paired!
            if message:  # intent
                self.speak_dialog("already.paired")
            self.state = SetupState.INACTIVE
            self.show_pairing_success()
        elif not self.data:
            self.handle_backend_menu()

    # config handling
    def update_user_config(self, config):
        with self.config_lock:
            conf = LocalConf(USER_CONFIG)
            conf.merge(config)
            conf.store()
            self.bus.emit(Message("configuration.patch",
                                  {"config": conf}))

    @staticmethod
    def _get_stt_module_config(module: str, lang: str = 'en-us'):
        from ovos_plugin_manager.stt import get_stt_module_configs
        default_config = get_stt_module_configs(module)
        config = default_config.get(lang) or _default_stt_config.get(module)
        LOG.info(config)
        return config

    @staticmethod
    def _get_tts_module_config(module: str, lang: str = 'en-us'):
        from ovos_plugin_manager.tts import get_tts_module_configs
        default_config = get_tts_module_configs(module)
        config = default_config.get(lang) or _default_tts_config.get(module)
        LOG.info(config)
        return config

    def change_to_selene(self):
        config = {
            "stt": {"module": "mycroft"},
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
        self.selected_backend = "selene"

    def change_to_local_backend(self):
        config = {
            "server": {
                "disabled": True
            }
        }
        self.update_user_config(config)
        self.selected_backend = "local"
        self.create_dummy_identity()

    # Pairing GUI events
    #### Backend selection menu
    @killable_event(msg="pairing.backend.menu.stop")
    def handle_backend_menu(self):
        self.state = SetupState.SELECTING_BACKEND
        self.send_stop_signal("pairing.confirmation.stop")
        self.handle_display_manager("BackendSelect")
        self.speak_dialog("backend_intro")
        self.speak_dialog("select_option_gui")

    def handle_backend_selected_event(self, message):
        self.send_stop_signal("pairing.backend.menu.stop", should_sleep=False)
        self.handle_backend_confirmation(message.data["backend"])

    def handle_return_event(self, message):
        self.send_stop_signal("pairing.confirmation.stop", should_sleep=False)
        page = message.data.get("page", "")
        self.handle_backend_menu()

    ### Backend confirmation
    @killable_event(msg="pairing.confirmation.stop",
                    callback=handle_intent_aborted)
    def handle_backend_confirmation(self, selection):
        if selection == "selene":
            self.handle_display_manager("BackendMycroft")
            self.speak_dialog("selene_intro")
            self.speak_dialog("selene_confirm_gui")
        elif selection == "local":
            self.handle_display_manager("BackendLocal")
            self.speak_dialog("no_backend_intro")
            self.speak_dialog("no_backend_confirm_gui")

    def handle_backend_confirmation_event(self, message):
        self.send_stop_signal("pairing.confirmation.stop")
        if message.data["backend"] == "local":
            self.select_local()
        else:
            self.select_selene()

    def select_selene(self):
        # selene selected
        self.change_to_selene()
        # continue to normal pairing process
        self.kickoff_pairing()

    def select_local(self, message=None):
        self.change_to_local_backend()
        self.data = None
        self.handle_stt_menu()

    ### STT selection
    @killable_event(msg="pairing.stt.menu.stop",
                    callback=handle_intent_aborted)
    def handle_stt_menu(self, _=None):
        self.state = SetupState.SELECTING_STT
        self.handle_display_manager("BackendLocalSTT")
        LOG.info(f"STT GUI Displayed")
        self.send_stop_signal("pairing.confirmation.stop")
        self.speak_dialog("stt_intro")
        self.speak_dialog("select_option_gui")

    def select_stt(self, message):
        self.selected_stt = message.data["engine"]
        LOG.info(f"Got STT selection: {self.selected_stt}")
        if self.selected_stt == "google":
            module_spec = "ovos-stt-plugin-server"
        elif self.selected_stt == "kaldi":
            module_spec = "ovos-stt-plugin-vosk-streaming"
        else:
            module_spec = None
        if module_spec:
            self.update_user_config({"tts": {
                    "module": module_spec,
                    module_spec: self._get_tts_module_config(module_spec,
                                                             self.lang)
                }})
        self.send_stop_signal("pairing.stt.menu.stop")
        self.handle_tts_menu()

    ### TTS selection
    @killable_event(msg="pairing.tts.menu.stop",
                    callback=handle_intent_aborted)
    def handle_tts_menu(self, _=None):
        self.send_stop_signal("pairing.stt.menu.stop")
        self.state = SetupState.SELECTING_TTS
        self.handle_display_manager("BackendLocalTTS")
        self.speak_dialog("tts_intro")
        self.speak_dialog("select_option_gui")

    def select_tts(self, message):
        self.selected_tts = message.data["engine"]
        if self.selected_tts == "mimic":
            module_spec = "ovos-tts-plugin-mimic"
        elif self.selected_tts == "mimic2":
            module_spec = "ovos-tts-plugin-mimic2"
        elif self.selected_tts == "pico":
            module_spec = "ovos-tts-plugin-pico"
        elif self.selected_tts == "larynx":
            module_spec = "ovos-tts-plugin-larynx-server"
        else:
            module_spec = None
        if module_spec:
            self.update_user_config({"stt": {
                    "module": module_spec,
                    module_spec: self._get_stt_module_config(module_spec,
                                                             self.lang)
                }})
        self.send_stop_signal()
        self.handle_display_manager("LoadingSkills")
        self.state = SetupState.INACTIVE

    ## Local backend pairing
    def create_dummy_identity(self):
        # create pairing file with dummy data
        login = {"uuid": self.uuid,
                 "access": "OVOSdbF1wJ4jA5lN6x6qmVk_QvJPqBQZTUJQm7fYzkDyY_Y=",
                 "refresh": "OVOS66c5SpAiSpXbpHlq9HNGl1vsw_srX49t5tCv88JkhuE=",
                 "expires_at": time.time() + 999999}
        IdentityManager.save(login)

    # selene pairing
    def update_device_attributes_on_backend(self):
        """Communicate version information to the backend.

        The backend tracks core version, enclosure version, platform build
        and platform name for each device, if it is known.
        """
        self.log.info('Sending updated device attributes to the backend...')
        try:
            api = DeviceApi()
            api.update_version()
        except Exception:
            pass

    def kickoff_pairing(self):
        self.state = SetupState.PAIRING
        self.data = None

        # Kick off pairing...
        with self.counter_lock:
            if self.count > -1:
                # We snuck in to this handler somehow while the pairing
                # process is still being setup.  Ignore it.
                self.log.debug("Ignoring call to handle_pairing")
                return
            # Not paired or already pairing, so start the process.
            self.count = 0

        self.log.debug("Kicking off pairing sequence")

        try:
            # Obtain a pairing code from the backend
            self.data = self.api.get_code(self.uuid)

            # Keep track of when the code was obtained.  The codes expire
            # after 20 hours.
            self.time_code_expires = time.monotonic() + 72000  # 20 hours
        except Exception:
            time.sleep(10)
            # Call restart pairing here
            # Bail out after Five minutes (5 * 6 attempts at 10 seconds
            # interval)
            if self.num_failed_codes < 5 * 6:
                self.num_failed_codes += 1
                self.abort_and_restart(quiet=True)
            else:
                self.end_pairing('connection.error')
                self.num_failed_codes = 0
            return

        self.num_failed_codes = 0  # Reset counter on success

        mycroft.audio.wait_while_speaking()

        self.show_pairing_start()
        self.speak_dialog("pairing.intro")

        # HACK this gives the Mark 1 time to scroll the address and
        # the user time to browse to the website.
        # TODO: mouth_text() really should take an optional parameter
        # to not scroll a second time.
        time.sleep(7)
        mycroft.audio.wait_while_speaking()

        if not self.activator:
            self.__create_activator()

    def check_for_activate(self):
        """Method is called every 10 seconds by Timer. Checks if user has
        activated the device yet on home.mycroft.ai and if not repeats
        the pairing code every 60 seconds.
        """
        try:
            # Attempt to activate.  If the user has completed pairing on the,
            # backend, this will succeed.  Otherwise it throws and HTTPError()

            token = self.data.get("token")
            login = self.api.activate(self.uuid, token)  # HTTPError() thrown

            # When we get here, the pairing code has been entered on the
            # backend and pairing can now be saved.
            # The following is kinda ugly, but it is really critical that we
            # get this saved successfully or we need to let the user know that
            # they have to perform pairing all over again at the website.
            try:
                IdentityManager.save(login)
            except Exception as e:
                self.log.debug("First save attempt failed: " + repr(e))
                time.sleep(2)
                try:
                    IdentityManager.save(login)
                except Exception as e2:
                    # Something must be seriously wrong
                    self.log.debug("Second save attempt failed: " + repr(e2))
                    self.abort_and_restart()

            if mycroft.audio.is_speaking():
                # Assume speaking is the pairing code.  Stop TTS of that.
                mycroft.audio.stop_speaking()

            self.show_pairing_success()
            self.bus.emit(Message("mycroft.paired", login))

            if self.mycroft_ready:
                # Tell user they are now paired
                self.speak_dialog("pairing.paired", wait=True)

            # Un-mute.  Would have been muted during onboarding for a new
            # unit, and not dangerous to do if pairing was started
            # independently.
            self.bus.emit(Message("mycroft.mic.unmute", None))

            # allow gui page to linger around a bit
            sleep(5)

            self.handle_display_manager("LoadingSkills")

            self.update_device_attributes_on_backend()
            self.state = SetupState.INACTIVE

        except HTTPError:
            # speak pairing code every 60th second
            with self.counter_lock:
                if self.count == 0:
                    self.speak_code()
                self.count = (self.count + 1) % 6

            if time.monotonic() > self.time_code_expires:
                # After 20 hours the token times out.  Restart
                # the pairing process.
                with self.counter_lock:
                    self.count = -1
                self.data = None
                self.handle_pairing()
            else:
                # trigger another check in 10 seconds
                self.__create_activator()
        except Exception as e:
            self.log.debug("Unexpected error: " + repr(e))
            self.abort_and_restart()

    def end_pairing(self, error_dialog):
        """Resets the pairing and don't restart it.

        Arguments:
            error_dialog: Reason for the ending of the pairing process.
        """
        self.speak_dialog(error_dialog)
        self.bus.emit(Message("mycroft.mic.unmute", None))

        self.data = None
        self.count = -1
        self.state = SetupState.INACTIVE

    def abort_and_restart(self, quiet=False):
        # restart pairing sequence
        self.log.debug("Aborting Pairing")
        self.enclosure.activate_mouth_events()
        if not quiet:
            self.speak_dialog("unexpected.error.restarting")

        # Reset state variables for a new pairing session
        with self.counter_lock:
            self.count = -1
        self.activator = None
        self.data = None  # Clear pairing code info
        self.log.info("Restarting pairing process")
        self.show_pairing_fail()
        self.bus.emit(Message("mycroft.not.paired",
                              data={'quiet': quiet}))

    def __create_activator(self):
        # Create a timer that will poll the backend in 10 seconds to see
        # if the user has completed the device registration process
        with self.activator_lock:
            if not self.activator_cancelled:
                self.activator = Timer(PairingSkill.poll_frequency,
                                       self.check_for_activate)
                self.activator.daemon = True
                self.activator.start()

    def speak_code(self):
        """Speak pairing code."""
        code = self.data.get("code")
        self.log.info("Pairing code: " + code)
        data = {"code": '. '.join(map(self.nato_dict.get, code)) + '.'}
        self.show_pairing(self.data.get("code"))
        self.speak_dialog("pairing.code", data)

    # GUI
    def handle_display_manager(self, state):
        self.gui["state"] = state
        self.gui.show_page(
            "ProcessLoader.qml",
            override_idle=True,
            override_animations=True)

    def show_pairing_start(self):
        # Make sure code stays on display
        self.enclosure.deactivate_mouth_events()
        self.enclosure.mouth_text(self.settings["pairing_url"] + "      ")
        self.handle_display_manager("PairingStart")
        # self.gui.show_page("pairing_start.qml", override_idle=True,
        # override_animations=True)

    def show_pairing(self, code):
        # self.gui.remove_page("pairing_start.qml")
        self.enclosure.deactivate_mouth_events()
        self.enclosure.mouth_text(code)
        self.gui["txtcolor"] = self.settings["color"]
        self.gui["backendurl"] = self.settings["pairing_url"]
        self.gui["code"] = code
        self.handle_display_manager("Pairing")
        # self.gui.show_page("pairing.qml", override_idle=True,
        # override_animations=True)

    def show_pairing_success(self):
        self.enclosure.activate_mouth_events()  # clears the display
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
        with self.activator_lock:
            self.activator_cancelled = True
            if self.activator:
                self.activator.cancel()
        if self.activator:
            self.activator.join()


def create_skill():
    return PairingSkill()
