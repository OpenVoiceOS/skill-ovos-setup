/*
    SPDX-FileCopyrightText: 2023 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: Apache-2.0
*/

import QtQuick.Layouts 1.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.kirigami 2.19 as Kirigami
import Mycroft 1.0 as Mycroft
import Qt5Compat.GraphicalEffects

Item {
    id: languageView
    anchors.fill: parent
    property bool horizontalMode: languageView.width > languageView.height ? 1 :0
    property var supportedLanguagesModel: sessionData.supportedLanguagesModel ? sessionData.supportedLanguagesModel : []

    Rectangle {
        color: Kirigami.Theme.backgroundColor
        anchors.fill: parent

        Rectangle {
            id: topArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Kirigami.Units.gridUnit * 4
            color: Kirigami.Theme.highlightColor

            Kirigami.Icon {
                id: topAreaIcon
                source: "globe"
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
                text: qsTr("Select Language")
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
            policy: ScrollBar.AlwaysOn

            contentItem: Rectangle {
                implicitWidth: 6
                radius: 6
                color: Kirigami.Theme.highlightColor
            }
        }

        Rectangle {
            id: middleArea
            Kirigami.Theme.colorSet: Kirigami.Theme.View
            Kirigami.Theme.inherit: false
            color: Kirigami.Theme.disabledTextColor
            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1
            anchors.top: topArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: bottomArea.top
            anchors.leftMargin: Mycroft.Units.gridUnit * 2
            anchors.rightMargin: Mycroft.Units.gridUnit * 2
            anchors.topMargin: Mycroft.Units.gridUnit
            anchors.bottomMargin: Mycroft.Units.gridUnit

            ListView {
                id: languagesListView
                anchors.fill: parent
                anchors.margins: 1
                spacing: 1
                clip: true

                model: supportedLanguagesModel

                ScrollBar.vertical: listViewScrollBar

                delegate: ItemDelegate {
                    id: listItemDelegate
                    width: languagesListView.width
                    height: languagesListView.height > 650 ? languagesListView.height * 0.20 : languagesListView.height * 0.25

                    background: Rectangle {
                        id: listItemDelegateBg
                        Kirigami.Theme.colorSet: Kirigami.Theme.Button
                        Kirigami.Theme.inherit: false
                        color: Qt.lighter(Kirigami.Theme.backgroundColor, 1.5)
                        radius: 1
                    }

                    contentItem: Label {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Kirigami.Theme.textColor
                        text: model.name
                        font.pixelSize: listItemDelegate.height * 0.4
                    }

                    onClicked: (mouse)=> {
                        Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("sounds/clicked.wav"))
                        triggerGuiEvent("mycroft.device.confirm.language", {"code": model.code, "name": model.name, "system_code": model.system_code})
                    }

                    onPressed: (mouse)=> {
                        Kirigami.Theme.colorSet = Kirigami.Theme.Button
                        Kirigami.Theme.inherit = false
                        listItemDelegateBg.color = Kirigami.Theme.highlightColor
                    }
                    onReleased: (mouse)=> {
                        Kirigami.Theme.colorSet = Kirigami.Theme.Button
                        Kirigami.Theme.inherit = false
                        listItemDelegateBg.color = Kirigami.Theme.backgroundColor
                    }
                }
                move: Transition {
                    NumberAnimation { properties: "x,y"; duration: 1000 }
                }
            }
        }

        Item {
            id: bottomArea
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: Kirigami.Units.gridUnit * 3.5

            Kirigami.Separator {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Kirigami.Units.largeSpacing
                anchors.rightMargin: Kirigami.Units.largeSpacing
                height: 1
                color: Kirigami.Theme.highlightColor
            }

            Label {
                id: selectLanguageDesc
                anchors.fill: parent
                anchors.leftMargin: Kirigami.Units.smallSpacing
                anchors.rightMargin: Kirigami.Units.smallSpacing
                text: qsTr("Language selection affects your choice of avialable STT & TTS engines")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: topArea.height * 0.27
                wrapMode: Text.WordWrap
                elide: Text.ElideMiddle
                maximumLineCount: 2
                color: Kirigami.Theme.textColor
            }
        }
    }
}
