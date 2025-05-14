import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import com.company 1.0
import "../ExpandableBottomBar" 
import com.rizzons.post 1.0
import com.rizzons.syntax 1.0
import Qt5Compat.GraphicalEffects

Page {
    id: discoverPage

    property var pages: []

    // Premium color palette
    readonly property color backgroundColor: "#111111"  // Chinese Black
    readonly property color cardColor: "#1E1E1E"       // Dark card
    readonly property color primaryText: "#FFFFFF"      // White
    readonly property color secondaryText: "#BBBAB9"    // Gray (X11)
    readonly property color accentColor: "#FEC347"      // Maine (Crayola) - primary accent
    readonly property color dividerColor: "#2E2E2E"     // Dark divider

    function loadData() {
        if (PageLoader.getPageCount() === 0) {
            console.log("Initial data load...");
            PageLoader.loadFromJson("qrc:/assets/data/AllPages.json");
        }
        Syntax.loadLikedPages();
        var pagesList = PageLoader.getPagesList();
        for (var i = 0; i < pagesList.length; i++) {
            if (pagesList[i])
                pagesList[i].isFollowing = Syntax.hasLikedPage(pagesList[i].pageID);
        }
        pages = pagesList;
    }

    Connections {
        target: Syntax
        function onLikedPagesChanged() {
            Syntax.loadLikedPages();
        }
    }

    Component.onCompleted: {
        console.log("Discover component completed");
        loadData();
    }

    // Dark background
    Rectangle {
        anchors.fill: parent
        color: backgroundColor
    }

    // Premium header with accent
    Rectangle {
        id: header
        width: parent.width
        height: 72
        color: backgroundColor
        z: 2

        RowLayout {
            anchors.fill: parent
            spacing: 16
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            // Premium back button
            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: width / 2
                color: backMouseArea.containsMouse ? "#2E2E2E" : "transparent"
                
                Image {
                    source: "icons/back.png"
                    width: 24
                    height: 24
                    anchors.centerIn: parent
                }
                
                
                MouseArea {
                    id: backMouseArea
                    anchors.fill: parent
                    onClicked: stack.pop()
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }

            // Premium title
            Label {
                text: "Discover"
                color: accentColor
                font {
                    pixelSize: 22
                    weight: Font.DemiBold
                    letterSpacing: 0.5
                }
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            // Balance layout
            Item { Layout.preferredWidth: 40 }
        }

        // Divider line
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: dividerColor
        }
    }

    ListView {
        id: pagesList
        clip: true
        model: discoverPage.pages
        spacing: 0

        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        section {
            property: "section"
            delegate: Rectangle {
                width: parent.width
                height: 54
                color: backgroundColor

                Text {
                    text: "Suggested For You"
                    color: accentColor
                    anchors {
                        left: parent.left
                        leftMargin: 24
                        verticalCenter: parent.verticalCenter
                    }
                    font {
                        pixelSize: 14
                        weight: Font.DemiBold
                        letterSpacing: 0.3
                    }
                }
            }
        }

        delegate: Rectangle {
            width: discoverPage.width
            height: 76
            color: cardColor

            Row {
                spacing: 16
                anchors {
                    fill: parent
                    margins: 16
                    leftMargin: 24
                }

                // Premium profile avatar
                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: "#333333"
                    border.width: 1
                    border.color: dividerColor

                    Text {
                        anchors.centerIn: parent
                        text: modelData.title.charAt(0).toUpperCase()
                        color: accentColor
                        font {
                            pixelSize: 18
                            weight: Font.DemiBold
                        }
                    }
                }

                // Page info
                MouseArea {
                    width: parent.width - 44 - 16 - 88
                    height: parent.height
                    onClicked: {
                        console.log("Opening Page:", modelData.pageID);
                        var component = Qt.createComponent("PageView.qml");
                        if (component.status === Component.Ready) {
                            stack.push(component, {
                                "pageData": modelData
                            });
                        } else {
                            console.error("Component error:", component.errorString());
                        }
                    }

                    Column {
                        width: parent.width
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        Row {
                            width: parent.width
                            spacing: 6
                            Text {
                                text: modelData.title
                                color: primaryText
                                font {
                                    pixelSize: 15
                                    weight: Font.Medium
                                    letterSpacing: 0.3
                                }
                                elide: Text.ElideRight
                            }

                            Image {
                                source: "icons/verified.png"
                                width: 16
                                height: 16
                                anchors.verticalCenter: parent.verticalCenter
                                visible: true
                            }
                        }

                        Text {
                            text: modelData.likesCount.toLocaleString() + " LIKES • " + 
                                  modelData.postCount + (modelData.postCount === 1 ? " POST" : " POSTS")
                            font.pixelSize: 12
                            color: secondaryText
                        }
                    }
                }

                // Premium follow button
                Button {
                    id: followButton
                    property bool isFollowing: false
                    width: 88
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter
                    Component.onCompleted: isFollowing = modelData.isFollowing
                    
                    onClicked: {
                        scale = 0.95;
                        followAnim.start();
                        isFollowing = !isFollowing;
                        modelData.isFollowing = isFollowing;
                        Syntax.likePage(modelData.pageID);
                        // Force immediate update in HomeScreen if it's in the stack
                        for (var i = 0; i < stack.depth; i++) {
                            var item = stack.get(i);
                            if (item && item.hasOwnProperty("loadContent"))
                                item.loadContent();
                        }
                    }

                    states: [
                        State {
                            name: "FOLLOWING"
                            when: followButton.isFollowing
                            PropertyChanges {
                                target: followButton
                                text: "Following"
                                background.color: "transparent"
                                background.border.color: secondaryText
                                contentItem.color: primaryText
                            }
                        },
                        State {
                            name: "FOLLOW"
                            when: !followButton.isFollowing
                            PropertyChanges {
                                target: followButton
                                text: "Follow"
                                background.color: accentColor
                                background.border.color: "transparent"
                                contentItem.color: "#111111"
                            }
                        }
                    ]

                    SequentialAnimation {
                        id: followAnim
                        NumberAnimation {
                            target: followButton
                            property: "scale"
                            to: 0.95
                            duration: 50
                        }
                        NumberAnimation {
                            target: followButton
                            property: "scale"
                            to: 1
                            duration: 150
                            easing.type: Easing.OutBack
                        }
                    }

                    transitions: Transition {
                        ColorAnimation {
                            properties: "color,border.color,contentItem.color"
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }

                    background: Rectangle {
                        radius: 6
                        border.width: 1
                    }

                    contentItem: Text {
                        text: followButton.text
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font {
                            pixelSize: 13
                            weight: Font.DemiBold
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: dividerColor
                visible: index !== discoverPage.pages.length - 1
            }
        }

        // Empty state
        Item {
            width: parent.width
            height: 300
            visible: pagesList.count === 0
            
            Column {
                anchors.centerIn: parent
                spacing: 16
                
                Rectangle {
                    width: 80
                    height: 80
                    radius: width / 2
                    color: cardColor
                    anchors.horizontalCenter: parent.horizontalCenter
                    border.color: accentColor
                    border.width: 2
                    
                    Text {
                        text: "🔍"
                        anchors.centerIn: parent
                        font.pixelSize: 32
                    }
                }
                
                Text {
                    text: "No pages found"
                    color: accentColor
                    font {
                        pixelSize: 18
                        weight: Font.DemiBold
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "Discover pages to follow"
                    color: secondaryText
                    font.pixelSize: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}