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
        btnba2.forceActiveFocus()
    }

    ListModel {
        id: backendFeatureList
        ListElement {
            text: "No Pairing Required"
        }
        ListElement {
            text: "Configurable STT Options: Google | Vosk"
        }
        ListElement {
            text: "Configurable TTS Options: Mimic2 | Mimic | Larynx | Pico"
        }
        ListElement {
            text: "Set your own API Keys"
        }
    }

    Rectangle {
        color: Kirigami.Theme.backgroundColor
        anchors.fill: parent
        anchors.margins: Mycroft.Units.gridUnit * 2

        Item {
            id: topArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: Kirigami.Units.largeSpacing
            anchors.rightMargin: Kirigami.Units.largeSpacing
            height: Kirigami.Units.gridUnit * 2

            Kirigami.Heading {
                id: brightnessSettingPageTextHeading
                level: 1
                wrapMode: Text.WordWrap
                anchors.centerIn: parent
                font.bold: true
                font.pixelSize: horizontalMode ? backendView.width * 0.035 : backendView.height * 0.040
                text: "No Backend"
                color: Kirigami.Theme.highlightColor
            }
        }

        Item {
            anchors.top: topArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: bottomArea.top
            anchors.margins: Kirigami.Units.smallSpacing
            
            ColumnLayout {
                anchors.fill: parent
                spacing: Kirigami.Units.smallSpacing

                Label {
                    id: warnText
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    color: Kirigami.Theme.textColor
                    wrapMode: Text.WordWrap
                    font.pixelSize: horizontalMode ? backendView.width * 0.035 : backendView.height * 0.040
                    text: "Allows your device to work offline"
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.largeSpacing
                }

                ListView {
                    id: qViewL
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: backendFeatureList
                    clip: true
                    currentIndex: -1
                    spacing: 5
                    property int cellWidth: qViewL.width
                    property int cellHeight: qViewL.height / 4.6
                    delegate: Rectangle {
                        width: qViewL.cellWidth
                        height: qViewL.cellHeight
                        radius: 10
                        color: Qt.darker(Kirigami.Theme.backgroundColor, 1.5)

                        Rectangle {
                            id: symb
                            anchors.left: parent.left
                            anchors.leftMargin: Kirigami.Units.smallSpacing
                            anchors.verticalCenter: parent.verticalCenter
                            height: parent.height - Kirigami.Units.largeSpacing
                            width: Kirigami.Units.iconSizes.medium
                            color: Kirigami.Theme.highlightColor
                            radius: width
                        }

                        Label {
                            id: cItm
                            anchors.left: symb.right
                            anchors.leftMargin: Kirigami.Units.largeSpacing
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            wrapMode: Text.WordWrap
                            anchors.margins: Kirigami.Units.smallSpacing
                            verticalAlignment: Text.AlignVCenter
                            color: Kirigami.Theme.textColor
                            text: model.text
                        }
                    }
                }
            }
        }

        RowLayout {
            id: bottomArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: footerArea.top
            anchors.topMargin: Kirigami.Units.largeSpacing
            anchors.leftMargin: Kirigami.Units.largeSpacing
            anchors.rightMargin: Kirigami.Units.largeSpacing
            anchors.bottomMargin: Kirigami.Units.largeSpacing
            height: Kirigami.Units.gridUnit * 3

            Button {
                id: btnba1
                Layout.fillWidth: true
                Layout.fillHeight: true

                KeyNavigation.right: btnba2
                Keys.onReturnPressed: clicked()

                background: Rectangle {
                    color: btnba1.down ? "transparent" :  (btnba1.activeFocus ? Kirigami.Theme.textColor : Kirigami.Theme.highlightColor)
                    border.width: 3
                    border.color: btnba1.activeFocus ? Kirigami.Theme.textColor : Qt.darker(Kirigami.Theme.highlightColor, 1.2)
                    radius: 10

                    Rectangle {
                        width: parent.width - 12
                        height: parent.height - 12
                        anchors.centerIn: parent
                        color: btnba1.down ? Kirigami.Theme.highlightColor : Qt.darker(Kirigami.Theme.backgroundColor, 1.25)
                        radius: 5
                    }
                }

                contentItem: Kirigami.Heading {
                    level: 3
                    wrapMode: Text.WordWrap
                    font.bold: true
                    color: Kirigami.Theme.textColor
                    text: "Back"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                onClicked: {
                    Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("../sounds/clicked.wav"))
                    triggerGuiEvent("mycroft.return.select.backend", {"page": "local"})
                }
            }

            Button {
                id: btnba2
                Layout.fillWidth: true
                Layout.fillHeight: true

                KeyNavigation.left: btnba1
                Keys.onReturnPressed: clicked()

                background: Rectangle {
                    color: btnba2.down ? "transparent" :  (btnba2.activeFocus ? Kirigami.Theme.textColor : Kirigami.Theme.highlightColor)
                    border.width: 3
                    border.color: btnba2.activeFocus ? Kirigami.Theme.textColor : Qt.darker(Kirigami.Theme.highlightColor, 1.2)
                    radius: 10

                    Rectangle {
                        width: parent.width - 12
                        height: parent.height - 12
                        anchors.centerIn: parent
                        color: btnba2.down ? Kirigami.Theme.highlightColor : Qt.darker(Kirigami.Theme.backgroundColor, 1.25)
                        radius: 5
                    }
                }

                contentItem: Kirigami.Heading {
                    level: 3
                    wrapMode: Text.WordWrap
                    font.bold: true
                    color: Kirigami.Theme.textColor
                    text: "Confirm"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                onClicked: {
                    Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("../sounds/clicked.wav"))
                    triggerGuiEvent("mycroft.device.confirm.backend", {"backend": "local"})
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
                text: "Use ◀ ▶ arrow keys to navigate, Use the ● select button to choose an option"
            }
        }
    }
} 
