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
    property real weeklyCost: 0
    property real monthlyCost: 0
    property real yearlyCost: 0

    property StackView stackViewPass
    property var itemDelegateRef

    function refreshCostScales() {
        detailPage.weeklyCost = itemListModel.weeklyCostAt(detailPage.itemIndex);
        detailPage.monthlyCost = itemListModel.monthlyCostAt(detailPage.itemIndex);
        detailPage.yearlyCost = itemListModel.yearlyCostAt(detailPage.itemIndex);
    }

    // connected to the edit dialog
    function applyEdit(itemNameText, expenseText, purchaseDateText) {
        if (detailPage.itemIndex == -1) {
            console.log("[Error] Invalid item index for edit");
            return;
        }

        const normalizedItemName = itemNameText.trim();
        const updatedExpense = currencyManager.parseAmountToUSD(expenseText);
        const updatedPurchaseDate = new Date(purchaseDateText + "T00:00:00");

        if (!itemListModel.updateItem(detailPage.itemIndex, normalizedItemName, updatedExpense.toFixed(6), purchaseDateText)) {
            console.log("[Error] Failed to update item");
            return;
        }

        detailPage.itemName = normalizedItemName;
        detailPage.totalPrice = updatedExpense;
        detailPage.purchaseDate = updatedPurchaseDate;
        detailPage.passedDays = itemListModel.passedDaysAt(detailPage.itemIndex);
        detailPage.refreshCostScales();
    }

    Component.onCompleted: detailPage.refreshCostScales()

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
        spacing: 14 // 所有详情页面元素的间隔

        // 顶部导航栏，包括返回和编辑按钮
        Rectangle {
            id: topNaviBar
            height: 80 // 导航栏高度，写固定值，与Home_Page统一
            Layout.fillWidth: true
            color: "transparent"

            Layout.bottomMargin: -8 // 把下面的内容往上提

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
                    transform: Translate {
                        x: -10
                    }

                    text: qsTr("\u2190 Home")
                    font.pointSize: 18
                    font.bold: true

                    onClicked: {
                        console.log("[User Click] Back Button Clicked");

                        // 在此页面新建object，仍然名为stackViewPass
                        // 然后方法里面传进来从Main.qml传了三层的stackViewPass，然后一口气popout
                        detailPage.stackViewPass.pop(stackViewPass.initialItem); // back to homepage
                    }
                }

                // 分隔空间（横向）
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
                        color: Material.foreground
                    }
                }

                // right margin in top navi bar
                Item {
                    width: 8
                }
            }
        }

        // 项目标题行，显示项目名称
        Text {
            id: itemTitleText
            text: detailPage.itemName
            font.bold: true
            font.pointSize: 25
            font.letterSpacing: 0.4
            color: Material.foreground // 原color: "#1F2D3D"

            Layout.topMargin: -2 // 向上靠一些
            Layout.bottomMargin: -6
            Layout.alignment: Qt.AlignHCenter
        }

        // 项目价格行，显示Daily Cost
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

            axisColor: Material.foreground // 传当前主题颜色，让坐标轴绘制时更新
        }

        // 分隔空间
        Item {
            Layout.preferredHeight: 0
        }

        // 详情页的两个卡片包进同一个容器中，单独调整间距
        Rectangle {
            id: detailsCardsContainer
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.topMargin: -12
            Layout.preferredHeight: detailsCardsLayout.implicitHeight
            color: "transparent"

            ColumnLayout {
                id: detailsCardsLayout
                anchors.fill: parent
                spacing: 0

                // 项目详情card，包括项目总价、项目购买日期、项目passed days
                Rectangle {
                    id: itemDetailsCard
                    Layout.fillWidth: true
                    Layout.leftMargin: 0
                    Layout.rightMargin: 0
                    Layout.topMargin: 0
                    Layout.preferredHeight: cardContnet.implicitHeight + 16 + 16 // content height + (top and bottom) margin

                    radius: 16
                    color: Window.window ? Window.window.panelColor : "#E3F2FD" // light blue

                    // 边框
                    border.color: Window.window ? Window.window.borderColor : "#CFD8DC"
                    border.width: 1

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
                                color: Window.window ? Window.window.panelTitleTextColor : Material.foreground
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            // 数据右对齐
                            Text {
                                // 判断当前货币，并调用formatFromUSD 来显示当前的货币符号
                                text: currencyManager.currentCurrencyIndex >= 0 ? currencyManager.formatFromUSD(totalPrice) : "$" + totalPrice
                                font.pointSize: 17
                                color: Window.window ? Window.window.panelTitleTextColor : Material.foreground
                                horizontalAlignment: Text.AlignRight
                            }
                        }

                        // 浅灰色分割线
                        Rectangle {
                            height: 1
                            width: parent.width
                            y: Math.round(y) // fix into int pixel point
                            antialiasing: false
                            color: Window.window ? Window.window.lineColor : "#B0BEC5"
                        }

                        // 第二行：purchase date
                        RowLayout {
                            width: parent.width

                            // 名称左对齐
                            Text {
                                text: qsTr("Purchase Date")
                                font.pointSize: 17
                                color: Window.window ? Window.window.panelTitleTextColor : Material.foreground
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            // 数据右对齐
                            Text {
                                text: Qt.formatDate(purchaseDate, "yyyy-MM-dd")
                                font.pointSize: 17
                                color: Window.window ? Window.window.panelTitleTextColor : Material.foreground
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                        // 浅灰色分割线
                        Rectangle {
                            height: 1
                            width: parent.width
                            y: Math.round(y) // fix into int pixel point
                            antialiasing: false
                            color: Window.window ? Window.window.lineColor : "#B0BEC5"
                        }

                        // 第三行：passed days
                        RowLayout {
                            width: parent.width

                            // 名称左对齐
                            Text {
                                text: qsTr("Passed Days")
                                font.pointSize: 17
                                color: Window.window ? Window.window.panelTitleTextColor : Material.foreground
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            // 数据右对齐
                            Text {
                                text: passedDays
                                font.pointSize: 17
                                color: Window.window ? Window.window.panelTitleTextColor : Material.foreground
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }

                // 分隔空间，两个卡片之间的间隔固定
                Item {
                    height: 10
                }

                // 项目支出Card，包括每周支出、每月支出、每年支出
                Rectangle {
                    id: costDetailsCard
                    Layout.fillWidth: true
                    Layout.leftMargin: 0
                    Layout.rightMargin: 0
                    Layout.topMargin: 0
                    Layout.preferredHeight: costCardContent.implicitHeight + 16 + 16

                    radius: 16
                    color: Window.window ? Window.window.panelColor : "#E3F2FD"

                    // 边框
                    border.color: Window.window ? Window.window.borderColor : "#CFD8DC"
                    border.width: 1

                    Column {
                        id: costCardContent
                        anchors.fill: costDetailsCard
                        anchors.margins: 16
                        spacing: 8

                        // 第一行：周均支出
                        RowLayout {
                            width: parent.width

                            // 文字左对齐
                            Text {
                                text: qsTr("Weekly Cost")
                                font.pointSize: 17
                                color: Window.window ? Window.window.panelTitleTextColor : Material.foreground
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            // 数据右对齐
                            Text {
                                text: currencyManager.currentCurrencyIndex >= 0 ? currencyManager.formatFromUSD(detailPage.weeklyCost) : "$" + detailPage.weeklyCost.toFixed(2)
                                font.pointSize: 17
                                color: Window.window ? Window.window.panelTitleTextColor : Material.foreground
                                horizontalAlignment: Text.AlignRight
                            }
                        }

                        // 浅灰色分割线
                        Rectangle {
                            height: 1
                            width: parent.width
                            y: Math.round(y) // fix into int pixel point
                            antialiasing: false
                            color: Window.window ? Window.window.lineColor : "#B0BEC5"
                        }

                        // 第二行：周均支出
                        RowLayout {
                            width: parent.width

                            Text {
                                text: qsTr("Monthly Cost")
                                font.pointSize: 17
                                color: Window.window ? Window.window.panelTitleTextColor : Material.foreground
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: currencyManager.currentCurrencyIndex >= 0 ? currencyManager.formatFromUSD(detailPage.monthlyCost) : "$" + detailPage.monthlyCost.toFixed(2)
                                font.pointSize: 17
                                color: Window.window ? Window.window.panelTitleTextColor : Material.foreground
                                horizontalAlignment: Text.AlignRight
                            }
                        }

                        // 浅灰色分割线
                        Rectangle {
                            height: 1
                            width: parent.width
                            y: Math.round(y) // fix into int pixel point
                            antialiasing: false
                            color: Window.window ? Window.window.lineColor : "#B0BEC5"
                        }

                        // 第三行：年均支出
                        RowLayout {
                            width: parent.width

                            Text {
                                text: qsTr("Yearly Cost")
                                font.pointSize: 17
                                color: Window.window ? Window.window.panelTitleTextColor : Material.foreground
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: currencyManager.currentCurrencyIndex >= 0 ? currencyManager.formatFromUSD(detailPage.yearlyCost) : "$" + detailPage.yearlyCost.toFixed(2)
                                font.pointSize: 17
                                color: Window.window ? Window.window.panelTitleTextColor : Material.foreground
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }
        }

        // 分隔空间
        Item {
            Layout.preferredHeight: 0
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
            height: 18
        }
    }
}
