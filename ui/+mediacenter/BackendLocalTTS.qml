/*
 * Copyright 2018 Aditya Mehra <aix.m@outlook.com>
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.0
import org.kde.kirigami 2.5 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import Mycroft 1.0 as Mycroft

Item {
    id: backendView
    anchors.fill: parent
    property bool horizontalMode: backendView.width > backendView.height ? 1 :0

    Component.onCompleted: {
        bt1.forceActiveFocus()
    }

    Rectangle {
        color: Kirigami.Theme.backgroundColor
        anchors.fill: parent
        anchors.margins: Mycroft.Units.gridUnit * 2

        GridLayout {
            anchors.top: parent.top
            anchors.bottom: footerArea.top
            anchors.left: parent.left
            anchors.right: parent.right
            z: 1
            columns: horizontalMode ? 2 : 1
            columnSpacing: Kirigami.Units.largeSpacing
            Layout.alignment: horizontalMode ? Qt.AlignVCenter : Qt.AlignTop

            ColumnLayout {
                Layout.maximumWidth: horizontalMode ? parent.width / 2 : parent.width
                Layout.preferredHeight: horizontalMode ? parent.height : parent.height / 2
                Layout.alignment: horizontalMode ? Qt.AlignVCenter : Qt.AlignTop

                Label {
                    id: configureSttEngineText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    font.bold: true
                    font.pixelSize: backendView.width * 0.05
                    color: Kirigami.Theme.highlightColor
                    text: "Configure Your TTS Engine"
                }

                Label {
                    id: warnText
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    wrapMode: Text.WordWrap
                    font.pixelSize: backendView.width * 0.04
                    color: Kirigami.Theme.textColor
                    text: "Text-To-Speech (TTS) is the process of converting strings of text into audio of spoken words"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Qt.darker(Kirigami.Theme.backgroundColor, 1.25)

                ColumnLayout {
                    anchors.fill: parent

                    Button {
                        id: bt1
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: Mycroft.Units.gridUnit

                        KeyNavigation.down: bt2
                        Keys.onReturnPressed: clicked()

                        background: Rectangle {
                            color: bt1.down ? "transparent" :  (bt1.activeFocus ? Kirigami.Theme.textColor : Kirigami.Theme.highlightColor)
                            border.width: 3
                            border.color: bt1.activeFocus ? Kirigami.Theme.textColor : Qt.darker(Kirigami.Theme.highlightColor, 1.2)
                            radius: 10

                            Rectangle {
                                width: parent.width - 12
                                height: parent.height - 12
                                anchors.centerIn: parent
                                color: bt1.down ? Kirigami.Theme.highlightColor : Qt.darker(Kirigami.Theme.backgroundColor, 1.25)
                                radius: 5
                            }
                        }

                        contentItem: Kirigami.Heading {
                            width: parent.width
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            level: 3
                            color: Kirigami.Theme.textColor
                            text: "Mimic2 (online male)"
                        }

                        onClicked: {
                            Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("../sounds/clicked.wav"))
                            triggerGuiEvent("mycroft.device.confirm.tts", {"engine": "mimic2"})
                        }
                    }

                    Button {
                        id: bt2
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: Mycroft.Units.gridUnit

                        KeyNavigation.up: bt1
                        KeyNavigation.down: bt3
                        Keys.onReturnPressed: clicked()

                        background: Rectangle {
                            color: bt2.down ? "transparent" :  (bt2.activeFocus ? Kirigami.Theme.textColor : Kirigami.Theme.highlightColor)
                            border.width: 3
                            border.color: bt2.activeFocus ? Kirigami.Theme.textColor : Qt.darker(Kirigami.Theme.highlightColor, 1.2)
                            radius: 10

                            Rectangle {
                                width: parent.width - 12
                                height: parent.height - 12
                                anchors.centerIn: parent
                                color: bt2.down ? Kirigami.Theme.highlightColor : Qt.darker(Kirigami.Theme.backgroundColor, 1.25)
                                radius: 5
                            }
                        }

                        contentItem: Kirigami.Heading {
                            width: parent.width
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            level: 3
                            color: Kirigami.Theme.textColor
                            text: "Larynx (online female)"
                        }

                        onClicked: {
                            Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("../sounds/clicked.wav"))
                            triggerGuiEvent("mycroft.device.confirm.tts",
                            {"engine": "larynx"})
                        }
                    }

                    Button {
                        id: bt3
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: Mycroft.Units.gridUnit

                        KeyNavigation.up: bt2
                        KeyNavigation.down: bt4
                        Keys.onReturnPressed: clicked()

                        background: Rectangle {
                            color: bt3.down ? "transparent" :  (bt3.activeFocus ? Kirigami.Theme.textColor : Kirigami.Theme.highlightColor)
                            border.width: 3
                            border.color: bt3.activeFocus ? Kirigami.Theme.textColor : Qt.darker(Kirigami.Theme.highlightColor, 1.2)
                            radius: 10

                            Rectangle {
                                width: parent.width - 12
                                height: parent.height - 12
                                anchors.centerIn: parent
                                color: bt3.down ? Kirigami.Theme.highlightColor : Qt.darker(Kirigami.Theme.backgroundColor, 1.25)
                                radius: 5
                            }
                        }

                        contentItem: Kirigami.Heading {
                            width: parent.width
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            level: 3
                            color: Kirigami.Theme.textColor
                            text: "Mimic (offline male)"
                        }

                        onClicked: {
                            Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("../sounds/clicked.wav"))
                            triggerGuiEvent("mycroft.device.confirm.tts", {"engine": "mimic"})
                        }
                    }
                    Button {
                        id: bt4
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: Mycroft.Units.gridUnit

                        KeyNavigation.up: bt3
                        Keys.onReturnPressed: clicked()

                        background: Rectangle {
                            color: bt4.down ? "transparent" :  (bt4.activeFocus ? Kirigami.Theme.textColor : Kirigami.Theme.highlightColor)
                            border.width: 3
                            border.color: bt4.activeFocus ? Kirigami.Theme.textColor : Qt.darker(Kirigami.Theme.highlightColor, 1.2)
                            radius: 10

                            Rectangle {
                                width: parent.width - 12
                                height: parent.height - 12
                                anchors.centerIn: parent
                                color: bt4.down ? Kirigami.Theme.highlightColor : Qt.darker(Kirigami.Theme.backgroundColor, 1.25)
                                radius: 5
                            }
                        }

                        contentItem: Kirigami.Heading {
                            width: parent.width
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            level: 3
                            color: Kirigami.Theme.textColor
                            text: "Pico (offline female)"
                        }

                        onClicked: {
                            Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("../sounds/clicked.wav"))
                            triggerGuiEvent("mycroft.device.confirm.tts",
                            {"engine": "pico"})
                        }
                    }
                }
            }
        }

        Item {
            id: footerArea
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: Kirigami.Units.gridUnit * 2

            Kirigami.Separator {
                id: footerAreaSept
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Kirigami.Theme.highlightColor
            }

            Label {
                anchors.top: footerAreaSept
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Mycroft.Units.gridUnit / 3
                fontSizeMode: Text.Fit
                minimumPixelSize: 10
                font.pixelSize: 24
                color: Kirigami.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                maximumLineCount: 1
                text: "Use ▲ ▼ arrow keys to navigate, Use the ● select button to choose an option"
            }
        }
    }
} 