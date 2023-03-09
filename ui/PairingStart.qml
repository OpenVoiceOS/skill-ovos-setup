/*
    SPDX-FileCopyrightText: 2023 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: Apache-2.0
*/

import QtQuick.Layouts 1.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.kirigami 2.19 as Kirigami
import Mycroft 1.0 as Mycroft
import org.kde.lottie 1.0

Item {
    id: root
    anchors.fill: parent

    Rectangle {
        color: Kirigami.Theme.backgroundColor
        anchors.fill: parent
        anchors.margins: Mycroft.Units.gridUnit * 2

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
                    
            Kirigami.Heading {
                id: sentence2
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                color: Kirigami.Theme.highlightColor
                font.family: "Noto Sans"
                font.bold: true
                font.weight: Font.Bold
                font.pixelSize: root.width * 0.035
                text: qsTr("Fetching Pairing Code")
            }
            
            LottieAnimation {
                id: l1
                Layout.fillWidth: true
                Layout.fillHeight: true
                source: Qt.resolvedUrl("animations/connected-waiting.json")
                loops: Animation.Infinite
                fillMode: Image.PreserveAspectFit
                running: true
            }
            
            Kirigami.Heading {
                id: sentence
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                color: Kirigami.Theme.textColor
                font.family: "Noto Sans"
                font.bold: true
                font.weight: Font.Bold
                font.pixelSize: parent.height * 0.075
                text: qsTr("I'm connected\nand need to be\nactivated")
            }
        }
    }
}  
