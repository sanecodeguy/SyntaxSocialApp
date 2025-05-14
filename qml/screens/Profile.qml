import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import com.company 1.0
import com.rizzons.post 1.0
import com.rizzons.syntax 1.0
import QtQuick.Dialogs  // In Qt6, FileDialog is in main Dialogs import
import Qt5Compat.GraphicalEffects
Page {
    id: profilePage
    signal postAdded();
    // User data properties
    property var syntax: Syntax
    property var currentUser: Syntax
    property var pages: []
    property var currentPost: null
    property bool showPostDetail: false
    property bool isImageLoading: false
    // For new post creation
    property bool showNewPostDialog: false
    property string newPostContent: ""
    property string newPostImagePath: ""

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
        Syntax.loadPostsFromJson(Syntax.getCurrentUser());
        var pagesList = PageLoader.getPagesList();
   
        pages = pagesList;
    
        if (currentUser) {
            console.log("Profile loaded for:", currentUser.getUsername(), 
                       "Posts:", currentUser.getPostCount(),
                       "Friends:", currentUser.getFriendCount(),
                       "Likes:", currentUser.getLikedPagesCount());
        }
    }

 Connections {
    target: Syntax
    function onPostsLoaded() {
        console.log("Posts loaded/updated");
        // Force UI refresh
        profilePage.postAdded();
    }
}

    Component.onCompleted: {
        Syntax.loadPostsFromJson(Syntax.getCurrentUser());
        // Syntax.iterateJsonPosts();

        loadData();
        console.log("Profile loaded for:", Syntax.getUsername());
        // console.log("Post count:", Syntax.getPostCount());
        
        var posts = Syntax.getPosts();
        if (posts.length > 0) {
            var firstPost = posts[0];
            // console.log("First post ID:", firstPost.id);
            // console.log("First post description:", firstPost.description);
            // console.log("First post image path:", firstPost.imagePath);
            // console.log("First post likes:", firstPost.likesCount);
            // console.log("First post date:", firstPost.date);
        }
    }

    background: Rectangle { 
        color: backgroundColor 
    }

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
                }
                onClicked: {
                    if (showPostDetail) {
                        showPostDetail = false;
                    } else {
                        // Handle back navigation
                    }
                }
            }

            // Title
            Label {
                text: showPostDetail ? "Post" : "Profile"
                color: primaryText
                font {
                    pixelSize: 22
                    weight: Font.DemiBold
                    letterSpacing: 0.5
                }
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            // Settings button
            Button {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                flat: true
                visible: !showPostDetail
                background: Rectangle {
                    color: "transparent"
                    radius: width / 2
                }
                contentItem: Image {
                    source: "icons/search.png"
                    width: 24
                    height: 24
                }
            }

            Item {
                Layout.preferredWidth: 40
                visible: showPostDetail
            }
        }
    }

    Loader {
        anchors.fill: parent
        sourceComponent: showPostDetail ? postDetailComponent : profileComponent
    }

    Component {
        id: profileComponent
        Flickable {
            contentWidth: width
            contentHeight: mainContentColumn.height
            clip: true

            Column {
                id: mainContentColumn
                width: parent.width
                spacing: 0

                // Profile header section
                Column {
                    width: parent.width
                    spacing: 24
                    padding: 24

                    // Profile avatar with circular border
                    Rectangle {
                        width: 120
                        height: 120
                        radius: width/2
                        anchors.horizontalCenter: parent.horizontalCenter
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
                                text: currentUser ? currentUser.getUsername().charAt(0).toUpperCase() : ""
                                font {
                                    pixelSize: 48
                                    weight: Font.Bold
                                }
                                color: accentColor
                            }
                        }
                    }

                    // User info
                    Column {
                        width: parent.width
                        spacing: 8
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            text: currentUser ? currentUser.getUsername() : ""
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            font {
                                pixelSize: 24
                                weight: Font.Bold
                            }
                            color: primaryText
                        }

                        Text {
                            text: "UI/UX Designer"
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 14
                            color: accentColor
                        }

                        Text {
                            text: "This is my profile bio. I can edit this later."
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            font.pixelSize: 14
                            color: secondaryText
                            lineHeight: 1.4
                        }
                    }

                    // Stats with rounded containers
                    Row {
                        width: parent.width
                        height: 80
                        spacing: 16
                        anchors.horizontalCenter: parent.horizontalCenter

                        Repeater {
                            model: [
                                { count: currentUser ? currentUser.getPostCount() : 0, label: "Posts" },
                                { count: currentUser ? currentUser.getFriendCount() : 0, label: "Friends" },
                                { count: currentUser ? currentUser.getLikedPagesCount() : 0, label: "Likes" }
                            ]
                            delegate: Rectangle {
                                width: (parent.width - parent.spacing * 2) / 3
                                height: parent.height
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
                                        }
                                        color: secondaryText
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }
                    }

                    // Action buttons
                    Row {
                        width: parent.width
                        height: 48
                        spacing: 16
                        anchors.horizontalCenter: parent.horizontalCenter

                        Button {
                            width: (parent.width - parent.spacing) / 2
                            height: parent.height
                            text: "Edit Profile"
                            font {
                                pixelSize: 14
                                weight: Font.Medium
                            }
                            flat: true
                            background: Rectangle {
                                color: "transparent"
                                border.width: 1
                                border.color: dividerColor
                                radius: height/2
                            }
                            contentItem: Text {
                                text: parent.text
                                color: primaryText
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            width: (parent.width - parent.spacing) / 2
                            height: parent.height
                            text: "New Post"
                            font {
                                pixelSize: 14
                                weight: Font.Medium
                            }
                            onClicked: showNewPostDialog = true
                            background: Rectangle {
                                color: accentColor
                                radius: height/2
                            }
                            contentItem: Text {
                                text: parent.text
                                color: backgroundColor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
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
                            model: ["Posts", "Friends", "Activity"]
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
                                        // Tab switching logic would go here
                                    }
                                }
                            }
                        }
                    }
                }

                // Posts grid with rounded corners
                GridView {
                    width: parent.width
                    height: currentUser ? Math.ceil(currentUser.getPostCount() / 3) * (width / 3) : 0
                    cellWidth: width / 3
                    cellHeight: cellWidth
                    model: currentUser ? currentUser.getPosts() : []
                    interactive: false
                    clip: true

                    delegate: Item {
                        width: GridView.view.cellWidth
                        height: GridView.view.cellHeight

                        Rectangle {
                            anchors {
                                fill: parent
                                margins: 1
                            }
                            radius: 4
                            color: cardColor
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: modelData.imagePath || ""
                                fillMode: Image.PreserveAspectCrop
                                layer.enabled: true
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
                                    }

                                    Text {
                                        id: likeLabel
                                        text: modelData && modelData.likesCount ? modelData.likesCount.toLocaleString() : "0"
                                        color: "white"
                                        font.pixelSize: 12
                                        font.weight: Font.DemiBold
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    currentPost = modelData;
                                    showPostDetail = true;
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
                                source: "icons/search.png"
                                width: 64
                                height: 64
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            
                            Text {
                                text: "No posts yet"
                                color: accentColor
                                font.pixelSize: 16
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            
                            Text {
                                text: "Create your first post"
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

    Component {
        id: postDetailComponent
        Flickable {
            width: parent.width
            height: parent.height
            contentWidth: width
            contentHeight: postColumn.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: postColumn
                width: parent.width
                spacing: 0

                // Post Container
                Rectangle {
                    width: parent.width
                    height: postContentColumn.height + 40
                    color: backgroundColor

                    Column {
                        id: postContentColumn
                        width: parent.width - 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 0

                        // Header
                        RowLayout {
                            width: parent.width
                            height: 72
                            spacing: 12

                            // Avatar
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
                                        source: "https://avatar.iran.liara.run/public?name=" + (currentUser ? currentUser.getUsername() : "User")
                                        fillMode: Image.PreserveAspectFit
                                        layer.enabled: true

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
                                        text: currentUser ? currentUser.getUsername() : "User"
                                        font: Qt.font({
                                            family: "Helvetica Neue",
                                            weight: Font.Bold,
                                            pixelSize: 15
                                        })
                                        color: primaryText
                                    }

                                    Image {
                                        source: "icons/verified.png"
                                        width: 16
                                        height: 16
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Text {
                                    text: currentUser ? "@" + currentUser.getUsername().toLowerCase() : "@username"
                                    font: Qt.font({
                                        family: "Helvetica Neue",
                                        weight: Font.Normal,
                                        pixelSize: 13
                                    })
                                    color: secondaryText
                                }
                            }

                            // More options button
                            IconButton {
                                Layout.alignment: Qt.AlignVCenter
                                width: 32
                                height: 32
                                iconSource: "icons/more.png"
                                iconWidth: 24
                                iconHeight: 24
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
                                width: parent.width - 24
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
                                text: (currentUser ? "<b>" + currentUser.getUsername() + "</b> " : "") + (currentPost ? currentPost.description : "")
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
                                spacing: 6
                                visible: currentPost && currentPost.commentsCount > 0

                                Text {
                                    text: "View all " + (currentPost ? currentPost.commentsCount : 0) + " comments"
                                    color: secondaryText
                                    font: Qt.font({
                                        family: "Helvetica Neue",
                                        pixelSize: 14
                                    })
                                }
                            }

                            // Date
                            Text {
                                text: currentPost ? new Date(currentPost.date).toLocaleDateString(Qt.locale(), "MMMM d, yyyy") : ""
                                color: secondaryText
                                font: Qt.font({
                                    family: "Helvetica Neue",
                                    pixelSize: 12
                                })
                            }
                        }
                    }
                }

                // Comments section
                Rectangle {
                    width: parent.width
                    height: 300
                    color: cardColor
                    radius: 16
                    visible: currentPost && currentPost.commentsCount > 0

                    Column {
                        width: parent.width - 24
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 16
                        padding: 16

                        Text {
                            text: "Comments"
                            font: Qt.font({
                                family: "Helvetica Neue",
                                weight: Font.Bold,
                                pixelSize: 16
                            })
                            color: primaryText
                        }

                        // Comment input
                        RowLayout {
                            width: parent.width
                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                radius: width / 2
                                color: dividerColor

                                Image {
                                    anchors.fill: parent
                                    source: "https://avatar.iran.liara.run/public?name=" + (currentUser ? currentUser.getUsername() : "User")
                                    fillMode: Image.PreserveAspectFit
                                    layer.enabled: true
                                }
                            }

                            TextField {
                                Layout.fillWidth: true
                                placeholderText: "Add a comment..."
                                placeholderTextColor: secondaryText
                                color: primaryText
                                font: Qt.font({
                                    family: "Helvetica Neue",
                                    pixelSize: 14
                                })
                                background: Rectangle {
                                    color: "transparent"
                                    border.width: 0
                                }
                            }

                            Button {
                                text: "Post"
                                font: Qt.font({
                                    family: "Helvetica Neue",
                                    weight: Font.Bold,
                                    pixelSize: 14
                                })
                                flat: true
                                contentItem: Text {
                                    text: parent.text
                                    color: accentColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    color: "transparent"
                                }
                            }
                        }

                        // Comments list
                        ListView {
                            width: parent.width
                            height: 200
                            model: currentPost ? currentPost.commentsCount : 0
                            clip: true
                            spacing: 16

                            delegate: Row {
                                width: parent.width
                                spacing: 12

                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: width / 2
                                    color: dividerColor

                                    Image {
                                        anchors.fill: parent
                                        source: "https://avatar.iran.liara.run/public?name=User" + index
                                        fillMode: Image.PreserveAspectFit
                                        layer.enabled: true

                                    }
                                }

                                Column {
                                    width: parent.width - 52
                                    spacing: 4

                                    Text {
                                        text: "Username " + (index + 1)
                                        font: Qt.font({
                                            family: "Helvetica Neue",
                                            weight: Font.Bold,
                                            pixelSize: 14
                                        })
                                        color: primaryText
                                    }

                                    Text {
                                        text: "This is a sample comment for demonstration purposes."
                                        font: Qt.font({
                                            family: "Helvetica Neue",
                                            pixelSize: 14
                                        })
                                        color: primaryText
                                        width: parent.width
                                        wrapMode: Text.Wrap
                                    }

                                    Text {
                                        text: "2d ago"
                                        font: Qt.font({
                                            family: "Helvetica Neue",
                                            pixelSize: 12
                                        })
                                        color: secondaryText
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
onPostAdded: {
    // This will automatically refresh the posts display
    console.log("New post added, refreshing view...");
}
    // Rounded New Post Dialog
Popup {
    id: newPostDialog
    width: Math.min(parent.width * 0.9, 500)
    height: Math.min(parent.height * 0.8, dialogContentColumn.height + 40)
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    visible: showNewPostDialog

    property string newPostImagePath: ""
    property bool isImageLoading: false

    onClosed: {
        postContent.text = ""
        newPostImagePath = ""
    }

    background: Rectangle {
        color: cardColor
        radius: 16
        border.color: dividerColor
        border.width: 1
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 16
            samples: 32
            color: "#80000000"
        }
    }

    Column {
        id: dialogContentColumn
        width: parent.width
        spacing: 16
        padding: 20

        Text {
            text: "Create New Post"
            font {
                pixelSize: 20
                weight: Font.Bold
            }
            color: accentColor
            anchors.horizontalCenter: parent.horizontalCenter
            bottomPadding: 8
        }

        // Post content section
        Column {
            width: parent.width
            spacing: 8

            Label {
                text: "Post Content"
                font.pixelSize: 14
                color: secondaryText
            }

            TextArea {
                id: postContent
                width: parent.width
                height: 120
                placeholderText: "What's on your mind?"
                placeholderTextColor: secondaryText
                wrapMode: TextArea.Wrap
                font.pixelSize: 14
                color: primaryText
                background: Rectangle {
                    color: "transparent"
                    border.width: 1
                    border.color: dividerColor
                    radius: 8
                }
            }
        }

        // Image section
        Column {
            width: parent.width
            spacing: 8
            visible: true // Always show image section

            Label {
                text: "Image Attachment"
                font.pixelSize: 14
                color: secondaryText
                visible: true
            }

            // Image preview
            Rectangle {
                width: parent.width
                height: newPostImagePath ? 200 : 0
                visible: newPostImagePath
                color: "#2E2E2E"
                radius: 8
                
                BusyIndicator {
                    anchors.centerIn: parent
                    running: isImageLoading
                    visible: isImageLoading
                }
                
                Image {
                    anchors.fill: parent
                    anchors.margins: 4
                    source: newPostImagePath
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    onStatusChanged: {
                        if (status === Image.Loading) {
                            isImageLoading = true
                        } else if (status === Image.Ready) {
                            isImageLoading = false
                        } else if (status === Image.Error) {
                            isImageLoading = false
                            console.error("Failed to load image:", newPostImagePath)
                            newPostImagePath = ""
                        }
                    }
                }
                
                RoundButton {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 8
                    width: 32
                    height: 32
                    radius: 16
                    onClicked: {
                        newPostImagePath = ""
                    }
                    
                    background: Rectangle {
                        color: "#99000000"
                        radius: width / 2
                    }
                    
                    contentItem: Text {
                        text: "×"
                        color: "white"
                        font.pixelSize: 18
                        anchors.centerIn: parent
                    }
                }
            }

            // Image selection controls
            Row {
                id: imageSelection
                width: parent.width
                spacing: 8
                visible: !newPostImagePath

                Button {
                    id: browseButton
                    text: "Browse..."
                    width: parent.width
                    height: 40
                    onClicked: fileDialog.open()
                    background: Rectangle {
                        color: "transparent"
                        border.width: 1
                        border.color: dividerColor
                        radius: height/2
                    }
                    contentItem: Text {
                        text: parent.text
                        color: accentColor
                        font {
                            pixelSize: 14
                            weight: Font.Medium
                        }
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        // Action buttons
        Row {
            spacing: 12
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: 8

            Button {
                text: "Cancel"
                width: 120
                height: 48
                flat: true
                onClicked: {
                    showNewPostDialog = false
                }
                background: Rectangle {
                    color: "transparent"
                    border.width: 1
                    border.color: dividerColor
                    radius: height/2
                }
                contentItem: Text {
                    text: parent.text
                    color: primaryText
                    font {
                        pixelSize: 14
                        weight: Font.Medium
                    }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                text: "Post"
                width: 120
                height: 48
                enabled: (postContent.text.trim() !== "") || (newPostImagePath !== "")
                onClicked: {
                    var postData = {
                        content: postContent.text,
                        imagePath: newPostImagePath
                    }
                    Syntax.createPost(postContent.text, newPostImagePath);
                    // console.log("Creating post:", JSON.stringify(postData))
                    
                    
                    showNewPostDialog = false
                }
                background: Rectangle {
                    color: enabled ? accentColor : Qt.darker(accentColor, 1.5)
                    radius: height/2
                    opacity: enabled ? 1 : 0.6
                }
                contentItem: Text {
                    text: parent.text
                    color: backgroundColor
                    font {
                        pixelSize: 14
                        weight: Font.Medium
                    }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Select an image"
        nameFilters: ["Image files (*.png *.jpg *.jpeg)"]
        onAccepted: {
            newPostImagePath = selectedFile.toString()
            console.log("Selected image:", newPostImagePath)
        }
        onRejected: {
            console.log("Image selection canceled")
        }
    }
}
    component IconButton : ToolButton {
        property alias iconSource: icon.source
        property alias iconWidth: icon.width
        property alias iconHeight: icon.height
        property color iconColor: "#BBBAB9"  // secondaryText
        property color iconColorPressed: "#FEC347" // accentColor
        
        implicitWidth: 32
        implicitHeight: 32
        
        contentItem: Image {
            id: icon
            source: iconSource
            width: Math.min(iconWidth, 24)
            height: Math.min(iconHeight, 24)
            anchors.centerIn: parent
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