import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import com.rizzons.syntax 1.0
import com.company 1.0
import "../ExpandableBottomBar"

Page {
    id: homeScreen
    
    // Premium color palette
    readonly property color backgroundColor: "#000000"       // Pure Black  
    readonly property color cardColor: "#121212"            // Elevated Black  
    readonly property color primaryText: "#FFFFFF"          // Pure White  
    readonly property color secondaryText: "#AAAAAA"        // Light Gray  
    readonly property color accentColor: "#FEC347"          // Unchanged (pops harder on dark)  
    readonly property color dividerColor: "#333333"         // Deep Gray  
    // Font properties (add with your color properties)
    readonly property int fontBoldWeight: Font.Bold
    readonly property int fontExtraBoldWeight: Font.ExtraBold
    readonly property int fontBlackWeight: Font.Black // Maximum boldness
    background: Rectangle { color: backgroundColor }
    property color primaryTextColor: primaryText
    // Typography scale
    readonly property string fontFamily: "Neue Haas Grotesk" // Sexy Helvetica successor
    readonly property int displaySize: 32  // For main titles
    readonly property int titleSize: 24    // Section headers
    readonly property int headlineSize: 18  // Card titles
    readonly property int bodySize: 14      // Primary text
    readonly property int captionSize: 12   // Secondary text
    
    // Transient properties (cleared when navigating away)
    property int friendCount: 0
    property var likedPages: []
    property var posts: []
    property var pages: []
    property var friendPosts:[]
    property bool hasContent: false
    property Component discoverComponent: Discover {}
    property Component friendsComponent: Friends{}

    // Persistent navigation properties
    property int currentIndex: 0
    property var navigationModel: [
        { icon: "icons/home.png", text: "", selected: true },
        { icon: "icons/search.png", text: "", selected: false },
        { icon: "icons/add.png", text: "", selected: false },
        { icon: "icons/heart.png", text: "", selected: false },
        { icon: "icons/profile.png", text: "", selected: false }
    ]

    // StackView attachment for navigation detection
    property StackView attachedStack: StackView.view

    // Initialize core data (called once)
    function initializeCoreData() {
        if (PageLoader.getPageCount() === 0) {
            console.log("Loading core page data...");
            PageLoader.loadFromJson("qrc:/assets/data/AllPages.json");
        }
        Syntax.loadLikedPages();
    }
function loadCompleteData() {
    console.log("Loading complete home screen data");
    
    // Reset properties
    friendCount = 0;
    likedPages = [];
    posts = [];
    pages = [];
    hasContent = false;
    
    // Load fresh data
    Syntax.loadFriendsData();
    Syntax.loadLikedPages();
    friendCount = Syntax.getFriendCount();
    likedPages = Syntax.getLikedPages() || [];
    Syntax.loadPostsFromJson(Syntax.getCurrentUser());
    friendPosts = Syntax.getFriendsPosts(); 
    // Process posts from liked pages
    var allPosts = [];
     
        for (var i = 0; i < likedPages.length; i++) {
            var pagePosts = PageLoader.getPagePostsList(likedPages[i].pageID) || [];
            for (var j = 0; j < pagePosts.length; j++) {
                var post = pagePosts[j];
                post.pageTitle = PageLoader.getPageTitle(likedPages[i].pageID);
                post.isFollowing = true;
                post.pageID = likedPages[i].pageID;
                allPosts.push(post);
            }
        }
        
    // Process friends' posts to match page post structure
    if (friendPosts && friendPosts.length) {
        for (var k = 0; k < friendPosts.length; k++) {
            var post = friendPosts[k];
            if (!post) continue;
            
            // Convert friend post to match page post structure
            var processedPost = {
                id: post.id,
                description: post.description,
                imagePath: post.imagePath,
                date: post.date || new Date().toISOString(),
                likesCount: post.likesCount || 0,
                commentsCount: post.commentsCount || 0,
                pageTitle: post.authorUsername || "Friend",  // Use author name as pageTitle
                pageID: "friend_" + (post.authorId || k),  // Create friend pageID
                isFollowing: true,
                isVerified: true  // Friends aren't verified pages
            };
            if(post.authorUsername!=Syntax.getCurrentUser().username)
            allPosts.push(processedPost);
        }
    }

    // Original sorting remains unchanged
    posts = allPosts.sort(function(a, b) {
        return new Date(b.date) - new Date(a.date);
    });
    hasContent = posts.length > 0;

    // Original pages loading remains unchanged
    var pagesList = PageLoader.getPagesList();
    pages = [];
    for (var m = 0; m < pagesList.length; m++) {
        var page = pagesList[m];
        if (page) {
            pages.push({
                pageID: page.pageID,
                pageTitle: page.pageTitle,
                imagePath: page.imagePath,
                description: page.description,
                isVerified: true,
                isFollowing: Syntax.hasLikedPage(page.pageID)
            });
        }
    }

    console.log("HomeScreen data loaded -", posts.length, "posts,", pages.length, "pages");
    if (posts.length > 0) {
        // console.log("Sample post:", JSON.stringify(posts[0], null, 2));
    }
}
    // Clear all transient data
    function clearAllData() {
        // console.log("Clearing all home screen data");
        Syntax.saveLikedPagesToFile();
        friendCount = 0;
        likedPages = [];
        posts = [];
        pages = [];
        hasContent = false;
    }

    // Handle stack operations
    function handleStackOperation() {
        console.log("Stack operation detected - clearing home data");
        clearAllData();
    }

    // Connections for data changes
    Connections {
        target: Syntax
        function onLikedPagesChanged() {
            if (attachedStack.currentItem === homeScreen) {
                loadCompleteData();
            }
        }
    }

    // Initialize when component is created
    Component.onCompleted: {
        console.log("HomeScreen created");
        initializeCoreData();
        if (visible) {
            loadCompleteData();
        }
    }

    // Handle visibility changes
    onVisibleChanged: {
        if (visible) {
            // console.log("HomeScreen becoming visible - loading data");
            loadCompleteData();
        } else {
            // console.log("HomeScreen hidden - clearing data");
            clearAllData();
        }
    }

    // Monitor stack operations
    Connections {
        target: attachedStack
        function onCurrentItemChanged() {
            if (attachedStack.currentItem !== homeScreen) {
                handleStackOperation();
            }
        }
    }

    // Navigation properties


    header: Header {
        backgroundColor: homeScreen.cardColor
        accentColor: homeScreen.accentColor
    }

    Column {
        anchors.fill: parent
        spacing: 0

        // Stories row
        StoriesRow {
            width: parent.width
            height: homeScreen.friendCount > 0 ? 100 : 0
            visible: homeScreen.friendCount > 0
            cardColor: homeScreen.cardColor
            dividerColor: homeScreen.dividerColor
            primaryText: homeScreen.primaryText
            friendCount: homeScreen.friendCount
        }

        // Main content
        Loader {
            width: parent.width
            height: parent.height - (homeScreen.friendCount >=0 ? 100 : 0) 
            sourceComponent: hasContent ? postFeedComponent : emptyStateComponent
        }
    }

Component {
    id: postFeedComponent
    ListView {
        id: postsListView
        width: parent.width
        spacing: 24
        clip: true
        model: posts
        delegate: PostDelegate {
            cardColor: homeScreen.cardColor
            dividerColor: homeScreen.dividerColor
            primaryText: homeScreen.primaryText
            secondaryText: homeScreen.secondaryText
            accentColor: homeScreen.accentColor
            fontFamily: homeScreen.fontFamily
        }
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
        anchors.horizontalCenter: parent.horizontalCenter
    }
}

    Component {
        id: emptyStateComponent
        EmptyState {
            width: parent.width * 0.8
            accentColor: homeScreen.accentColor
            primaryText: homeScreen.primaryText
            secondaryText: homeScreen.secondaryText
            fontFamily: homeScreen.fontFamily
            discoverComponent: homeScreen.discoverComponent
            friendsComponent: homeScreen.friendsComponent
            dividerColor: homeScreen.dividerColor
        }
    }
}