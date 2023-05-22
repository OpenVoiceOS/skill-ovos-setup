# Changelog

## [Unreleased](https://github.com/OpenVoiceOS/skill-ovos-setup/tree/HEAD)

[Full Changelog](https://github.com/OpenVoiceOS/skill-ovos-setup/compare/V0.0.2a5...HEAD)

**Breaking changes:**

- rm selene + voice route [\#75](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/75) ([JarbasAl](https://github.com/JarbasAl))

## [V0.0.2a5](https://github.com/OpenVoiceOS/skill-ovos-setup/tree/V0.0.2a5) (2023-03-21)

[Full Changelog](https://github.com/OpenVoiceOS/skill-ovos-setup/compare/V0.0.2a4...V0.0.2a5)

**Merged pull requests:**

- Add basic key navigation and button hover [\#73](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/73) ([AIIX](https://github.com/AIIX))

## [V0.0.2a4](https://github.com/OpenVoiceOS/skill-ovos-setup/tree/V0.0.2a4) (2023-02-09)

[Full Changelog](https://github.com/OpenVoiceOS/skill-ovos-setup/compare/V0.0.2a3...V0.0.2a4)

**Merged pull requests:**

- rename RuntimeRequirements [\#71](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/71) ([JarbasAl](https://github.com/JarbasAl))

## [V0.0.2a3](https://github.com/OpenVoiceOS/skill-ovos-setup/tree/V0.0.2a3) (2023-01-31)

[Full Changelog](https://github.com/OpenVoiceOS/skill-ovos-setup/compare/V0.0.2a2...V0.0.2a3)

**Merged pull requests:**

- use class property to define skill as offline [\#70](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/70) ([AIIX](https://github.com/AIIX))

## [V0.0.2a2](https://github.com/OpenVoiceOS/skill-ovos-setup/tree/V0.0.2a2) (2023-01-31)

[Full Changelog](https://github.com/OpenVoiceOS/skill-ovos-setup/compare/V0.0.2a1...V0.0.2a2)

**Merged pull requests:**

- fix text overflow in list delegates [\#65](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/65) ([AIIX](https://github.com/AIIX))

## [V0.0.2a1](https://github.com/OpenVoiceOS/skill-ovos-setup/tree/V0.0.2a1) (2023-01-30)

[Full Changelog](https://github.com/OpenVoiceOS/skill-ovos-setup/compare/V0.0.1...V0.0.2a1)

**Merged pull requests:**

- fix scaling of buttons on backend select [\#68](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/68) ([AIIX](https://github.com/AIIX))

## [V0.0.1](https://github.com/OpenVoiceOS/skill-ovos-setup/tree/V0.0.1) (2023-01-25)

[Full Changelog](https://github.com/OpenVoiceOS/skill-ovos-setup/compare/V0.0.1a1...V0.0.1)

## [V0.0.1a1](https://github.com/OpenVoiceOS/skill-ovos-setup/tree/V0.0.1a1) (2023-01-25)

[Full Changelog](https://github.com/OpenVoiceOS/skill-ovos-setup/compare/7759f8161bfc0e53bf169e200170af655d255ec0...V0.0.1a1)

**Implemented enhancements:**

- Add support for "enable\_stt\_selection", "enable\_tts\_selection", "enable\_backend\_selection" [\#29](https://github.com/OpenVoiceOS/skill-ovos-setup/issues/29)
- Aix rebased listview [\#59](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/59) ([JarbasAl](https://github.com/JarbasAl))
- allow image to set preferred engine to show on top and fix getting engines fail [\#53](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/53) ([AIIX](https://github.com/AIIX))
- feat/sorted\_plugins [\#47](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/47) ([JarbasAl](https://github.com/JarbasAl))
- refactor translation [\#45](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/45) ([emphasize](https://github.com/emphasize))
- feat/autopair\_personal\_backend [\#44](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/44) ([JarbasAl](https://github.com/JarbasAl))
- Add german locale [\#43](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/43) ([emphasize](https://github.com/emphasize))
- feat/setup\_stage\_flags [\#37](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/37) ([JarbasAl](https://github.com/JarbasAl))
- Adds Language and Welcome UI, Design Updates, Translations [\#22](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/22) ([AIIX](https://github.com/AIIX))
- feat/voice pairing [\#18](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/18) ([JarbasAl](https://github.com/JarbasAl))

**Fixed bugs:**

- Setup skill will not go past backend confirmation on no backend in latest version [\#49](https://github.com/OpenVoiceOS/skill-ovos-setup/issues/49)
- Setup skill after completion seems to capture all intents [\#48](https://github.com/OpenVoiceOS/skill-ovos-setup/issues/48)
- fix GUI crashing with too many options reported by plugins [\#55](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/55) ([JarbasAl](https://github.com/JarbasAl))
- disable converse completely if using gui mode as its totally broken [\#51](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/51) ([AIIX](https://github.com/AIIX))
- fix/enum\_string [\#46](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/46) ([JarbasAl](https://github.com/JarbasAl))
- fix how to see if we need gui or voice and condition back button on backend selection page [\#41](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/41) ([AIIX](https://github.com/AIIX))
- Handle skipped backend selection as no backend if not already paired [\#40](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/40) ([NeonDaniel](https://github.com/NeonDaniel))
- Fix typo in setup.py getting skill/package name [\#39](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/39) ([NeonDaniel](https://github.com/NeonDaniel))
- fix/stt\_tts\_selection [\#38](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/38) ([JarbasAl](https://github.com/JarbasAl))
- deprecate\_disabled\_flag + cleanup code [\#36](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/36) ([JarbasAl](https://github.com/JarbasAl))
- fix Setup [\#35](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/35) ([JarbasAl](https://github.com/JarbasAl))
- Fix/pairing [\#34](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/34) ([JarbasAl](https://github.com/JarbasAl))
- Loose r [\#32](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/32) ([JarbasAl](https://github.com/JarbasAl))
- Fix config setting to match signatures in `SetupManager` [\#27](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/27) ([NeonDaniel](https://github.com/NeonDaniel))
- fix/serialization of enum [\#25](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/25) ([JarbasAl](https://github.com/JarbasAl))
- fix/pairing event emit [\#24](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/24) ([JarbasAl](https://github.com/JarbasAl))
- Hotfix/no gui pairing [\#15](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/15) ([JarbasAl](https://github.com/JarbasAl))
- Fix/double vosk [\#14](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/14) ([JarbasAl](https://github.com/JarbasAl))
- consistency [\#13](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/13) ([JarbasAl](https://github.com/JarbasAl))
- better wifi integration [\#12](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/12) ([JarbasAl](https://github.com/JarbasAl))
- mycroft.not.paired [\#10](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/10) ([JarbasAl](https://github.com/JarbasAl))
- only write config at final step [\#9](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/9) ([JarbasAl](https://github.com/JarbasAl))
- fix/locks\_and\_timing [\#8](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/8) ([JarbasAl](https://github.com/JarbasAl))

**Merged pull requests:**

- Add PyPI Automation [\#69](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/69) ([NeonDaniel](https://github.com/NeonDaniel))
- Fix disable debug [\#67](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/67) ([AIIX](https://github.com/AIIX))
- Add quick defaults for no backend [\#66](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/66) ([AIIX](https://github.com/AIIX))
- fix ttslist menu errors [\#62](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/62) ([AIIX](https://github.com/AIIX))
- Move plugin dependencies to optional extras [\#61](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/61) ([NeonDaniel](https://github.com/NeonDaniel))
- wait for dialog to be spoken [\#60](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/60) ([emphasize](https://github.com/emphasize))
- fix error overlay count bug [\#54](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/54) ([AIIX](https://github.com/AIIX))
- Feat/bump [\#50](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/50) ([JarbasAl](https://github.com/JarbasAl))
- bump requirements.txt [\#42](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/42) ([JarbasAl](https://github.com/JarbasAl))
- Add missing imports from os module [\#33](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/33) ([NeonDaniel](https://github.com/NeonDaniel))
- Setup [\#30](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/30) ([JarbasAl](https://github.com/JarbasAl))
- finished state [\#26](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/26) ([JarbasAl](https://github.com/JarbasAl))
- Add bigscreen ui for selection menu [\#17](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/17) ([AIIX](https://github.com/AIIX))
- Follow Color Scheme and Add Button Sounds [\#16](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/16) ([AIIX](https://github.com/AIIX))
- feat/workflows [\#7](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/7) ([JarbasAl](https://github.com/JarbasAl))
- :tada: - packaging [\#5](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/5) ([JarbasAl](https://github.com/JarbasAl))
- Implement a GUI only workflow [\#4](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/4) ([AIIX](https://github.com/AIIX))
- add fix for pairing code scale [\#3](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/3) ([AIIX](https://github.com/AIIX))
- fix pairing send correct emits for process check [\#2](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/2) ([AIIX](https://github.com/AIIX))
- use mock backend [\#1](https://github.com/OpenVoiceOS/skill-ovos-setup/pull/1) ([JarbasAl](https://github.com/JarbasAl))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
