import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import com.company 1.0
import com.rizzons.syntax 1.0
ToolBar {
    property color backgroundColor
    property color accentColor
    property color buttoncolor : "#E5B142"
    
    height: 60
    contentHeight: 60
    background: Rectangle { 
        color: backgroundColor
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 8
            samples: 17
            color: "#14000000"
            verticalOffset: 1
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        
        // Left spacer
        Item { Layout.fillWidth: true }
        
        // Logo with fixed size
        Image {
            source: "icons/logo.png"
            Layout.preferredWidth: 120
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignCenter
            fillMode: Image.PreserveAspectFit
            
            layer.enabled: true
            layer.effect: ColorOverlay {
                color: buttoncolor
            }
        }
        
        // Right spacer
        Item { Layout.fillWidth: true }
    }
}