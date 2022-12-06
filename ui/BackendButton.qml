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

Button {
    id: backendButtonControl
    property bool horizontalMode: false
    topInset: Mycroft.Units.gridUnit / 2
    leftInset: Mycroft.Units.gridUnit / 2
    rightInset: Mycroft.Units.gridUnit / 2
    bottomInset: Mycroft.Units.gridUnit / 2

    background: Rectangle {
        color: backendButtonControl.down ? "transparent" :  Kirigami.Theme.highlightColor
        border.width: 6
        border.color: Qt.darker(Kirigami.Theme.highlightColor, 1.2)
        radius: 10

        Rectangle {
            width: parent.width - 32
            height: parent.height - 32
            anchors.centerIn: parent
            color: backendButtonControl.down ? Kirigami.Theme.highlightColor : Qt.darker(Kirigami.Theme.backgroundColor, 1.5)
            radius: 10
        }
    }

    contentItem: Item {

        RowLayout {
            id: backendButtonContentsLayout
            anchors.fill: parent
            anchors.margins: Mycroft.Units.gridUnit * 2
            spacing: Mycroft.Units.gridUnit

            Kirigami.Icon {
                Layout.preferredWidth: backendButtonControl.horizontalMode ? parent.width * 0.3 : parent.height
                Layout.preferredHeight: backendButtonControl.horizontalMode ? width : parent.height
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.leftMargin: Mycroft.Units.gridUnit / 2
                source: Qt.resolvedUrl(model.backend_icon)
            }

            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: backendButtonControl.horizontalMode ? parent.width * 0.125 : parent.height * 0.7
                wrapMode: Text.WordWrap
                text: model.backend_name
            }
        }
    }

    onClicked: {
        Mycroft.SoundEffects.playClickedSound(Qt.resolvedUrl("sounds/clicked.wav"))
        triggerGuiEvent("mycroft.device.set.backend",
        {"backend": model.backend_type})
    }
}
