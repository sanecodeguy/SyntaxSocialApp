import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

TabButton {
    id: root
    width: implicitWidth
    height: implicitHeight
    display: checked ? TabButton.TextBesideIcon : TabButton.IconOnly
    topPadding: 10
    leftPadding: 14
    rightPadding: 14
    bottomPadding: 10
    spacing: 10
    clip: true
    icon.color: checked ? palette.highlightedText : palette.buttonText
    font.bold: true
    
    // Dark theme color palette
    palette {
        buttonText: "#BBBAB9"  // secondaryText
        highlight: "#3E3E3E"  // tabHighlight
        highlightedText: "#FEC347"  // accentColor
    }

    contentItem: Item {
        implicitWidth: img.width + (root.spacing + label.contentWidth) * label.visible
        implicitHeight: img.height

        Image {
            id: img
            width: root.icon.width
            height: root.icon.height
            anchors {
                left: root.display === TabButton.IconOnly ? undefined : parent.left
                verticalCenter: parent.verticalCenter
                horizontalCenter: root.display === TabButton.IconOnly ? parent.horizontalCenter : undefined
            }
            source: root.icon.source

            ColorOverlay {
                anchors.fill: parent
                source: parent
                color: root.icon.color
                cached: true
            }
        }

        Label {
            id: label
            anchors {
                topMargin: root.spacing
                left: img.right
                leftMargin: root.spacing
                verticalCenter: parent.verticalCenter
            }
            text: root.text
            font: root.font
            color: root.checked ? root.palette.highlightedText : root.palette.buttonText
            visible: root.display !== TabButton.IconOnly
        }
    }

    background: Item {
        implicitWidth: 30
        implicitHeight: 30

        Rectangle {
            anchors.fill: parent
            color: root.checked ? root.palette.highlight : "#2E2E2E"  // tabHighlight or tabInactive
            radius: parent.height * 0.6
        }
    }

    Behavior on width {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutBack
        }
    }
}