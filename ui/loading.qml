import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

Mycroft.Delegate {
    skillBackgroundSource: "https://github.com/OpenVoiceOS/ovos_assets/raw/master/Logo/ovos-logo-512.png"

    Mycroft.PaginatedText {
         anchors.fill: parent
         text: "Installing default skills...."
         currentIndex: 0
         horizontalAlignment: Text.AlignHCenter
         //font.pointSize: Kirigami.Units.gridUnit
         // HACK TO SET BETTER SIZE ON RESPEAKER IMAGE
         font.pointSize: Kirigami.Units.smallSpacing * 3
    }
}