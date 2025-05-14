import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import com.rizzons.syntax 1.0
import Qt5Compat.GraphicalEffects

Page {
    id: friendsPage

    // Models for each tab
    ListModel { id: friendsModel }
    ListModel { id: searchModel }

    property bool loading: false
    property string searchText: ""

    // Premium color palette
    readonly property color backgroundColor: "#111111"  // Chinese Black
    readonly property color cardColor: "#1E1E1E"       // Dark card
    readonly property color primaryText: "#FFFFFF"      // White
    readonly property color secondaryText: "#BBBAB9"    // Gray (X11)
    readonly property color accentColor: "#FEC347"      // Maine (Crayola) - primary accent
    readonly property color dangerColor: "#F63827"      // Deep Carmine Pink - for remove actions
    readonly property color dividerColor: "#2E2E2E"     // Dark divider
    readonly property color tabInactive: "#2E2E2E"      // Inactive tab
    readonly property color tabHighlight: "#3E3E3E"     // Tab highlight

    // Main data loading function
    function refreshAllData() {
        loading = true
        friendsModel.clear()
        searchModel.clear()
        
        var friendsData = Syntax.loadFriendsData()
        var allUsers = Syntax.getUsersList()
        
        for (var i = 0; i < friendsData.length; i++) {
            if (friendsData[i] && friendsData[i].username) {
                friendsModel.append({
                    "username": friendsData[i].username
                })
            }
        }
        
        filterUsers(allUsers)
        loading = false
    }

    // Filter users for search tab
    function filterUsers(allUsers) {
        searchModel.clear()
        var currentFriends = []
        
        for (var i = 0; i < friendsModel.count; i++) {
            currentFriends.push(friendsModel.get(i).username)
        }
        
        for (var j = 0; j < allUsers.length; j++) {
            var user = allUsers[j]
            if (!user || !user.username) continue
            
            var usernameMatch = user.username.toLowerCase().includes(searchText.toLowerCase())
            var notFriend = currentFriends.indexOf(user.username) === -1
            
            if (usernameMatch && notFriend) {
                searchModel.append({
                    "username": user.username
                })
            }
        }
    }

    // Handle backend changes
    Connections {
        target: Syntax
        function onFriendsDataChanged() {
            refreshAllData()
        }
    }

    // Initial load
    Component.onCompleted: refreshAllData()

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
        
        RowLayout {
            anchors.fill: parent
            spacing: 16
            anchors.leftMargin: 24
            anchors.rightMargin: 24

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
                text: "Connections"
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
    }

 // Replace your existing tabBar implementation with this:

// Modern Tab Bar
Rectangle {
    id: tabBar
    width: parent.width
    height: 48  // Slightly more compact
    anchors.top: header.bottom
    color: "transparent"  // Makes it blend better
    property int currentIndex: 0
    
    // Subtle divider line
    Rectangle {
        width: parent.width
        height: 1
        color: dividerColor
        anchors.bottom: parent.bottom
    }
    
    Row {
        anchors.centerIn: parent
        height: parent.height
        spacing: 0
        
        // Connections Tab - Modern Design
        Item {
            width: 140
            height: parent.height
            
            Rectangle {
                width: parent.width
                height: 3
                color: accentColor
                visible: tabBar.currentIndex === 0
                anchors.bottom: parent.bottom
            }
            
            Text {
                text: "Connections"
                anchors.centerIn: parent
                color: tabBar.currentIndex === 0 ? accentColor : secondaryText
                font {
                    pixelSize: 14
                    weight: Font.Medium
                    letterSpacing: 0.5
                }
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: tabBar.currentIndex = 0
                cursorShape: Qt.PointingHandCursor
            }
        }
        
        // Vertical divider
        Rectangle {
            width: 1
            height: 24
            color: dividerColor
            anchors.verticalCenter: parent.verticalCenter
        }
        
        // Search Tab - Modern Design
        Item {
            width: 140
            height: parent.height
            
            Rectangle {
                width: parent.width
                height: 3
                color: accentColor
                visible: tabBar.currentIndex === 1
                anchors.bottom: parent.bottom
            }
            
            Text {
                text: "Discover"
                anchors.centerIn: parent
                color: tabBar.currentIndex === 1 ? accentColor : secondaryText
                font {
                    pixelSize: 14
                    weight: Font.Medium
                    letterSpacing: 0.5
                }
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: tabBar.currentIndex = 1
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
    
    // Animated underline for smooth transitions
    Rectangle {
        width: 140
        height: 3
        color: accentColor
        anchors.bottom: parent.bottom
        x: tabBar.currentIndex === 0 ? (parent.width/2 - 140 - 0.5) : (parent.width/2 + 0.5)
        Behavior on x {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }
}
        
    StackLayout {
        anchors {
            top: tabBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        currentIndex: tabBar.currentIndex

        // Connections Tab - Premium Dark List
        ScrollView {
            width: parent.width
            height: parent.height
            clip: true
            
            ListView {
                id: friendsList
                width: parent.width
                height: parent.height
                model: friendsModel
                clip: true
                spacing: 8
                topMargin: 16
                bottomMargin: 16
                leftMargin: 16
                rightMargin: 16

                delegate: Rectangle {
                    id: friendCard
                    width: ListView.view.width - 32
                    height: 80
                    radius: 12
                    color: cardColor
                    property string username: model.username
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        // Premium profile avatar
                        Rectangle {
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            radius: width / 2
                            color: "#333333"
                            
                            Text {
                                text: username.charAt(0).toUpperCase()
                                anchors.centerIn: parent
                                color: accentColor
                                font {
                                    pixelSize: 20
                                    weight: Font.DemiBold
                                }
                            }
                        }

                        // User info
                        Column {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 4
                            
                            Text {
                                text: username
                                color: primaryText
                                font {
                                    pixelSize: 16
                                    weight: Font.Medium
                                }
                                elide: Text.ElideRight
                                width: parent.width
                            }

                            Text {
                                text: "Connected"
                                color: secondaryText
                                font.pixelSize: 12
                                width: parent.width
                            }
                        }

                        // Premium remove button
                        Rectangle {
                            width: 90
                            height: 36
                            radius: 18
                            color: removeMouseArea.pressed ? Qt.darker(dangerColor, 1.2) : 
                                  (removeMouseArea.containsMouse ? Qt.darker(dangerColor, 1.1) : dangerColor)
                            
                            Text {
                                text: "Remove"
                                anchors.centerIn: parent
                                color: "white"
                                font {
                                    pixelSize: 13
                                    weight: Font.DemiBold
                                }
                            }
                            
                            MouseArea {
                                id: removeMouseArea
                                anchors.fill: parent
                                onClicked: {
                                    for (var i = 0; i < friendsModel.count; i++) {
                                        if (friendsModel.get(i).username === username) {
                                            friendsModel.remove(i)
                                            break
                                        }
                                    }
                                    Syntax.removeFriend(username)
                                }
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }

                // Premium empty state
                Item {
                    width: parent.width
                    height: 300
                    visible: friendsList.count === 0 && !loading
                    
                    Column {
                        width: parent.width
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
                                text: "👥"
                                anchors.centerIn: parent
                                font.pixelSize: 32
                            }
                        }
                        
                        Text {
                            text: "No connections yet"
                            color: accentColor
                            font {
                                pixelSize: 18
                                weight: Font.DemiBold
                            }
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: "Your connections will appear here"
                            color: secondaryText
                            font.pixelSize: 14
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }

        // Search Tab - Premium Dark Design
        Item {
            width: parent.width
            height: parent.height
            
            // Premium search bar
            Rectangle {
                id: searchContainer
                width: parent.width - 32
                height: 52
                radius: 26
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 16
                color: cardColor
                
                Row {
                    anchors.fill: parent
                    spacing: 12
                    leftPadding: 24
                    rightPadding: 24
                    
                    Image {
                        source: "qrc:/icons/search.svg"
                        width: 20
                        height: 20
                        anchors.verticalCenter: parent.verticalCenter
                        
                        ColorOverlay {
                            anchors.fill: parent
                            source: parent
                            color: secondaryText
                        }
                    }
                    
                    TextField {
                        id: searchField
                        width: parent.width - 60
                        height: parent.height
                        placeholderText: "Search users..."
                        font.pixelSize: 15
                        color: primaryText
                        placeholderTextColor: secondaryText
                        verticalAlignment: Text.AlignVCenter
                        background: Rectangle {
                            color: "transparent"
                        }
                        onTextChanged: {
                            searchText = text
                            filterUsers(Syntax.getUsersList())
                        }
                    }
                }
            }

            // Premium search results
            ScrollView {
                width: parent.width
                height: parent.height - searchContainer.height - 32
                anchors.top: searchContainer.bottom
                anchors.topMargin: 16
                clip: true
                
                ListView {
                    id: searchResults
                    width: parent.width
                    model: searchModel
                    spacing: 8
                    topMargin: 8
                    bottomMargin: 16
                    leftMargin: 16
                    rightMargin: 16

                    delegate: Rectangle {
                        id: userCard
                        width: ListView.view.width - 32
                        height: 80
                        radius: 12
                        color: cardColor
                        property string username: model.username
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16

                            // Premium profile avatar
                            Rectangle {
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 48
                                radius: width / 2
                                color: "#333333"
                                
                                Text {
                                    text: username.charAt(0).toUpperCase()
                                    anchors.centerIn: parent
                                    color: accentColor
                                    font {
                                        pixelSize: 20
                                        weight: Font.DemiBold
                                    }
                                }
                            }

                            // User info
                            Column {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 4
                                
                                Text {
                                    text: username
                                    color: primaryText
                                    font {
                                        pixelSize: 16
                                        weight: Font.Medium
                                    }
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                Text {
                                    text: "Available to connect"
                                    color: secondaryText
                                    font.pixelSize: 12
                                    width: parent.width
                                }
                            }

                            // Premium connect button
                            Rectangle {
                                width: 90
                                height: 36
                                radius: 18
                                color: connectMouseArea.pressed ? Qt.darker(accentColor, 1.2) : 
                                      (connectMouseArea.containsMouse ? Qt.darker(accentColor, 1.1) : accentColor)
                                
                                Text {
                                    text: "Connect"
                                    anchors.centerIn: parent
                                    color: "#111111"
                                    font {
                                        pixelSize: 13
                                        weight: Font.DemiBold
                                    }
                                }
                                
                                MouseArea {
                                    id: connectMouseArea
                                    anchors.fill: parent
                                    onClicked: {
                                        friendsModel.append({"username": username})
                                        Syntax.addFriend(username)
                                        
                                        for (var i = 0; i < searchModel.count; i++) {
                                            if (searchModel.get(i).username === username) {
                                                searchModel.remove(i)
                                                break
                                            }
                                        }
                                    }
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }
                    }

                    // Premium empty state
                    Item {
                        width: parent.width
                        height: 300
                        visible: searchResults.count === 0 && !loading
                        
                        Column {
                            width: parent.width
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
                                text: searchText.length > 0 ? "No users found" : "Search for users"
                                color: accentColor
                                font {
                                    pixelSize: 18
                                    weight: Font.DemiBold
                                }
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            
                            Text {
                                text: searchText.length > 0 ? 
                                    "Try a different search term" : 
                                    "Find people to connect with"
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

    // Premium loading indicator
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.06, 0.06, 0.06, 0.8)
        visible: loading
        z: 100
        
        Rectangle {
            width: 60
            height: 60
            radius: 30
            anchors.centerIn: parent
            color: cardColor
            
            RotationAnimator {
                target: loadingIcon
                from: 0
                to: 360
                duration: 800
                running: true
                loops: Animation.Infinite
            }
            
            Image {
                id: loadingIcon
                source: "qrc:/icons/loading.svg"
                width: 32
                height: 32
                anchors.centerIn: parent
                
                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: accentColor
                }
            }
        }
    }
}