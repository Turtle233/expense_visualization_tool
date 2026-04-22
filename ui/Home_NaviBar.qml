import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

// ------bottom navi bar------
Rectangle {
    id: naviBar
    width: parent.width
    height: 90
    anchors.bottom: parent.bottom
    color: "transparent"

    property var addItemDialog
    property bool showAddButton: true
    signal pageRequested(string pageName)

    Loader {
        id: addItemDialogLoader
        active: !naviBar.addItemDialog
        source: "Home_AddItemDialog.qml"
    }

    Row {
        id: buttonRow
        anchors.fill: parent
        spacing: 0

        // bottom-left half - home button
        Rectangle {
            id: homeButton
            width: naviBar.width / 2
            height: naviBar.height
            color: "transparent"

            // default set to home
            property bool selected: true

            Text {
                id: homeText
                text: qsTr("Home")
                anchors.horizontalCenter: homeButton.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: 20
                font.bold: true
                color: homeButton.selected ? Material.foreground : "gray"
            }

            // animation on click
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    homeButton.selected = true
                    settingButton.selected = false
                    naviBar.pageRequested("home")
                }
                onPressed: homeButton.scale = 1.1
                onReleased: homeButton.scale = 1.0
            }
        }

        // bottom-right half - setting button
        Rectangle {
            id: settingButton
            width: naviBar.width / 2
            height: naviBar.height
            color: "transparent"

            property bool selected: false

            Text {
                id: settingText
                text: qsTr("Settings")
                anchors.horizontalCenter: settingButton.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: 20
                font.bold: true
                color: settingButton.selected ? Material.foreground : "gray"
            }

            // animation on click
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    homeButton.selected = false
                    settingButton.selected = true
                    naviBar.pageRequested("settings")
                }
                onPressed: settingButton.scale = 1.1
                onReleased: settingButton.scale = 1.0
            }
        }
    }

    // add button centered in navi bar
    Rectangle {
        id: addButton
        visible: naviBar.showAddButton
        width: 50
        height: 50
        radius: width / 2
        color: Window.window ? Window.window.buttonColor : "#87CEEB"
        // color: "#87CEEB" // default skyblue is #87CEEB, another one is #abdbff
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: "+"
            anchors.centerIn: parent
            font.pointSize: 35
            color: "white"
        }

        // animation on click
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

        MouseArea {
            anchors.fill: parent
            onPressed: addButton.scale = 1.2
            onReleased: addButton.scale = 1.0
            onClicked: {
                console.log("[User Click] Add button clicked")
                if (naviBar.addItemDialog) {
                    naviBar.addItemDialog.open()
                } else if (addItemDialogLoader.item) {
                    addItemDialogLoader.item.open()
                }
            }
        }
    }
}
// ------end bottom navi bar------
