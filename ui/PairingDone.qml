/*
    SPDX-FileCopyrightText: 2023 Aditya Mehra <aix.m@outlook.com>
    SPDX-License-Identifier: Apache-2.0
*/

import QtQuick.Layouts 1.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.kirigami 2.19 as Kirigami
import Mycroft 1.0 as Mycroft

Item {
    id: root
    anchors.fill: parent

    Rectangle {
        color: Kirigami.Theme.backgroundColor
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent

            Kirigami.Heading {
                id: hey
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 1
                elide: Text.ElideRight
                fontSizeMode: Text.Fit
                minimumPixelSize: 8
                font.family: "Noto Sans"
                font.bold: true
                font.weight: Font.Bold
                font.pixelSize: 50
                color: Kirigami.Theme.highlightColor
                text: "Hey Mycroft"
            }
            Kirigami.Heading {
                id: example1
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                fontSizeMode: Text.Fit
                minimumPixelSize: 8
                font.family: "Noto Sans"
                font.bold: true
                font.weight: Font.Bold
                font.pixelSize: 35
                color: Kirigami.Theme.textColor
                text: "What's the\nweather?"
            }
            Kirigami.Heading {
                id: example2
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                fontSizeMode: Text.Fit
                minimumPixelSize: 8
                font.family: "Noto Sans"
                font.bold: true
                font.weight: Font.Bold
                font.pixelSize: 35
                color: Kirigami.Theme.textColor
                text: "Tell me about\nAbraham Lincoln"
            }
            Kirigami.Heading {
                id: example3
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                fontSizeMode: Text.Fit
                minimumPixelSize: 8
                font.family: "Noto Sans"
                font.bold: true
                font.weight: Font.Bold
                font.pixelSize: 35
                color: Kirigami.Theme.textColor
                text: "Play the News"
            }
        }
    }
}  
