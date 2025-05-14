import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

TabBar {
    id: root
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight)
    spacing: 10
    topPadding: (height - contentHeight) / 2
    leftPadding: (width - contentWidth) / 2
    rightPadding: (width - contentWidth) / 2
    bottomPadding: (height - contentHeight) / 2
    
    // Dark theme color palette
    palette {
        base: "#1E1E1E"  // cardColor
        buttonText: "#BBBAB9"  // secondaryText
        highlightedText: "#FEC347"  // accentColor
        highlight: "#3E3E3E"  // tabHighlight
        window: "#111111"  // backgroundColor
    }

    contentItem: ListView {
        model: root.contentModel
        currentIndex: root.currentIndex
        spacing: root.spacing
        orientation: Qt.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.AutoFlickIfNeeded
        snapMode: ListView.SnapToItem
        highlightMoveDuration: 0
        highlightRangeMode: ListView.ApplyRange
        preferredHighlightBegin: 0
        preferredHighlightEnd: width
        clip: true
    }

    background: Rectangle {
        implicitWidth: 400
        implicitHeight: 80
        color: root.palette.base
        radius: 12

        RectangularGlow {
            z: -1
            anchors.fill: parent
            glowRadius: 8
            color: "#80000000"
            cornerRadius: parent.radius + glowRadius
            cached: true
        }
    }
}