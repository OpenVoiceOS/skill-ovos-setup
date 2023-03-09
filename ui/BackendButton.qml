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

Button {
    id: backendButtonControl
    property string backendName
    property string backendIcon
    property string backendType
    property bool horizontalMode: false
    property var fontSize

    background: Rectangle {
        color: backendButtonControl.down ? "transparent" :  Kirigami.Theme.highlightColor
        border.width: 6
        border.color: backendButtonControl.activeFocus ? Kirigami.Theme.textColor : Qt.darker(Kirigami.Theme.highlightColor, 1.2)
        radius: 10

        Rectangle {
            width: parent.width - 32
            height: parent.height - 32
            anchors.centerIn: parent
            color: backendButtonControl.down ? Kirigami.Theme.highlightColor : Qt.darker(Kirigami.Theme.backgroundColor, 1.5)
            radius: 10
        }
    }

    contentItem: Loader {
        id: backendButtonLoader
        sourceComponent: backendButtonControl.horizontalMode ? horizontalButtonContent : verticalButtonContent
        onLoaded: {
            backendButtonLoader.item.backendName = backendButtonControl.backendName
            backendButtonLoader.item.backendIcon = backendButtonControl.backendIcon
        }
    }

    Keys.onReturnPressed: (event)=> {
        clicked()
    }

    onClicked: (mouse)=> {
        Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("sounds/clicked.wav"))
        triggerGuiEvent("mycroft.device.set.backend",
        {"backend": backendButtonControl.backendType})
    }

    Component {
        id: horizontalButtonContent

        ColumnLayout {
            id: backendButtonContentsLayout
            spacing: Mycroft.Units.gridUnit
            anchors.fill: parent
            property string backendName
            property string backendIcon

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height < 300 ? 0 : Mycroft.Units.gridUnit * 2
            }

            Item {
                Layout.preferredWidth: parent.width - Kirigami.Units.iconSizes.large * 4
                Layout.preferredHeight: parent.width - Kirigami.Units.iconSizes.large * 4
                Layout.minimumWidth: parent.height < 300 ? Kirigami.Units.iconSizes.large * 1.4 : Kirigami.Units.iconSizes.large * 2
                Layout.minimumHeight: parent.height < 300 ? Kirigami.Units.iconSizes.large * 1.4 : Kirigami.Units.iconSizes.large * 2
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom

                Kirigami.Icon {
                    width: parent.width * 0.8
                    height: parent.height * 0.8
                    anchors.centerIn: parent
                    source: backendButtonContentsLayout.backendIcon
                }
            }

            Label {
                Layout.fillWidth: true                
                Layout.fillHeight: true
                Layout.leftMargin: Mycroft.Units.gridUnit 
                Layout.rightMargin: Mycroft.Units.gridUnit
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

                verticalAlignment: Text.AlignTop
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                font.pixelSize: backendButtonControl.fontSize
                text: backendButtonContentsLayout.backendName
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    Component {
        id: verticalButtonContent
        
        RowLayout {
            id: backendButtonContentsLayout
            spacing: Mycroft.Units.gridUnit
            anchors.fill: parent
            property string backendName
            property string backendIcon

            Kirigami.Icon {
                Layout.preferredWidth: parent.height * 0.5
                Layout.preferredHeight: width
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.leftMargin: Mycroft.Units.gridUnit / 2
                source: backendButtonContentsLayout.backendIcon
            }

            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: Mycroft.Units.gridUnit / 2
                Layout.rightMargin: Mycroft.Units.gridUnit / 2

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: backendButtonControl.fontSize
                text: backendButtonContentsLayout.backendName
            }
        }
    }
}
