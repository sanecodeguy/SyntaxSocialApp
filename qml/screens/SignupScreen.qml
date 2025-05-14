import QtQuick 2.15
import QtQuick.Controls 2.15
import com.rizzons.syntax 1.0

Page {
    id: signupScreen

    // White background matching auth screen
    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
    }

    // Loading Screen Component
    Component {
        id: loadingComponent
        
        Item {
            id: loadingOverlay
            anchors.fill: parent
            z: 10 // Show above everything
            
            Rectangle {
                anchors.fill: parent
                color: "#ffffff"
                
                Column {
                    anchors.centerIn: parent
                    spacing: 40
                    width: Math.min(parent.width * 0.8, 400)
                    
                    // Animated Logo
                    Item {
                        width: 150
                        height: 150
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Image {
                            source: "icons/logo.png"
                            width: 150
                            height: 150
                            anchors.centerIn: parent
                            fillMode: Image.PreserveAspectFit

                        }
                    }
                    
                    // Animated Text
                    Text {
                        id: loadingText
                        text: "CREATING ACCOUNT"
                        color: "#121212"
                        font {
                            pixelSize: 14
                            letterSpacing: 3
                            weight: Font.Bold
                        }
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        property int dotCount: 0
                        
                        Timer {
                            interval: 500
                            running: true
                            repeat: true
                            onTriggered: {
                                loadingText.dotCount = (loadingText.dotCount + 1) % 4
                                loadingText.text = "CREATING ACCOUNT" + ".".repeat(loadingText.dotCount)
                            }
                        }
                    }
                    
                    // Animated Progress
                    Rectangle {
                        width: parent.width
                        height: 2
                        color: "#e0e0e0"
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Rectangle {
                            width: parent.width
                            height: 2
                            color: "#121212"
                            
                            SequentialAnimation on width {
                                loops: Animation.Infinite
                                NumberAnimation { from: 0; to: parent.width * 0.7; duration: 800; easing.type: Easing.InOutQuad }
                                NumberAnimation { to: 0; duration: 400; easing.type: Easing.InQuad }
                                PauseAnimation { duration: 200 }
                            }
                        }
                    }
                }
            }
        }
    }

    // Main Form Column
    Column {
        id: formColumn
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            margins: 40
        }
        spacing: 32

        // Your logo (same 150x150 size as auth screen)
        Image {
            source: "icons/logo.png"
            width: 150
            height: 150
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
        }

        // Input fields
        Column {
            width: parent.width
            spacing: 1

            // Full Name
            Rectangle { width: parent.width; height: 1; color: "#333333" }
            TextField {
                id: fullNameField
                width: parent.width
                height: 56
                font.pixelSize: 16
                color: "#121212"
                topPadding: 28
                leftPadding: 0
                background: Item {}

                Text {
                    text: "FULL NAME"
                    color: fullNameField.text ? "#666666" : "#444444"
                    font {
                        pixelSize: 11
                        letterSpacing: 3
                        weight: Font.DemiBold
                    }
                    anchors { left: parent.left; top: parent.top }
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
            }

            // Username
            Rectangle { width: parent.width; height: 1; color: "#333333" }
            TextField {
                id: usernameField
                width: parent.width
                height: 56
                font.pixelSize: 16
                color: "#121212"
                topPadding: 28
                leftPadding: 0
                background: Item {}
                property bool isValid: false
                property bool isChecking: false

                Text {
                    text: "USERNAME"
                    color: usernameField.text ? "#666666" : "#444444"
                    font {
                        pixelSize: 11
                        letterSpacing: 3
                        weight: Font.DemiBold
                    }
                    anchors { left: parent.left; top: parent.top }
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                // Validation indicator
                Text {
                    text: {
                        if (usernameField.isChecking) return "⌛"
                        return usernameField.isValid ? "✓" : (usernameField.text ? "✗" : "")
                    }
                    color: usernameField.isValid ? "#4ade80" : "#f87171"
                    font.pixelSize: 14
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                }

                onTextChanged: {
                    if (text.length > 0) {
                        isChecking = true
                        checkTimer.restart()
                    } else {
                        isValid = false
                        isChecking = false
                    }
                }

                Timer {
                    id: checkTimer
                    interval: 500
                    onTriggered: {
                        usernameField.isValid = !Syntax.userExists(usernameField.text)
                        usernameField.isChecking = false
                    }
                }
            }

            // Password
            Rectangle { width: parent.width; height: 1; color: "#333333" }
            TextField {
                id: passwordField
                width: parent.width
                height: 56
                echoMode: TextInput.Password
                font.pixelSize: 16
                color: "#121212"
                topPadding: 28
                leftPadding: 0
                background: Item {}

                Text {
                    text: "PASSWORD"
                    color: passwordField.text ? "#666666" : "#444444"
                    font {
                        pixelSize: 11
                        letterSpacing: 3
                        weight: Font.DemiBold
                    }
                    anchors { left: parent.left; top: parent.top }
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                // Eye toggle
                Text {
                    text: passwordField.echoMode === TextInput.Password ? "👁️" : "👁️‍🗨️"
                    color: "#888888"
                    font.pixelSize: 16
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
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

            Rectangle { width: parent.width; height: 1; color: "#333333" }
        }

        // Signup button
        MouseArea {
            width: parent.width
            height: 48
            hoverEnabled: true
            enabled: usernameField.isValid && 
                    fullNameField.text.length > 0 && 
                    passwordField.text.length > 0

            Rectangle {
                anchors.fill: parent
                color: parent.containsMouse ? "#E5B142" : "#FEC347"
                border.width: 1
                border.color: parent.parent.enabled ? 
                    (parent.containsMouse ? "#121212" : "#555555") : "#AAAAAA"
                radius: 2

                Text {
                    text: "CREATE ACCOUNT"
                    color: parent.parent.containsMouse ? "#121212" : 
                          (parent.parent.enabled ? "#121212" : "#121212")
                    font {
                        pixelSize: 12
                        letterSpacing: 3
                        weight: Font.Bold
                    }
                    anchors.centerIn: parent
                }

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }
            }

            onClicked: attemptSignup()
        }

        // Login link
        Text {
            text: "Already have an account? <a href='login' style='color:#888888;text-decoration:none'>Log in</a>"
            textFormat: Text.RichText
            color: "#666666"
            font.pixelSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: 16

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: stack.pop()
            }
        }
    }

    // Status message
    Text {
        id: statusText
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 40
        }
        color: "#ff5555"
        font {
            pixelSize: 12
            letterSpacing: 1
        }
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 160 } }
    }

    function attemptSignup() {
        if (!usernameField.isValid) {
            statusText.text = "INVALID USERNAME";
            statusText.opacity = 1;
            statusTimer.start();
            return;
        }

        // Show loading overlay
        var loader = loadingComponent.createObject(signupScreen);
        
        // Simulate account creation (replace with actual API call)
        var creationTimer = Qt.createQmlObject('import QtQuick 2.15; Timer {}', signupScreen);
        creationTimer.interval = 2500;
        creationTimer.repeat = false;
        creationTimer.triggered.connect(function() {
            var success = Syntax.createUserSignUp(usernameField.text, passwordField.text);
            loader.destroy();
            
            if (success) {
                statusText.text = "ACCOUNT CREATED";
                statusText.color = "#4ade80";
                statusText.opacity = 1;
                successTimer.start();
            } else {
                statusText.text = "SIGNUP FAILED";
                statusText.color = "#ff5555";
                statusText.opacity = 1;
                statusTimer.start();
            }
        });
        creationTimer.start();
    }

    Timer {
        id: statusTimer
        interval: 3000
        onTriggered: statusText.opacity = 0
    }

    Timer {
        id: successTimer
        interval: 1500
        onTriggered: stack.pop()
    }
}