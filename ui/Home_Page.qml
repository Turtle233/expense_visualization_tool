import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Controls.Material

// 主页面的底层layer，这里提及的内容能够为跨文件访问提供支撑. 具体的功能函数，都在这里写实现。
Page {
    id: homePage
    anchors.fill: parent

    // 用在 Example_Item 里面，传过来需要提前显式声明
    property StackView stackViewPass

    // 默认不进入编辑模式和设置模式
    property bool editMode: false
    property bool settingsMode: false

    Item {
        anchors.fill: parent

        Home_HeaderBar {
            id: header
            visible: !homePage.settingsMode // make invisible when entering settings_page
            editMode: homePage.editMode // upcast the edit mode to the homepage
            onEditModeRequested: function (nextEditModeStatus) {
                homePage.editMode = nextEditModeStatus;
            }
            // pass sorting signal, pass the void sorting functions from item.cpp
            onSortRequested: function (sortMode) {
                if (sortMode === "dateAsc") {
                    itemListModel.sortByDateAscending();
                } else if (sortMode === "dateDesc") {
                    itemListModel.sortByDateDescending();
                } else if (sortMode === "nameAsc") {
                    itemListModel.sortByNameAscending();
                } else if (sortMode === "nameDesc") {
                    itemListModel.sortByNameDescending();
                }
            }
        }

        Home_NaviBar {
            id: naviBar
            addItemDialog: addItemDialog
            showAddButton: !homePage.settingsMode // make invisible when entering settings_page

            // function to enter settings_page, meanwhile entering settings mode
            onPageRequested: function (pageName) {
                homePage.settingsMode = (pageName === "settings");
                if (homePage.settingsMode) {
                    homePage.editMode = false; // validation ensure
                }
            }
        }

        Home_AddItemDialog {
            id: addItemDialog
            onAddItemRequested: function (itemName, itemExpense, purchaseDateText) {
                const expenseInUsd = currencyManager.parseAmountToUSD(itemExpense);
                if (expenseInUsd <= 0
                        || !itemListModel.addItem(itemName, expenseInUsd.toFixed(6), purchaseDateText)) {
                    console.log("[Error] Failed to add item from AddItemDialog");

                    // msgbox indicating error input
                    addItemDialog.open();
                }
            }
        }

        Home_ItemList {
            id: homeItemList
            visible: !homePage.settingsMode // make invisible when entering settings_page
            anchors.top: header.bottom
            anchors.topMargin: -8
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: naviBar.top
            stackViewPass: homePage.stackViewPass
            editMode: homePage.editMode
        }

        Settings_Page {
            id: settingsPage
            visible: homePage.settingsMode
            anchors.fill: homeItemList
        }

        // 用来检测添加对话框的输入错误
        MessageDialog {
            id: addItemErrorDialog
            title: qsTr("Input Error")
            text: qsTr("Please type in valid item name, item expense, and purchase date.")
            buttons: MessageDialog.Ok
        }
    }
}
