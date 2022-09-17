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
                    id: selBText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    font.bold: true
                    font.pixelSize: backendView.width * 0.05
                    color: Kirigami.Theme.highlightColor
                    text: "Select Your Backend"
                }

                Label {
                    id: warnText
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    wrapMode: Text.WordWrap
                    font.pixelSize: backendView.width * 0.04
                    color: Kirigami.Theme.textColor
                    text: "A backend provides services used by Mycroft Core"
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
                            border.width: 6
                            border.color: Qt.darker(Kirigami.Theme.highlightColor, 1.2)
                            radius: 10

                            Rectangle {
                                width: parent.width - 32
                                height: parent.height - 32
                                anchors.centerIn: parent
                                color: bt1.down ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                                radius: 10
                            }
                        }

                        contentItem: Label {
                            width: parent.width
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            fontSizeMode: horizontalMode ? Text.HorizontalFit : Text.VerticalFit
                            minimumPixelSize: 8
                            font.pixelSize: 32
                            text: "Mycroft Backend"
                        }

                        onClicked: {
                            Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("sounds/clicked.wav"))
                            triggerGuiEvent("mycroft.device.set.backend",
                            {"backend": "selene"})
                        }
                    }

                    Button {
                        id: bt2
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: Mycroft.Units.gridUnit

                        background: Rectangle {
                            color: bt2.down ? "transparent" :  Kirigami.Theme.highlightColor
                            border.width: 6
                            border.color: Qt.darker(Kirigami.Theme.highlightColor, 1.2)
                            radius: 10

                            Rectangle {
                                width: parent.width - 32
                                height: parent.height - 32
                                anchors.centerIn: parent
                                color: bt2.down ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                                radius: 10
                            }
                        }

                        contentItem: Label {
                            width: parent.width
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            fontSizeMode: horizontalMode ? Text.HorizontalFit : Text.VerticalFit
                            minimumPixelSize: 8
                            font.pixelSize: 32
                            text: "Personal Backend"
                        }

                        onClicked: {
                            Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("sounds/clicked.wav"))
                            triggerGuiEvent("mycroft.device.set.backend",
                            {"backend": "personal"})
                        }
                    }

                    Button {
                        id: bt3
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: Mycroft.Units.gridUnit

                        background: Rectangle {
                            color: bt3.down ? "transparent" :  Kirigami.Theme.highlightColor
                            border.width: 6
                            border.color: Qt.darker(Kirigami.Theme.highlightColor, 1.2)
                            radius: 10

                            Rectangle {
                                width: parent.width - 32
                                height: parent.height - 32
                                anchors.centerIn: parent
                                color: bt3.down ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                                radius: 10
                            }
                        }

                        contentItem: Label {
                            width: parent.width
                            height: parent.height
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            fontSizeMode: horizontalMode ? Text.HorizontalFit : Text.VerticalFit
                            minimumPixelSize: 8
                            font.pixelSize: 32
                            text: "No Backend"
                        }

                        onClicked: {
                            Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("sounds/clicked.wav"))
                            triggerGuiEvent("mycroft.device.set.backend",
                            {"backend": "offline"})
                        }
                    }
                }
            }
        }
    }
} 
