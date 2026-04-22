import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

// ------header bar------
// header title
Rectangle {
    id: header
    width: parent.width
    height: 80 // 标题栏高度写固定值，与Detail Page统一
    color: "transparent"

    property bool editMode: false // edit mode need to be triggered on by edit button

    // signals for sort and edit buttons
    signal editModeRequested(bool nextEditButtonClick)
    signal sortRequested(string sortMode)

    Text {
        text: qsTr("See your Cost") // software title
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 16
        font.pointSize: 22
        font.bold: true
        color: Material.foreground
    }

    // sort button with drop down menu
    Button {
        id: sortButton
        visible: !header.editMode   // when edit mode was triggered, hide the sort button
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: editButton.left
        anchors.rightMargin: 8

        Text {
            text: qsTr("Sort")
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 18
            color: Material.foreground
        }

        // drop down menu for sorting
        // final value passed into header.sortRequested() is a bool function return value from sorting.cpp
        Menu {
            id: menuDropdown
            title: ""
            MenuItem {
                text: qsTr("Sort By Date Asc ⬆️")
                onTriggered: {
                    header.sortRequested("dateAsc");
                    console.log("[User Click] Sort By Date Ascending clicked");
                }
            }

            MenuItem {
                text: qsTr("Sort By Date Dsc ⬇️")
                onTriggered: {
                    header.sortRequested("dateDesc");
                    console.log("[User Click] Sort By Date Descending clicked");
                }
            }

            MenuItem {
                text: qsTr("Sort By Name Asc ⬆️")
                onTriggered: {
                    header.sortRequested("nameAsc");
                    console.log("[User Click] Sort By Name Ascending clicked");
                }
            }

            MenuItem {
                text: qsTr("Sort By Name Dsc ⬇️")
                onTriggered: {
                    header.sortRequested("nameDesc");
                    console.log("[User Click] Sort By Name Descending clicked");
                }
            }
        }

        onClicked: menuDropdown.open()
    }

    // edit button
    Button {
        id: editButton
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 16

        Text {
            // if in edit mode, show Done, if not, show regular Edit
            text: header.editMode ? qsTr("Done") : qsTr("Edit")

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 18
            color: Material.foreground
        }

        onClicked: {
            console.log("[User Click] Edit button clicked");
            header.editModeRequested(!header.editMode); // after click the edit button, inverse the state of edit mode
        }
    }
}
// ------end header bar------
