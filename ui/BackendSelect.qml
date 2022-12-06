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

import QtQuick.Layouts 1.12
import QtQuick 2.12
import QtQuick.Controls 2.12
import org.kde.kirigami 2.11 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import QtGraphicalEffects 1.0
import Mycroft 1.0 as Mycroft

Item {
    id: backendView
    anchors.fill: parent
    property bool horizontalMode: backendView.width > backendView.height ? 1 : 0
    property bool languageSelectionEnabled: sessionData.language_selection_enabled ? Boolean(sessionData.language_selection_enabled) : 0

    Rectangle {
        color: Kirigami.Theme.backgroundColor
        anchors.fill: parent

        Rectangle {
            id: topArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: backendSelectionGridView.count < 4 ? Kirigami.Units.gridUnit * 4 : Kirigami.Units.gridUnit * 3
            color: Kirigami.Theme.highlightColor

            Kirigami.Icon {
                id: topAreaIcon
                source: "emblem-system-symbolic"
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
                text: qsTr("Select Your Backend")
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
            id: backendScroller
            anchors.right: parent.right
            anchors.top: topArea.bottom
            anchors.bottom: bottomArea.top
            width: Mycroft.Units.gridUnit
        }

        ColumnLayout {
            id: middleArea
            anchors.bottom: bottomArea.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: topArea.bottom
            anchors.leftMargin: Mycroft.Units.gridUnit * 2
            anchors.rightMargin: Mycroft.Units.gridUnit * 2
            anchors.topMargin: backendSelectionGridView.count < 4 ? Mycroft.Units.gridUnit * 2 : Mycroft.Units.gridUnit / 2
            anchors.bottomMargin: backendSelectionGridView.count < 4 ? Mycroft.Units.gridUnit * 2 : Mycroft.Units.gridUnit / 2

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                GridView {
                    id: backendSelectionGridView
                    clip: true
                    anchors.fill: parent
                    cellWidth: horizontalMode ? width / 3 : width
                    cellHeight: horizontalMode ? (backendSelectionGridView.count < 4 ? height : height / 2) : Kirigami.Units.gridUnit * 4
                    model: sessionData.backend_list
                    ScrollBar.vertical: backendScroller
                    delegate: BackendButton {
                        implicitWidth: backendSelectionGridView.cellWidth
                        implicitHeight: backendSelectionGridView.cellHeight
                        horizontalMode: backendView.horizontalMode
                    }
                }
            }
        }


        Rectangle {
            id: bottomArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: backendView.horizontalMode ? (backendView.languageSelectionEnabled ? Kirigami.Units.gridUnit * 3 : Kirigami.Units.gridUnit * 2) : (backendView.languageSelectionEnabled ? Kirigami.Units.gridUnit * 5 : Kirigami.Units.gridUnit * 3)
            color: Kirigami.Theme.highlightColor

            GridLayout {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                columns: backendView.horizontalMode && backendView.languageSelectionEnabled ? 2 : 1

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: backendView.horizontalMode ? parent.height : parent.height / 2

                    Kirigami.Icon {
                        id: warnTextIcon
                        source: "documentinfo"
                        width: Kirigami.Units.iconSizes.mediumSmall
                        height: width
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter

                        ColorOverlay {
                            anchors.fill: parent
                            source: warnTextIcon
                            color: Kirigami.Theme.textColor
                        }
                    }

                    Label {
                        id: warnText
                        anchors.left: warnTextIcon.right
                        anchors.leftMargin: Mycroft.Units.gridUnit / 2
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                        color: Kirigami.Theme.textColor
                        text: qsTr("A backend provides services used by OpenVoiceOS Core")
                    }
                }

                Button {
                    id: btnba1
                    Layout.preferredWidth: backendView.horizontalMode ? Kirigami.Units.gridUnit * 10 : parent.width
                    Layout.fillHeight: true
                    enabled: backendView.languageSelectionEnabled ? 1 : 0
                    visible: backendView.languageSelectionEnabled ? 1 : 0

                    background: Rectangle {
                        color: btnba1.down ? "transparent" :  Kirigami.Theme.backgroundColor
                        border.width: 3
                        border.color: Kirigami.Theme.backgroundColor
                        radius: 3
                    }

                    contentItem: Item {
                        id: contentsForBtnBa1
                        RowLayout {
                            anchors.centerIn: parent

                            Kirigami.Icon {
                                Layout.topMargin: 5
                                Layout.bottomMargin: 5
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
                                text: qsTr("Language Selection")
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                            }
                        }
                    }

                    onClicked: {
                        Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("sounds/clicked.wav"))
                        triggerGuiEvent("mycroft.return.select.language", {})
                    }
                }
            }
        }
    }
}
