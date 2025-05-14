import QtQuick.Layouts 1.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import com.rizzons.syntax 1.0
import Qt5Compat.GraphicalEffects

Page {
    id: authScreen
    signal loginSuccess()
    
    // White background
    Rectangle {
        anchors.fill: parent
        color: "#FFFFFF"
    }

    FocusScope {
        anchors.fill: parent
        focus: true

        // Central form (now with subtle shadow)
        Rectangle {
            width: Math.min(parent.width * 0.9, 400)
            height: childrenRect.height + 60
            anchors.centerIn: parent
            color: "#FFFFFF"
            radius: 8
            border.color: "#EEEEEE"
            border.width: 1
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                radius: 8
                samples: 16
                color: "#10000000"  // Very subtle shadow
            }

            Column {
                width: parent.width - 60
                anchors.centerIn: parent
                spacing: 24
                topPadding: 40
                bottomPadding: 40

                // Logo (unchanged but centered)
                Image {
                    source: "icons/logo.png"
                    width: 120
                    height: 120
                    anchors.horizontalCenter: parent.horizontalCenter
                    fillMode: Image.PreserveAspectFit
                }

                // Input fields (modern flat style)
                Column {
                    width: parent.width
                    spacing: 16

                    // Username field
                    TextField {
                        id: usernameField
                        width: parent.width
                        height: 56
                        font.pixelSize: 15
                        color: "#121212"  // High-contrast text
                        placeholderText: " "
                        leftPadding: 16
                        topPadding: 24
                        background: Rectangle {
                            radius: 4
                            border.width: 1
                            border.color: usernameField.activeFocus ? "#FEC347" : "#DDDDDD"
                        }

                        Text {
                            text: "USERNAME"
                            color: usernameField.activeFocus ? "#FEC347" : "#999999"
                            font {
                                pixelSize: 11
                                letterSpacing: 2
                                weight: Font.Medium
                            }
                            anchors { left: parent.left; top: parent.top; leftMargin: 16; topMargin: 8 }
                        }
                    }

                    // Password field
                    TextField {
                        id: passwordField
                        width: parent.width
                        height: 56
                        echoMode: TextInput.Password
                        font.pixelSize: 15
                        color: "#121212"
                        placeholderText: " "
                        leftPadding: 16
                        topPadding: 24
                        background: Rectangle {
                            radius: 4
                            border.width: 1
                            border.color: passwordField.activeFocus ? "#FEC347" : "#DDDDDD"
                        }

                        Text {
                            text: "PASSWORD"
                            color: passwordField.activeFocus ? "#FEC347" : "#999999"
                            font {
                                pixelSize: 11
                                letterSpacing: 2
                                weight: Font.Medium
                            }
                            anchors { left: parent.left; top: parent.top; leftMargin: 16; topMargin: 8 }
                        }

                        // Eye toggle (gold when focused)
                        Text {
                            text: passwordField.echoMode === TextInput.Password ? "👁️" : "👁️‍🗨️"
                            color: passwordField.activeFocus ? "#FEC347" : "#AAAAAA"
                            font.pixelSize: 16
                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                rightMargin: 16
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    passwordField.echoMode = 
                                        passwordField.echoMode === TextInput.Password ? 
                                        TextInput.Normal : TextInput.Password;
                                }
                            }
                        }
                    }
                }

                // Login button (gold)
                Button {
                    width: parent.width
                    height: 48
                    text: "SIGN IN"
                    font {
                        pixelSize: 14
                        letterSpacing: 1.5
                        weight: Font.DemiBold
                    }
                    background: Rectangle {
                        radius: 4
                        color: parent.down ? "#E5B142" : "#FEC347"  // Darker gold when pressed
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#121212"  // Black text for contrast
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: attemptLogin()
                }

                // Sign up link (subtle)
                Text {
                    text: "No account? <a href='signup' style='color:#FEC347;text-decoration:none'>Sign up</a>"
                    textFormat: Text.RichText
                    color: "#999999"
                    font.pixelSize: 13
                    anchors.horizontalCenter: parent.horizontalCenter

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: stack.push(signupScreen)
                    }
                }
            }
        }
    }

    // Error message (red)
    Rectangle {
        id: statusToast
        width: statusText.width + 32
        height: statusText.height + 16
        radius: 20
        color: "#F63827"
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 30
        }
        opacity: 0
        visible: opacity > 0

        Text {
            id: statusText
            anchors.centerIn: parent
            color: "white"
            font {
                pixelSize: 12
                letterSpacing: 1
                weight: Font.Medium
            }
        }

        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    // === REST OF YOUR CODE (UNCHANGED) ===
    function attemptLogin() {
        if(usernameField.text === "" || passwordField.text === "") {
            statusText.text = "Credentials required";
            statusToast.opacity = 1;
            statusTimer.start();
            return false;
        }
        
        var newUser = Syntax.createUser(usernameField.text, passwordField.text);
        if(newUser) {
            stack.push(loadingScreen);
            loadingTimer.start();
            return true;
        }
        
        statusText.text = "Authentication failed";
        statusToast.opacity = 1;
        statusTimer.start();
        return false;
    }

    Timer {
        id: loadingTimer
        interval: 2000
        onTriggered: loginSuccess()
    }

    Timer {
        id: statusTimer
        interval: 3000
        onTriggered: statusToast.opacity = 0
    }

    Component {
        id: signupScreen
        SignupScreen {}
    }

    Component {
        id: loadingScreen
        Item {
            width: parent ? parent.width : 0
            height: parent ? parent.height : 0
            
            Rectangle {
                anchors.fill: parent
                color: "#FFFFFF"
            }
            
            Column {
                anchors.centerIn: parent
                spacing: 40
                width: Math.min(parent.width * 0.8, 400)
                
                Image {
                    source: "icons/logo.png"
                    width: 120
                    height: 120
                    anchors.horizontalCenter: parent.horizontalCenter
                    fillMode: Image.PreserveAspectFit
                    
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.8; duration: 800; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                    }
                }
                
                Text {
                    text: "AUTHENTICATING"
                    color: "#121212"
                    font {
                        pixelSize: 14
                        letterSpacing: 3
                        weight: Font.Bold
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Item {
                    width: parent.width
                    height: 20
                    
                    Rectangle {
                        width: parent.width
                        height: 2
                        color: "#EEEEEE"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Rectangle {
                        id: progressBar
                        width: 0
                        height: 2
                        color: "#FEC347"  // Gold progress bar
                        anchors.verticalCenter: parent.verticalCenter
                        
                        SequentialAnimation on width {
                            loops: Animation.Infinite
                            NumberAnimation { 
                                from: 0
                                to: Rectangle.width * 0.6
                                duration: 800 
                                easing.type: Easing.InOutQuad 
                            }
                            NumberAnimation { 
                                to: 0 
                                duration: 400 
                                easing.type: Easing.InQuad 
                            }
                            PauseAnimation { duration: 200 }
                        }
                        
                        Rectangle {
                            width: 8
                            height: 2
                            color: "#FEC347"
                            anchors.right: parent.right
                            opacity: parent.width > 10 ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 100 } }
                        }
                    }
                }
            }
        }
    }
}