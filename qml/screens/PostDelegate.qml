import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts 1.15
import com.company 1.0
import com.rizzons.syntax 1.0

Item {
    id:root
    property color cardColor
    property color dividerColor
    property color primaryText
    property color secondaryText
    property color accentColor
    property string fontFamily
    
    width: ListView.view.width
    height: column.implicitHeight + 40
    anchors.horizontalCenter: parent.horizontalCenter
    property bool isLiked: false
    property int currentLikes: modelData.likesCount || 0
    // Like animation component
    Item {
        id: likeAnimation
        width: 50
        height: 50
        visible: false

        function like(x, y) {
            var heart = heartComponent.createObject(root, {
                "x": x - width/2,
                "y": y - height/2
            });
            heart.startAnimation();
        }

        Component {
            id: heartComponent
            
            Item {
                id: heartContainer
                width: 50
                height: 50
                
                property real targetX: (Math.random() - 0.5) * 100
                property real targetY: -100
                
                property real animScale: 0.5
                property real animRotation: (Math.random() - 0.5) * 30
                property real animOpacity: 0
                property real animXProgress: 0
                property real animYProgress: 0
                
                Canvas {
                    id: heartCanvas
                    anchors.fill: parent
                    
                    onPaint: {
                        var ctx = getContext("2d");
                        var centerX = width / 2;
                        var centerY = height / 2;
                        
                        var gradient = ctx.createLinearGradient(0, 0, width, height);
                        gradient.addColorStop(0.2, "red");
                        gradient.addColorStop(1, "purple");
                        
                        ctx.fillStyle = gradient;
                        ctx.strokeStyle = "transparent";
                        ctx.lineWidth = 0;
                        
                        ctx.beginPath();
                        ctx.moveTo(centerX, height * 0.35);
                        ctx.bezierCurveTo(
                            width * 0.2, height * 0.1,
                            -width * 0.25, height * 0.6,
                            centerX, height
                        );
                        ctx.bezierCurveTo(
                            width * 1.25, height * 0.6,
                            width * 0.8, height * 0.1,
                            centerX, height * 0.35
                        );
                        ctx.closePath();
                        ctx.fill();
                    }
                }
                
                transform: [
                    Scale { 
                        xScale: animScale
                        yScale: animScale
                    },
                    Rotation {
                        angle: animRotation
                        origin.x: width/2
                        origin.y: height/2
                    },
                    Translate {
                        x: animXProgress * targetX
                        y: animYProgress * targetY
                    }
                ]
                
                opacity: animOpacity
                
                SequentialAnimation {
                    id: mainAnimation
                    running: false
                    
                    ParallelAnimation {
                        NumberAnimation {
                            target: heartContainer
                            property: "animScale"
                            from: 0.5
                            to: 1.0
                            duration: 500
                            easing.type: Easing.InOutQuad
                        }
                        
                        NumberAnimation {
                            target: heartContainer
                            property: "animRotation"
                            to: 0
                            duration: 500
                            easing.type: Easing.InOutQuad
                        }
                        
                        NumberAnimation {
                            target: heartContainer
                            property: "animOpacity"
                            from: 0
                            to: 1
                            duration: 500
                            easing.type: Easing.InOutQuad
                        }
                    }
                    
                    ParallelAnimation {
                        NumberAnimation {
                            target: heartContainer
                            property: "animScale"
                            from: 1.0
                            to: 1.5
                            duration: 500
                            easing.type: Easing.InOutQuad
                        }
                        
                        NumberAnimation {
                            target: heartContainer
                            property: "animOpacity"
                            from: 1
                            to: 0
                            duration: 500
                            easing.type: Easing.InOutQuad
                        }
                        
                        NumberAnimation {
                            target: heartContainer
                            property: "animXProgress"
                            from: 0
                            to: 1
                            duration: 500
                            easing.type: Easing.InOutQuad
                        }
                        
                        NumberAnimation {
                            target: heartContainer
                            property: "animYProgress"
                            from: 0
                            to: 1
                            duration: 500
                            easing.type: Easing.InOutQuad
                        }
                    }
                    
                    ScriptAction {
                        script: heartContainer.destroy()
                    }
                }
                
                function startAnimation() {
                    mainAnimation.start();
                }
                
                Component.onCompleted: {
                    heartCanvas.requestPaint();
                }
            }
        }
    }

    component IconButton : ToolButton {
        property alias iconSource: icon.source
        property alias iconWidth: icon.width
        property alias iconHeight: icon.height
        property color iconColor: secondaryText
        property color iconColorPressed: accentColor
        
        contentItem: Image {
            id: icon
            source: iconSource
            width: iconWidth
            height: iconHeight
            fillMode: Image.PreserveAspectFit
            layer.enabled: true
            layer.effect: ColorOverlay {
                color: parent.down ? iconColorPressed : iconColor
            }
        }
        background: Rectangle {
            color: "transparent"
        }
    }

    // Post Container
    Rectangle {
        id: postContainer
        anchors {
            fill: parent
            margins: 8
        }
        color: cardColor
        radius: 16
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 4
            radius: 16
            samples: 33
            color: "#20000000"
        }

        // Add double click handler for like animation
       MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onDoubleClicked: function(mouse) {
                var pos = mapToItem(root, mouse.x, mouse.y);
                likeAnimation.like(pos.x, pos.y);
                
                // Update like state and count
                if (!isLiked) {
                    isLiked = true;
                    currentLikes += 1;
                    // Syntax.likePost(modelData.postID);
                }
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: 0

            // Header
            RowLayout {
                width: parent.width - 24
                height: 72
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                // Avatar - Fixed image path
                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    width: 42
                    height: 42
                    radius: width / 2
                    color: "transparent"
                    border.width: 2
                    border.color: accentColor

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: width / 2
                        color: dividerColor
                        
                        Image {
                            anchors.fill: parent
                            source: "https://avatar.iran.liara.run/public?name=" + (modelData.pageTitle || "User")
                            fillMode: Image.PreserveAspectFit
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: 38
                                    height: 38
                                    radius: width / 2
                                }
                            }
                        }
                    }
                }

                // User Info
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Row {
                        spacing: 6
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            text: modelData.pageTitle || "Page Title"
                            font: Qt.font({
                                family: fontFamily,
                                weight: Font.Bold,
                                pixelSize: 15
                            })
                            color: primaryText
                        }

                        Image {
                            source: Qt.resolvedUrl("icons/verified.png")
                            width: 16
                            height: 16
                            visible: modelData.isVerified || true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Text {
                        text: "@" + (modelData.pageTitle ? modelData.pageTitle.replace(/\s+/g, '').toLowerCase() : "username")
                        font: Qt.font({
                            family: fontFamily,
                            weight: Font.Normal,
                            pixelSize: 13
                        })
                        color: secondaryText
                    }
                }

                // Follow Button - Handle undefined state
                Button {
                    Layout.alignment: Qt.AlignVCenter
                    text: (modelData.isFollowing || false) ? "Following" : "Follow"
                    font: Qt.font({
                        family: fontFamily,
                        weight: Font.DemiBold,
                        pixelSize: 13
                    })
                    
                    background: Rectangle {
                        radius: 8
                        color: (modelData.isFollowing || false) ? "transparent" : accentColor
                        border.color: (modelData.isFollowing || false) ? dividerColor : "transparent"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        color: (modelData.isFollowing || false) ? primaryText : "#000000"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        modelData.isFollowing = !modelData.isFollowing
                        Syntax.likePage(modelData.pageID)
                    }
                }
            }

            // Post Content - Fixed padding syntax
            Column {
                width: parent.width
                spacing: 12
                leftPadding: 12
                rightPadding: 12

                // Image - Ensure parent exists
                Rectangle {
                    width: column.width - 24
                    height: width
                    radius: 12
                    color: dividerColor
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: modelData.imagePath || ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: column.width
                                height: column.height
                                radius: 12
                            }
                        }
                    }
                }

                // Actions - Fixed icon dimensions
                Row {
                    width: parent.width
                    height: 40
                    spacing: 20

                    IconButton {
                        width: 32
                        height: 32
                        iconSource: isLiked ? "icons/heart-filled.png" : "icons/heart.png"
                        // iconColorPressed: "#FF375F"
                        iconWidth: 24
                        iconHeight: 24
                        onClicked: {
                            isLiked = !isLiked
                            currentLikes += isLiked ? 1 : -1
                        }
                    }

                    IconButton {
                        width: 32
                        height: 32
                        iconSource: "icons/comment.png"
                        iconWidth: 24
                        iconHeight: 24
                    }

                    IconButton {
                        width: 32
                        height: 32
                        iconSource: "icons/share.png"
                        iconWidth: 24
                        iconHeight: 24
                    }

                    Item { Layout.fillWidth: true }

                    IconButton {
                        width: 32
                        height: 32
                        iconSource: "icons/bookmark.png"
                        iconWidth: 24
                        iconHeight: 24
                    }
                }

                // Likes
             Text {
                text: currentLikes.toLocaleString() + " likes"
                font: Qt.font({
                    family: fontFamily,
                    weight: Font.Bold,
                    pixelSize: 14
                })
                color: isLiked ? "#FF375F" : primaryText // Change color if liked
            }

                // Caption
                Text {
                    width: parent.width
                    text: "<b>" + (modelData.pageTitle || "") + "</b> " + (modelData.description || "")
                    font: Qt.font({
                        family: fontFamily,
                        pixelSize: 14
                    })
                    color: primaryText
                    wrapMode: Text.Wrap
                    textFormat: Text.StyledText
                }

                // Comments Preview - Handle undefined
                Column {
                    width: parent.width
                    visible: (modelData.comments && modelData.comments.length > 0) || false
                    spacing: 6

                    Repeater {
                        model: modelData.comments ? modelData.comments.slice(0, 2) : []
                        
                        Row {
                            spacing: 8
                            
                            Text {
                                text: (modelData.username || "user") + ":"
                                font: Qt.font({
                                    family: fontFamily,
                                    weight: Font.Bold,
                                    pixelSize: 14
                                })
                                color: primaryText
                            }
                            
                            Text {
                                text: modelData.text || ""
                                font: Qt.font({
                                    family: fontFamily,
                                    pixelSize: 14
                                })
                                color: primaryText
                                wrapMode: Text.Wrap
                            }
                        }
                    }

                    Text {
                        text: "View all " + (modelData.comments ? modelData.comments.length : 0) + " comments"
                        color: secondaryText
                        font: Qt.font({
                            family: fontFamily,
                            pixelSize: 14
                        })
                        visible: false
                    }
                }

                // Date
                Text {
                    text: modelData.date ? new Date(modelData.date).toLocaleDateString(Qt.locale(), "MMMM d, yyyy") : ""
                    color: secondaryText
                    font: Qt.font({
                        family: fontFamily,
                        pixelSize: 12
                    })
                }
            }
        }
    }
}