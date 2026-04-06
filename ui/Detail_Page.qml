import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

// 主框架
Page {
    id: detailPage
    anchors.fill: parent

    // values declaration and initialization
    property string itemName: qsTr("Item Name")
    property real totalPrice: 0
    property date purchaseDate
    property int passedDays: 0
    property int itemIndex: -1

    property StackView stackViewPass
    property var itemDelegateRef

    // connected to the edit dialog
    function applyEdit(itemNameText, expenseText, purchaseDateText) {
        if (detailPage.itemIndex == -1) {
            console.log("[Error] Invalid item index for edit");
            return;
        }

        const normalizedItemName = itemNameText.trim();
        const updatedExpense = currencyManager.parseAmountToUSD(expenseText);
        const updatedPurchaseDate = new Date(purchaseDateText + "T00:00:00");

        if (!itemListModel.updateItem(detailPage.itemIndex, normalizedItemName, updatedExpense.toFixed(2), purchaseDateText)) {
            console.log("[Error] Failed to update item");
            return;
        }

        detailPage.itemName = normalizedItemName;
        detailPage.totalPrice = updatedExpense;
        detailPage.purchaseDate = updatedPurchaseDate;
        detailPage.passedDays = itemListModel.passedDaysAt(detailPage.itemIndex);
    }

    // load the Detail_EditDialog
    Loader {
        id: editDialogLoader
        active: true
        source: "Detail_EditDialog.qml"
    }

    // connect with the edit dialog when data was refreshed
    Connections {
        target: editDialogLoader.item
        function onEditItemRequested(itemName, itemExpense, purchaseDateText) {
            detailPage.applyEdit(itemName, itemExpense, purchaseDateText);
        }
    }

    // 详情页面主要元素
    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        // 顶部导航栏，包括返回和编辑按钮
        Rectangle {
            id: topNaviBar
            height: 80
            Layout.fillWidth: true
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                height: topNaviBar.height
                spacing: 10

                // left margin in top navi bar
                Item {
                    width: 8
                }

                Button {
                    id: topBackButton
                    Material.background: "Transparent"

                    // 强制视觉位移偏左
                    transform: Translate { x: -10 }

                    text: qsTr("\u2190 Home")
                    font.pointSize: 18

                    onClicked: {
                        console.log("[User Click] Back Button Clicked");

                        // 在此页面新建object，仍然名为stackViewPass
                        // 然后方法里面传进来从Main.qml传了三层的stackViewPass，然后一口气popout
                        detailPage.stackViewPass.pop(stackViewPass.initialItem); // back to homepage
                    }
                }

                // 分隔空间
                Item {
                    Layout.fillWidth: true
                }

                Button {
                    id: topEditButton
                    icon.name: "edit"

                    onClicked: {
                        console.log("[User Click] Edit Button Clicked");
                        if (editDialogLoader.item) {
                            editDialogLoader.item.openWithValues(detailPage.itemName, detailPage.totalPrice, detailPage.purchaseDate);
                        }
                    }

                    Text {
                        anchors.horizontalCenter: topEditButton.horizontalCenter
                        anchors.verticalCenter: topEditButton.verticalCenter
                        text: qsTr("Edit")
                        font.pointSize: 18
                    }
                }

                // right margin in top navi bar
                Item {
                    width: 8
                }
            }
        }

        // 项目标题行，包括项目名称
        Text {
            id: itemTitleText
            text: detailPage.itemName
            font.bold: true
            font.pointSize: 25
            font.letterSpacing: 0.4
            color: "#1F2D3D"
            Layout.bottomMargin: -8

            Layout.alignment: Qt.AlignHCenter
        }

        // 项目价格行，包括平均到每天的价格
        Text {
            id: pricePerDayText
            text: {
                const validDays = Math.max(1, detailPage.passedDays);
                const dailyCost = detailPage.totalPrice / validDays;

                // 价格栏根据当前货币显示符号
                const formatted = currencyManager.currentCurrencyIndex >= 0 ? currencyManager.formatFromUSD(dailyCost) : "$" + dailyCost.toFixed(2);
                return qsTr("Daily Cost: %1").arg(formatted);
            }
            font.bold: true
            font.pointSize: 20
            font.letterSpacing: 0.2
            color: "#FB8C00"
            Layout.topMargin: -4

            Layout.alignment: Qt.AlignHCenter
        }

        // 当前圆圈所在位置的横坐标、纵坐标显示
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 0

            Text {
                id: currentPointInfoText
                visible: expenseVisualizationGraph.hasCurrentPoint
                anchors.horizontalCenter: parent.horizontalCenter
                y: 2
                width: detailPage.width - 32
                text: qsTr("Current Date: %1 | Cost of Current Point: %2").arg(expenseVisualizationGraph.currentPointDate).arg(expenseVisualizationGraph.currentPointCost)
                wrapMode: Text.WrapAnywhere
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 14
                color: "#546E7A"
            }
        }

        // expense visualization 图表
        ExpenseGraph {
            id: expenseVisualizationGraph
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.preferredHeight: 250
            totalExpense: currencyManager.currentCurrencyIndex >= 0 ? currencyManager.convertFromUSD(detailPage.totalPrice) : detailPage.totalPrice
            passedDays: detailPage.passedDays
            currencyCode: currencyManager.currentCurrencyCode
        }

        // 分隔空间
        Item {
            Layout.preferredHeight: 0
        }

        // 项目详情card，包括项目总价、项目购买日期、项目passed days
        Rectangle {
            id: itemDetailsCard
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.preferredHeight: cardContnet.implicitHeight + 16 + 16 // content height + (top and bottom) margin

            radius: 16
            color: "#E3F2FD" // light blue

            Column {
                id: cardContnet
                anchors.fill: itemDetailsCard
                anchors.margins: 16
                spacing: 8

                // 第一行：total price
                RowLayout {
                    width: parent.width

                    // 名称左对齐
                    Text {
                        text: qsTr("Total Price")
                        font.pointSize: 17
                        color: Material.foreground
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // 数据右对齐
                    Text {
                        // 判断当前货币，并调用formatFromUSD 来显示当前的货币符号
                        text: currencyManager.currentCurrencyIndex >= 0 ? currencyManager.formatFromUSD(totalPrice) : "$" + totalPrice
                        font.pointSize: 17
                        color: Material.foreground
                        horizontalAlignment: Text.AlignRight
                    }
                }

                // 浅灰色分割线
                Rectangle {
                    height: 1
                    width: parent.width
                    y: Math.round(y) // fix into int pixel point
                    antialiasing: false
                    color: "#B0BEC5"
                }

                // 第二行：purchase date
                RowLayout {
                    width: parent.width

                    // 名称左对齐
                    Text {
                        text: qsTr("Purchase Date")
                        font.pointSize: 17
                        color: Material.foreground
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // 数据右对齐
                    Text {
                        text: Qt.formatDate(purchaseDate, "yyyy-MM-dd")
                        font.pointSize: 17
                        color: Material.foreground
                        horizontalAlignment: Text.AlignRight
                    }
                }
                // 浅灰色分割线
                Rectangle {
                    height: 1
                    width: parent.width
                    y: Math.round(y) // fix into int pixel point
                    antialiasing: false
                    color: "#B0BEC5"
                }

                // 第三行：passed days
                RowLayout {
                    width: parent.width

                    // 名称左对齐
                    Text {
                        text: qsTr("Passed Days")
                        font.pointSize: 17
                        color: Material.foreground
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // 数据右对齐
                    Text {
                        text: passedDays
                        font.pointSize: 17
                        color: Material.foreground
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }

        // 分隔空间
        Item {
            Layout.fillHeight: true
        }

        // 删除按钮
        Button {
            id: deleteButton
            width: detailPage.width / 2
            Layout.alignment: Qt.AlignHCenter
            Material.background: Material.Pink
            Material.foreground: "white"

            text: qsTr("Delete Item")
            font.pointSize: 18
            font.bold: true

            onClicked: {
                console.log("[User Click] Delete Button Clicked");
                if (detailPage.itemIndex == -1) {
                    console.log("[Error] Invalid item index for delete");
                    return;
                }

                if (!itemListModel.deleteItem(detailPage.itemIndex)) {
                    console.log("[Error] Failed to delete item");
                    return;
                }

                if (detailPage.stackViewPass) {
                    detailPage.stackViewPass.pop(detailPage.stackViewPass.initialItem); // back to homepage
                }
            }
        }

        // 分隔空间
        Item {
            height: 16
        }
    }
}
