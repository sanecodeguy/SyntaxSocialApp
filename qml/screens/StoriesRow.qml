import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import com.company 1.0
import com.rizzons.syntax 1.0

Rectangle {
    property color cardColor
    property color dividerColor
    property color primaryText
    property int friendCount
    
    width: parent.width
    height: 100
    color: cardColor
    border.color: dividerColor
    border.width: 1

    // Get friends list from current user
    property var friendsList: {
        if (Syntax.getCurrentUser()) {
            return Syntax.getCurrentUser().getFriendsList()
        }
        return []
    }

    ListView {
        anchors.fill: parent
        orientation: ListView.Horizontal
        spacing: 16
        leftMargin: 12
        clip: true
        model: friendsList

        delegate: Column {
            spacing: 6
            width: 72
            padding: 4

            Rectangle {
                width: 64
                height: 64
                radius: width / 2
                anchors.horizontalCenter: parent.horizontalCenter
                
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#f09433" }
                    GradientStop { position: 0.25; color: "#e6683c" }
                    GradientStop { position: 0.5; color: "#dc2743" }
                    GradientStop { position: 0.75; color: "#cc2366" }
                    GradientStop { position: 1.0; color: "#bc1888" }
                }
                
                Rectangle {
                    anchors.centerIn: parent
                    width: 60
                    height: 60
                    radius: width / 2
                    color: cardColor
                    
                    Image {
                        anchors.centerIn: parent
                        width: 56
                        height: 56
                        source: "https://avatar.iran.liara.run/public?name=" + modelData.username
                        fillMode: Image.PreserveAspectFit
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: 56
                                height: 56
                                radius: width / 2
                            }
                        }
                    }
                }
            }
            Text {
                width: parent.width
                text: modelData.username
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                color: primaryText
            }
        }
    }
}