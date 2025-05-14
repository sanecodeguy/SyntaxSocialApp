import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import com.company 1.0
import com.rizzons.syntax 1.0
Column {
    property color accentColor
    property color primaryText
    property color secondaryText
    property string fontFamily
    property Component discoverComponent
    property Component friendsComponent
    property color dividerColor
    
    anchors.centerIn: parent
    spacing: 24
    width: parent.width

    Image {
        source: "icons/logo.png"
        width: 120
        height: 120
        fillMode: Image.PreserveAspectFit
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 0.2
        layer.enabled: true
        layer.effect: ColorOverlay {
            color: accentColor
        }
    }

    Column {
        width: parent.width
        spacing: 8
        
        Text {
            text: "No Posts Yet"
            color: primaryText
            font {
                pixelSize: 18
                weight: Font.Bold
                family: fontFamily
            }
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "When you follow accounts, their posts will appear here."
            color: secondaryText
            font {
                pixelSize: 14
                family: fontFamily
            }
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Button {
        width: parent.width
        height: 44
        anchors.horizontalCenter: parent.horizontalCenter
        
        background: Rectangle {
            color: parent.down ? Qt.darker(accentColor, 1.1) : accentColor
            radius: 8
        }
        
        contentItem: Text {
            text: "Discover Accounts"
            color: "#111111"
            font {
                pixelSize: 14
                weight: Font.Bold
                family: fontFamily
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        onClicked: stack.push(discoverComponent)
    }

    Button {
        width: parent.width
        height: 44
        anchors.horizontalCenter: parent.horizontalCenter
        
        background: Rectangle {
            color: parent.down ? Qt.darker(dividerColor, 1.1) : dividerColor
            radius: 8
        }
        
        contentItem: Text {
            text: "Show / Add Friends"
            color: primaryText
            font {
                pixelSize: 14
                weight: Font.Bold
                family: fontFamily
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        onClicked: stack.push(friendsComponent)
    }
}