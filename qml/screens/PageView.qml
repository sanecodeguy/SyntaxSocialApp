import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import com.rizzons.syntax 1.0
import com.company 1.0
import Qt5Compat.GraphicalEffects

Page {
    id: pageView
    property var pageData: ({})
    signal leavingpage()

    property var posts: PageLoader.getPagePostsList(pageData.pageID) || []
    property bool following: pageData.isFollowing || false
    property var currentPost: null
    property bool showPostDetail: false

    // Premium color palette
    readonly property color backgroundColor: "#111111"
    readonly property color cardColor: "#1E1E1E"
    readonly property color primaryText: "#FFFFFF"
    readonly property color secondaryText: "#BBBAB9"
    readonly property color accentColor: "#FEC347"
    readonly property color dividerColor: "#2E2E2E"

    

    function loadData() {
        if (PageLoader.getPageCount() === 0) {
            console.log("Initial data load...");
            PageLoader.loadFromJson("qrc:/assets/data/AllPages.json");
        }
        Syntax.loadLikedPages();
        
        var pagesList = PageLoader.getPagesList();
        for (var i = 0; i < pagesList.length; i++) {
            if (pagesList[i]) {
                pagesList[i].isFollowing = Syntax.hasLikedPage(pagesList[i].pageID);
            }
        }
        pages = pagesList;
    }

    background: Rectangle { color: backgroundColor }

    // Header with back button
    header: ToolBar {
        contentHeight: 72
        background: Rectangle { 
            color: backgroundColor
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: dividerColor
            }
        }

        RowLayout {
            anchors.fill: parent
            spacing: 16
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            // Back button
            Button {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                flat: true
                background: Rectangle {
                    color: "transparent"
                    radius: width / 2
                }
                contentItem: Image {
                    source: "icons/back.png"
                    width: 24
                    height: 24
                    layer.enabled: true
                    layer.effect: ColorOverlay {
                        color: primaryText
                    }
                }
                onClicked: {
                    if (showPostDetail) {
                        showPostDetail = false
                    } else {
                        stack.pop()
                    }
                }
            }

            // Page title - Centered
            Label {
                text: showPostDetail ? "POST" : (pageData.title || "").toUpperCase()
                color: primaryText
                font {
                    pixelSize: 18
                    weight: Font.DemiBold
                    letterSpacing: 1
                }
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Item { 
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
            }
        }
    }

    // Main content when not showing post detail
    Loader {
        anchors.fill: parent
        sourceComponent: showPostDetail ? postDetailComponent : profileComponent
    }

    // Profile component
    Component {
        id: profileComponent
        Flickable {
            contentWidth: width
            contentHeight: contentColumn.height
            clip: true

            Column {
                id: contentColumn
                width: parent.width
                spacing: 0

                // Profile section
                Column {
                    width: parent.width
                    spacing: 24
                    padding: 24

                    Row {
                        width: parent.width
                        spacing: 32

                        // Profile image with accent border
                        Rectangle {
                            width: 120
                            height: 120
                            radius: width/2
                            color: "transparent"
                            border.width: 3
                            border.color: accentColor

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 3
                                radius: width/2
                                color: cardColor

                                Text {
                                    anchors.centerIn: parent
                                    text: pageData.title ? pageData.title.charAt(0).toUpperCase() : ""
                                    font {
                                        pixelSize: 48
                                        weight: Font.Bold
                                    }
                                    color: accentColor
                                }
                            }
                        }

                        // Stats - Using rounded containers
                        Row {
                            height: 120
                            spacing: 16
                            layoutDirection: Qt.RightToLeft

                            Repeater {
                                model: [
                                    { count: posts.length, label: "POSTS" },
                                    { count: PageLoader.returnlikescount(pageData.pageID) || 0, label: "LIKES" }
                                ]
                                delegate: Rectangle {
                                    width: 80
                                    height: 80
                                    radius: 12
                                    color: cardColor

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 4

                                        Text {
                                            text: modelData.count.toLocaleString()
                                            font {
                                                pixelSize: 20
                                                weight: Font.Bold
                                            }
                                            color: accentColor
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        Text {
                                            text: modelData.label
                                            font {
                                                pixelSize: 12
                                                letterSpacing: 1
                                            }
                                            color: secondaryText
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Bio - All text centered
                    Column {
                        width: parent.width
                        spacing: 12
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            text: pageData.title || ""
                            width: parent.width
                            font {
                                pixelSize: 22
                                weight: Font.Bold
                            }
                            color: primaryText
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            text: pageData.category || "Official Page"
                            width: parent.width
                            font.pixelSize: 14
                            color: accentColor
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            text: pageData.description || "Welcome to our official page!"
                            width: parent.width
                            wrapMode: Text.Wrap
                            font.pixelSize: 14
                            color: secondaryText
                            lineHeight: 1.4
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    // Follow button
                    Button {
                        width: parent.width * 0.7
                        height: 48
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: following ? "FOLLOWING" : "FOLLOW"
                        font {
                            pixelSize: 14
                            letterSpacing: 1
                            weight: Font.Bold
                        }
                        onClicked: {
                            following = !following
                            pageData.isFollowing = following
                            Syntax.likePage(pageData.pageID)
                            Syntax.saveLikedPagesToFile()
                        }
                        background: Rectangle {
                            color: following ? "transparent" : accentColor
                            border.width: following ? 1 : 0
                            border.color: dividerColor
                            radius: height/2
                        }
                        contentItem: Text {
                            text: parent.text
                            color: following ? primaryText : backgroundColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                // Tabs with rounded indicators
                Rectangle {
                    width: parent.width
                    height: 60
                    color: backgroundColor

                    Row {
                        width: parent.width - 32
                        height: parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 0

                        Repeater {
                            model: ["POSTS", "REELS", "TAGGED"]
                            delegate: Item {
                                width: parent.width / 3
                                height: parent.height

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 8

                                    Text {
                                        text: modelData
                                        font {
                                            pixelSize: 14
                                            weight: index === 0 ? Font.Bold : Font.Normal
                                            letterSpacing: 1
                                        }
                                        color: index === 0 ? accentColor : secondaryText
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    Rectangle {
                                        width: 24
                                        height: 3
                                        radius: 2
                                        color: index === 0 ? accentColor : "transparent"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        // Tab switching logic
                                    }
                                }
                            }
                        }
                    }
                }

                // Posts grid with visible previews
// Posts grid - Updated to match home screen style
GridView {
    width: parent.width
    height: posts.length > 0 ? Math.ceil(posts.length / 3) * (width / 3) : 0
    cellWidth: width / 3
    cellHeight: cellWidth
    model: posts
    interactive: false
    clip: true

    delegate: Item {
        width: GridView.view.cellWidth
        height: GridView.view.cellHeight

        // Post Container
        Rectangle {
            anchors {
                fill: parent
                margins: 1
            }
            color: cardColor
            radius: 4
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 2
                radius: 8
                samples: 17
                color: "#20000000"
            }

            // Post image
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: dividerColor
                clip: true

                Image {
                    anchors.fill: parent
                    source: modelData.imagePath || ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    layer.enabled: true
                }
            }

            // Like overlay for popular posts
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.margins: 8
                width: likeLabel.width + 16
                height: 24
                radius: height/2
                color: "#cc000000"
                visible: modelData.likesCount > 0

                Row {
                    anchors.centerIn: parent
                    spacing: 4

                    Image {
                        source: "icons/heart.png"
                        width: 14
                        height: 14
                        anchors.verticalCenter: parent.verticalCenter
                        layer.enabled: true
                        layer.effect: ColorOverlay {
                            color: "white"
                        }
                    }

                    Text {
                        id: likeLabel
                        text: modelData.likesCount.toLocaleString()
                        color: "white"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    currentPost = modelData
                    showPostDetail = true
                }
            }
        }
    }

    // Empty state
    Rectangle {
        width: parent.width
        height: 200
        color: "transparent"
        visible: false
        
        Column {
            anchors.centerIn: parent
            spacing: 16
            
            Image {
                source: "icons/post.png"
                width: 64
                height: 64
                anchors.horizontalCenter: parent.horizontalCenter
                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: secondaryText
                }
            }
            
            Text {
                text: "No posts yet"
                color: accentColor
                font.pixelSize: 16
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Text {
                text: "Check back later for updates"
                color: secondaryText
                font.pixelSize: 14
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
            }
        }
    }

    Component.onCompleted: {
        if (!PageLoader.isInitialized()) {
            PageLoader.loadFromJson("qrc:/assets/data/AllPages.json");
        }
        loadData();
    }

    Connections {
        target: Syntax
        function onLikedPagesChanged() {
            Syntax.loadLikedPages();
            // Refresh follow states when likes change
            for (var i = 0; i < discoverPage.pages.length; i++) {
                var page = discoverPage.pages[i];
                if (page) {
                    page.isFollowing = Syntax.hasLikedPage(page.pageID);
                }
            }
        }
    }

    // Post detail component
 Component {
    id: postDetailComponent
    Item {
        width: parent.width
        height: parent.height

        // Post Container
        Rectangle {
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

            Flickable {
                width: parent.width
                height: parent.height
                contentWidth: width
                contentHeight: column.implicitHeight + 40
                clip: true

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

                        // Back button
                        Button {
                            Layout.alignment: Qt.AlignVCenter
                            width: 40
                            height: 40
                            flat: true
                            onClicked: showPostDetail = false
                            background: Rectangle {
                                color: "transparent"
                                radius: width / 2
                            }
                            contentItem: Image {
                                source: "icons/back.png"
                                width: 24
                                height: 24
                                layer.enabled: true
                                layer.effect: ColorOverlay {
                                    color: primaryText
                                }
                            }
                        }

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
                                    source: "https://avatar.iran.liara.run/public?name=" + (currentPost.pageTitle || "User")
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
                                    text: currentPost ? pageData.title || "Page Title" : "Page Title"
                                    font: Qt.font({
                                        family: "Helvetica Neue",
                                        weight: Font.Bold,
                                        pixelSize: 15
                                    })
                                    color: primaryText
                                }

                                Image {
                                    source: Qt.resolvedUrl("icons/verified.png")
                                    width: 16
                                    height: 16
                                    visible: true // Always show verified in detail view
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Text {
                                text: "@" + (currentPost ? currentPost.pageTitle.replace(/\s+/g, '').toLowerCase() : "username")
                                font: Qt.font({
                                    family: "Helvetica Neue",
                                    weight: Font.Normal,
                                    pixelSize: 13
                                })
                                color: secondaryText
                            }
                        }

                    }

                    // Post Content
                    Column {
                        width: parent.width
                        spacing: 12
                        leftPadding: 12
                        rightPadding: 12

                        // Image
                        Rectangle {
                            width: column.width - 24
                            height: width
                            radius: 12
                            color: dividerColor
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: currentPost ? currentPost.imagePath : ""
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

                        // Actions
                        Row {
                            width: parent.width
                            height: 40
                            spacing: 20

                            IconButton {
                                width: 32
                                height: 32
                                iconSource: "icons/heart.png"
                                iconColorPressed: "#FF375F"
                                iconWidth: 24
                                iconHeight: 24
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
                            text: (currentPost ? currentPost.likesCount : 0).toLocaleString() + " likes"
                            font: Qt.font({
                                family: "Helvetica Neue",
                                weight: Font.Bold,
                                pixelSize: 14
                            })
                            color: primaryText
                        }

                        // Caption
                        Text {
                            width: parent.width
                            text: "<b>" + (currentPost ? currentPost.pageTitle : "") + "</b> " + (currentPost ? currentPost.description : "")
                            font: Qt.font({
                                family: "Helvetica Neue",
                                pixelSize: 14
                            })
                            color: primaryText
                            wrapMode: Text.Wrap
                            textFormat: Text.StyledText
                        }
                        // Comments Preview
                        Column {
                            width: parent.width
                            visible: currentPost && currentPost.comments && currentPost.comments.length > 0
                            spacing: 6

                            Repeater {
                                model: currentPost && currentPost.comments ? currentPost.comments.slice(0, 2) : []
                                
                                Row {
                                    spacing: 8
                                    
                                    Text {
                                        text: (modelData.username || "user") + ":"
                                        font: Qt.font({
                                            family: "Helvetica Neue",
                                            weight: Font.Bold,
                                            pixelSize: 14
                                        })
                                        color: primaryText
                                    }
                                    
                                    Text {
                                        text: modelData.text || ""
                                        font: Qt.font({
                                            family: "Helvetica Neue",
                                            pixelSize: 14
                                        })
                                        color: primaryText
                                        wrapMode: Text.Wrap
                                    }
                                }
                            }

                            Text {
                                text: "View all " + (currentPost && currentPost.comments ? currentPost.comments.length : 0) + " comments"
                                color: secondaryText
                                font: Qt.font({
                                    family: "Helvetica Neue",
                                    pixelSize: 14
                                })
                            }
                        }

                        // Date
                        Text {
                            text: currentPost && currentPost.date ? new Date(currentPost.date).toLocaleDateString(Qt.locale(), "MMMM d, yyyy") : ""
                            color: secondaryText
                            font: Qt.font({
                                family: "Helvetica Neue",
                                pixelSize: 12
                            })
                        }
                    }
                }
            }
        }
    }
}
component IconButton : ToolButton {
    property alias iconSource: icon.source
    property alias iconWidth: icon.width
    property alias iconHeight: icon.height
    property color iconColor: "#BBBAB9"  // secondaryText
    property color iconColorPressed: "#FEC347" // accentColor
    
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
}