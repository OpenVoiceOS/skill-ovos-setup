import QtQuick.Layouts 1.4
import QtQuick 2.4
import QtQuick.Controls 2.0
import org.kde.kirigami 2.4 as Kirigami
import QtGraphicalEffects 1.0
import Mycroft 1.0 as Mycroft
import org.kde.lottie 1.0

Item {
    id: root
    
    Rectangle {
        anchors.fill: parent
        color: Kirigami.Theme.backgroundColor
        
        ColumnLayout {
            id: grid
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            
            Label {
                id: statusLabel
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: parent.height * 0.075
                wrapMode: Text.WordWrap
                renderType: Text.NativeRendering
                font.family: "Noto Sans Display"
                font.styleName: "Black"
                text: "Configuring"
                color: Kirigami.Theme.textColor
            }
            
            Label {
                id: statusLabel2
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: parent.height * 0.075
                wrapMode: Text.WordWrap
                renderType: Text.NativeRendering
                font.family: "Noto Sans Display"
                font.styleName: "Black"
                text: "Local Backend"
                color: Kirigami.Theme.highlightColor
            }
            
            RowLayout {
                id: warnText
                Layout.fillWidth: true
                
                Image {
                    id: iconCircle
                    source: "icons/info-circle.svg"
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                    ColorOverlay {
                        source: iconCircle
                        anchors.fill: iconCircle
                        color: Kirigami.Theme.textColor
                    }
                }
                
                Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: width * 0.040
                    wrapMode: Text.WordWrap
                    color: Kirigami.Theme.textColor
                    text: "Device will reboot to complete configuring the device"
                }
            }

            LottieAnimation {
                id: statusIcon
                visible: true
                enabled: true
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                loops: Animation.Infinite
                fillMode: Image.PreserveAspectFit
                running: true
                source: Qt.resolvedUrl("animations/installing.json")
            }
        }
    }
}
