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
    property var code: sessionData.code
    property var backendurl: "account.mycroft.ai/pair"
    anchors.fill: parent
    property bool horizontalMode: root.width > root.height ? 1 :0

    Rectangle {
        color: Kirigami.Theme.backgroundColor
        anchors.fill: parent
        anchors.margins: Mycroft.Units.gridUnit * 2

        GridLayout {
            id: colLay
            anchors.fill: parent
            columns: horizontalMode ? 1 : 1
            columnSpacing: Kirigami.Units.largeSpacing
            Layout.alignment: horizontalMode ? Qt.AlignVCenter : Qt.AlignTop

            ColumnLayout {
                Layout.preferredWidth: horizontalMode ? parent.width / 1.5 : parent.width
                Layout.preferredHeight: horizontalMode ? parent.height : parent.height / 2
                Layout.alignment: horizontalMode ? Qt.AlignVCenter : Qt.AlignTop

                Kirigami.Heading {
                    id: sentence3
                    Layout.fillWidth: true
                    Layout.alignment: horizontalMode ? Qt.AlignVCenter | Qt.AlignLeft : Qt.AlignTop | Qt.AlignLeft
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    font.weight: Font.Bold
                    font.pixelSize: horizontalMode ? root.width * 0.07 : root.height * 0.04
                    horizontalAlignment: Text.AlignHCenter
                    color: Kirigami.Theme.textColor
                    text: qsTr("Pair this device at")
                }
                Kirigami.Heading {
                    id: sentence3b
                    Layout.fillWidth: true
                    Layout.alignment: horizontalMode ? Qt.AlignVCenter | Qt.AlignLeft : Qt.AlignTop | Qt.AlignLeft
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    font.weight: Font.Bold
                    font.pixelSize: horizontalMode ? root.width * 0.07 : root.height * 0.04
                    horizontalAlignment: Text.AlignHCenter
                    color: Kirigami.Theme.highlightColor
                    text: root.backendurl
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop
                    color: Qt.darker(Kirigami.Theme.backgroundColor, 1.5)

                    Kirigami.Heading {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        font.weight: Font.Bold
                        font.pixelSize: horizontalMode ? root.width * 0.12 : root.height * 0.05
                        color: Kirigami.Theme.highlightColor
                        text: root.code
                    }
                }
            }
        }
    }
}  
