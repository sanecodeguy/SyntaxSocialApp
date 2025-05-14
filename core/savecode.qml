import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import com.company 1.0
import "../components"

Page {
    id: discoverPage

    // Data properties
    property var pages: []
    property bool isLoading: false
    property string errorMessage: ""
    property bool hasData: pages.length > 0

    // Load data on startup
    Component.onCompleted: loadData()

    function loadData() {
        console.log("Loading JSON...");
        isLoading = true;
        errorMessage = "";
        
        try {
            if (PageLoader.loadFromJson("qrc:/assets/data/AllPages.json")) {
                pages = PageLoader.getPages();
                console.log("Pages loaded:", JSON.stringify(pages, null, 2));
                if (pages.length === 0) {
                    errorMessage = "No pages found in data";
                }
            } else {
                errorMessage = "Failed to load JSON data";
            }
        } catch (error) {
            errorMessage = "Error: " + error;
            console.error("Exception:", error);
        }
        
        isLoading = false;
    }

    // UI States
    // --------
    // Loading State
    BusyIndicator {
        anchors.centerIn: parent
        running: isLoading
        visible: isLoading
        width: 80
        height: 80
    }

    // Error State
    Column {
        anchors.centerIn: parent
        spacing: 20
        visible: !isLoading && errorMessage !== ""

        Label {
            text: "⚠️ Loading Error"
            font.pixelSize: 20
            font.bold: true
            color: "red"
        }

        Label {
            width: discoverPage.width * 0.8
            text: errorMessage
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 14
            color: "#666"
        }

        Button {
            text: "Retry Loading"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: loadData()

            background: Rectangle {
                radius: 8
                color: parent.down ? "#d0d0d0" : "#f0f0f0"
            }
        }
    }

    // Content State
    ScrollView {
        anchors.fill: parent
        visible: !isLoading && errorMessage === "" && hasData
        clip: true

        Column {
            width: parent.width
            spacing: 20

            Repeater {
                model: pages

                delegate: Column {
                    width: discoverPage.width
                    spacing: 0

                    // Page Header
                    Rectangle {
                        width: parent.width
                        height: 80
                        color: "white"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 15
                            anchors.rightMargin: 15
                            spacing: 12

                            // Owner Avatar
                            Rectangle {
                                width: 50
                                height: 50
                                radius: width / 2
                                color: "#f0f0f0"

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.owner ? modelData.owner.charAt(0).toUpperCase() : "?"
                                    font.pixelSize: 20
                                    font.bold: true
                                    color: "#666"
                                }
                            }

                            // Page Info
                            Column {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: modelData.title || "Untitled Page"
                                    font.pixelSize: 16
                                    font.bold: true
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }

                                Text {
                                    text: "By " + (modelData.owner || "Unknown")
                                    font.pixelSize: 12
                                    color: "#666"
                                }
                            }

                            // Likes
                            Text {
                                text: modelData.likes + " ♥"
                                font.pixelSize: 14
                                color: "#ff4081"
                            }
                        }
                    }

                    // Posts List
                    Repeater {
                        model: PageLoader.getPagePosts(index)

                        delegate: PostDelegate {
                            width: discoverPage.width
                            postData: modelData
                        }
                    }

                    // Page Footer Spacer
                    Rectangle {
                        width: parent.width
                        height: 15
                        color: "transparent"
                    }
                }
            }
        }
    }
    footer: TabBar {
    position: TabBar.Footer
    background: Rectangle { color: "white" }

    TabButton {
        icon.source: "icons/home.png"
        icon.width: 24
        icon.height: 24
    }
    TabButton {
        icon.source: "icons/search.png"
        icon.width: 24
        icon.height: 24
    }
    TabButton {
        icon.source: "icons/add.png" 
        icon.width: 24
        icon.height: 24
    }
    TabButton {
        icon.source: "icons/heart.png"
        icon.width: 24
        icon.height: 24
    }
    TabButton {
        icon.source: "icons/profile.png"
        icon.width: 24
        icon.height: 24
    }
}
}

// Post Delegate
