import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    property ListView target: null
    property bool refreshing: false
    property color color: "#0095f6"
    property int threshold: 100
    
    signal refresh()
    
    width: target ? target.width : 0
    height: refreshing ? 60 : Math.max(0, target.contentY * -1)
    visible: target !== null
    
    onRefreshingChanged: {
        if (!refreshing) {
            target.contentY = 0;
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: root.color
        visible: parent.height > 0
        
        Row {
            anchors.centerIn: parent
            spacing: 10
            visible: root.refreshing
            
            BusyIndicator {
                running: root.refreshing
                width: 30
                height: 30
                palette.dark: "white"
            }
            
            Text {
                text: "Refreshing..."
                color: "white"
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        Text {
            anchors.centerIn: parent
            text: "Pull to refresh"
            color: "white"
            font.pixelSize: 14
            visible: !root.refreshing && parent.height > 30
        }
    }
    
    Connections {
        target: root.target
        
        function onContentYChanged() {
            if (!root.refreshing && root.target.contentY < -root.threshold && root.target.dragging) {
                root.refreshing = true;
                root.refresh();
            }
        }
        
        function onDraggingChanged() {
            if (!root.target.dragging && root.target.contentY < 0 && !root.refreshing) {
                bounceBackAnim.start();
            }
        }
    }
    
    NumberAnimation {
        id: bounceBackAnim
        target: root.target
        property: "contentY"
        to: 0
        duration: 300
        easing.type: Easing.OutQuad
    }
}