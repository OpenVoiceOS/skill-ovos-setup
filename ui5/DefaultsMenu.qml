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
import QtGraphicalEffects 1.0
import Mycroft 1.0 as Mycroft

Item {
    id: defaultsMenu
    // anchors.fill: parent
    width: 800
    height: 480
    property bool horizontalMode: width > height ? 1 : 0
    property var defaultTTSEngine: sessionData.default_tts_engine
    property var defaultSTTEngine: sessionData.default_stt_engine

    Rectangle {
        color: Kirigami.Theme.backgroundColor
        anchors.fill: parent

        Rectangle {
            id: topArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Kirigami.Units.gridUnit * 3
            color: Kirigami.Theme.highlightColor

            Kirigami.Icon {
                id: topAreaIcon
                source: Qt.resolvedUrl("icons/defaults.svg")
                width: Kirigami.Units.iconSizes.large
                height: width
                anchors.left: parent.left
                anchors.leftMargin: Mycroft.Units.gridUnit * 2
                anchors.verticalCenter: parent.verticalCenter

                ColorOverlay {
                    anchors.fill: parent
                    source: topAreaIcon
                    color: Kirigami.Theme.textColor
                }
            }

            Label {
                id: selectLanguageHeader
                anchors.left: topAreaIcon.right
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: Mycroft.Units.gridUnit
                text: qsTr("Configure Engines")
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: topArea.height * 0.4
                elide: Text.ElideLeft
                maximumLineCount: 1
                color: Kirigami.Theme.textColor
            }

            Kirigami.Separator {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Kirigami.Units.largeSpacing
                anchors.rightMargin: Kirigami.Units.largeSpacing
                height: 1
                color: Kirigami.Theme.textColor
            }
        }

        ScrollBar {
            id: listViewScrollBar
            anchors.right: parent.right
            anchors.rightMargin: Mycroft.Units.gridUnit
            anchors.top: middleArea.top
            anchors.bottom: middleArea.bottom
            policy: ScrollBar.AsNeeded
        }

        ColumnLayout {
            id: middleArea
            clip: true
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: topArea.bottom
            anchors.margins: Mycroft.Units.gridUnit * 2

            Label {
                id: warnText
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
                color: Kirigami.Theme.textColor
                wrapMode: Text.WordWrap
                font.pixelSize: horizontalMode ? (defaultsMenu.height > 600 ? topArea.height * 0.4 : topArea.height * 0.25) : topArea.height * 0.3
                text: qsTr("We've selected the default engines to provide the optimal experience. You can optionally select your own engines or continue with the defaults.")
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Kirigami.Units.largeSpacing
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: defaultsMenu.horizontalMode ? Kirigami.Units.gridUnit * 3 : Kirigami.Units.gridUnit * 6
                columns: defaultsMenu.horizontalMode ? 2 : 1

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Rectangle {
                        color: Kirigami.Theme.highlightColor
                        radius: 4
                        width: Kirigami.Units.gridUnit * 8
                        height: Kirigami.Units.gridUnit * 1
                        anchors.top: parent.top
                        x: sttSelectionContent.x
                        y: -2
                        z: 2

                        Label {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            minimumPixelSize: 2
                            font.pixelSize: 72
                            maximumLineCount: 3
                            fontSizeMode: Text.Fit
                            wrapMode: Text.WordWrap
                            text: qsTr("Speech-To-Text Engine")
                            color: Kirigami.Theme.textColor
                        }
                    }

                    Rectangle {
                        id: sttSelectionContent
                        width: parent.width
                        height: Kirigami.Units.gridUnit * 2
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Kirigami.Units.smallSpacing
                        color: Kirigami.Theme.backgroundColor
                        border.width: 1
                        border.color: Kirigami.Theme.highlightColor
                        radius: 4


                        Label {
                            anchors.fill: parent
                            anchors.topMargin: Kirigami.Units.gridUnit * 1
                            anchors.leftMargin: Mycroft.Units.gridUnit / 2
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            color: Kirigami.Theme.textColor
                            maximumLineCount: 2
                            wrapMode: Text.WordWrap
                            font.bold: true
                            elide: Text.ElideRight
                            text: defaultSTTEngine.replace(/-/g, " ").replace(/_/g, " ").toUpperCase()
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Rectangle {
                        color: Kirigami.Theme.highlightColor
                        radius: 4
                        width: Kirigami.Units.gridUnit * 8
                        height: Kirigami.Units.gridUnit * 1
                        anchors.top: parent.top
                        x: ttsSelectionContent.x
                        y: -2
                        z: 2

                        Label {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            minimumPixelSize: 2
                            font.pixelSize: 72
                            maximumLineCount: 3
                            fontSizeMode: Text.Fit
                            wrapMode: Text.WordWrap
                            text: qsTr("Text-To-Speech Engine")
                            color: Kirigami.Theme.textColor
                        }
                    }

                    Rectangle {
                        id: ttsSelectionContent
                        width: parent.width
                        height: Kirigami.Units.gridUnit * 2
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Kirigami.Units.smallSpacing
                        color: Kirigami.Theme.backgroundColor
                        border.width: 1
                        border.color: Kirigami.Theme.highlightColor
                        radius: 4

                        Label {
                            anchors.fill: parent
                            anchors.topMargin: Kirigami.Units.gridUnit * 1
                            anchors.leftMargin: Mycroft.Units.gridUnit / 2
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            color: Kirigami.Theme.textColor
                            maximumLineCount: 2
                            wrapMode: Text.WordWrap
                            font.bold: true
                            elide: Text.ElideRight
                            text: defaultTTSEngine.replace(/-/g, " ").replace(/_/g, " ").toUpperCase()
                        }
                    }
                }
            }

            Button {
                id: configureEnginesButton
                Layout.fillWidth: true
                Layout.preferredHeight: Mycroft.Units.gridUnit * 3

                background: Rectangle {
                    color: configureEnginesButton.down ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
                    border.width: 2
                    border.color: configureEnginesButton.down ? Kirigami.Theme.backgroundColor : Kirigami.Theme.highlightColor
                    radius: 4
                }

                contentItem: Item {
                    RowLayout {
                        anchors.centerIn: parent

                        Kirigami.Icon {
                            Layout.fillHeight: true
                            Layout.preferredWidth: height
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            source: Qt.resolvedUrl("icons/defaults.svg")
                        }

                        Kirigami.Heading {
                            level: 2
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignRight
                            wrapMode: Text.WordWrap
                            font.bold: true
                            color: Kirigami.Theme.textColor
                            text: qsTr("Customize Engines")
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }

                onClicked: {
                    Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("sounds/clicked.wav"))
                    triggerGuiEvent("mycroft.device.quick.setup.customize", {})
                }
            }
        }

        Rectangle {
            id: bottomArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Kirigami.Units.gridUnit * 3
            color: Kirigami.Theme.highlightColor

            RowLayout {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing

                Button {
                    id: btnba1
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    background: Rectangle {
                        color: btnba1.down ? "transparent" :  Kirigami.Theme.backgroundColor
                        border.width: 3
                        border.color: Kirigami.Theme.backgroundColor
                        radius: 3
                    }

                    contentItem: Item {
                        RowLayout {
                            anchors.centerIn: parent

                            Kirigami.Icon {
                                Layout.fillHeight: true
                                Layout.preferredWidth: height
                                Layout.alignment: Qt.AlignVCenter
                                source: "arrow-left"
                            }

                            Kirigami.Heading {
                                level: 2
                                Layout.fillHeight: true
                                wrapMode: Text.WordWrap
                                font.bold: true
                                color: Kirigami.Theme.textColor
                                text: qsTr("Back")
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                            }
                        }
                    }

                    onClicked: {
                        Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("sounds/clicked.wav"))
                        triggerGuiEvent("mycroft.device.quick.setup.back", {})
                    }
                }

                Button {
                    id: btnba2
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    background: Rectangle {
                        color: btnba2.down ? "transparent" :  Kirigami.Theme.backgroundColor
                        border.width: 3
                        border.color: Kirigami.Theme.backgroundColor
                        radius: 3
                    }

                    contentItem: Item {
                        RowLayout {
                            anchors.centerIn: parent

                            Kirigami.Icon {
                                Layout.fillHeight: true
                                Layout.preferredWidth: height
                                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                                source: "dialog-ok-apply"
                            }

                            Kirigami.Heading {
                                level: 2
                                Layout.fillHeight: true
                                Layout.alignment: Qt.AlignRight
                                wrapMode: Text.WordWrap
                                font.bold: true
                                color: Kirigami.Theme.textColor
                                text: qsTr("Confirm")
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }

                    onClicked: {
                        Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("sounds/clicked.wav"))
                        triggerGuiEvent("mycroft.device.quick.setup.confirm", {"stt_engine": defaultSTTEngine, "tts_engine": defaultTTSEngine})
                    }
                }
            }
        }
    }
}
