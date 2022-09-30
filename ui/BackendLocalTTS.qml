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
    property var offlineMale: sessionData.offlineMale
    property var onlineMale: sessionData.onlineMale
    property var offlineFemale: sessionData.offlineFemale
    property var onlineFemale: sessionData.onlineFemale

    anchors.fill: parent
    property bool horizontalMode: backendView.width > backendView.height ? 1 :0

    Rectangle {
        color: Kirigami.Theme.backgroundColor
        anchors.fill: parent
        anchors.margins: Mycroft.Units.gridUnit * 2

        GridLayout {
            anchors.fill: parent
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

                        background: Rectangle {
                            color: bt1.down ? "transparent" :  Kirigami.Theme.highlightColor
                            border.width: 3
                            border.color: Qt.darker(Kirigami.Theme.highlightColor, 1.2)
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
                            text: "Online Male - " + backendView.onlineMale
                        }

                        onClicked: {
                            Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("sounds/clicked.wav"))
                            triggerGuiEvent("mycroft.device.confirm.tts", {"engine": backendView.onlineMale})
                        }
                    }

                    Button {
                        id: bt2
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: Mycroft.Units.gridUnit

                        background: Rectangle {
                            color: bt2.down ? "transparent" :  Kirigami.Theme.highlightColor
                            border.width: 3
                            border.color: Qt.darker(Kirigami.Theme.highlightColor, 1.2)
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
                            text: "Online Female - " + backendView.onlineFemale
                        }

                        onClicked: {
                            Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("sounds/clicked.wav"))
                            triggerGuiEvent("mycroft.device.confirm.tts",
                            {"engine": backendView.onlineFemale})
                        }
                    }

                    Button {
                        id: bt3
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: Mycroft.Units.gridUnit

                        background: Rectangle {
                            color: bt3.down ? "transparent" :  Kirigami.Theme.highlightColor
                            border.width: 3
                            border.color: Qt.darker(Kirigami.Theme.highlightColor, 1.2)
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
                            text: "Offline Male - " + backendView.offlineMale
                        }

                        onClicked: {
                            Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("sounds/clicked.wav"))
                            triggerGuiEvent("mycroft.device.confirm.tts",
                            {"engine": backendView.offlineMale})
                        }
                    }
                    Button {
                        id: bt4
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: Mycroft.Units.gridUnit

                        background: Rectangle {
                            color: bt4.down ? "transparent" :  Kirigami.Theme.highlightColor
                            border.width: 3
                            border.color: Qt.darker(Kirigami.Theme.highlightColor, 1.2)
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
                            text: "Offline Female - " + backendView.offlineFemale
                        }

                        onClicked: {
                            Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("sounds/clicked.wav"))
                            triggerGuiEvent("mycroft.device.confirm.tts",
                            {"engine": backendView.offlineFemale})
                        }
                    }
                }
            }
        }
    }
} 
