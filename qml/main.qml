import "./ExpandableBottomBar" 
import QtQuick 2.15
import QtQuick.Controls 2.15
import "./screens" as Screens  
import com.company 1.0

ApplicationWindow {
    id: root
    visible: true
    width: 360
    height: 640
    title: "Syntax"
    color: "#111111"
    property bool isLoggedIn: false

    // Screen components
    property Component homeComponent: Screens.HomeScreen {}
    property Component discoverComponent: Screens.Discover {}
    property Component friendsComponent: Screens.Friends {}
    property Component profileComponent: Screens.Profile{} // Placeholder

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: Screens.AuthScreen {
            onLoginSuccess: {
                isLoggedIn = true
                navBar.buttons[0].checked = true
                loadScreen(homeComponent, true)
            }
        }
    }

    function loadScreen(component, immediate = false) {
        if (stack.depth > 0) {
            stack.replace(component, {}, immediate ? StackView.Immediate : StackView.Immediate)
        } else {
            stack.push(component, {}, immediate ? StackView.Immediate : StackView.Immediate)
        }
    }

    NavigationBar {
        id: navBar
        visible: isLoggedIn
        anchors {
            left: parent.left
            leftMargin: 50
            right: parent.right
            rightMargin: 50
            bottom: parent.bottom
            bottomMargin: 20
        }

        property var buttons: [homeButton, discoverButton, friendsButton, profileButton]

        // Assuming NavigationBarButton has these basic properties:
        // - text
        // - icon.source
        // - checked
        // - onClicked or similar for handling taps
        
        NavigationBarButton {
            id: homeButton
            text: "Home"
            icon.source: "icons/home.png"
            checked: true
            onClicked: {
                checked = true
                loadScreen(homeComponent, true)
            }
        }

        NavigationBarButton {
            id: discoverButton
            text: "Discover"
            icon.source: "icons/search.png"
            onClicked: {
                checked = true
                loadScreen(discoverComponent, true)
            }
        }

        NavigationBarButton {
            id: friendsButton
            text: "Friends"
            icon.source: "icons/heart.png"
            onClicked: {
                checked = true
                loadScreen(friendsComponent, true)
            }
        }

        NavigationBarButton {
            id: profileButton
            text: "Profile"
            icon.source: "icons/profile.png"
            onClicked: {
                checked = true
                loadScreen(profileComponent, true) // Uncomment when ready
            }
        }
    }
}