import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

Item {
    id: homeItemList
    property StackView stackViewPass
    property bool editMode: false // downcasting from headerbar -> homepage -> itemlist

    ListView {
        id: itemListView
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        // clip: true // 防止 ListView 超出 Item 的边界
        model: itemListModel

        // ———————————————————————————————————————————添加与删除的过渡效果—————————————————————————————————————————————————
        // animation of item adding (longer because add item dialog also have pop out animation)
        add: Transition {
            // 先顺序执行，等待 addItemDialog 的动画走完再播放add item rect的动画
            SequentialAnimation {
                // // firstly wait for addItemDialog disappear
                // PauseAnimation {
                //     duration: 100
                // }

                // run two animes together
                ParallelAnimation {
                    // 淡入
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 360
                        easing.type: Easing.OutCubic
                    }

                    // 缩放变大
                    NumberAnimation {
                        property: "scale"
                        from: 0.9
                        to: 1
                        duration: 360
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        // animation of item removing (shorter)
        remove: Transition {
            // run two animes together
            ParallelAnimation {
                // 淡出
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: 180
                    easing.type: Easing.OutCubic
                }

                // 缩放变小
                NumberAnimation {
                    property: "scale"
                    from: 1
                    to: 0.9
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }
        }

        // animation of other items when adding new item
        addDisplaced: Transition {
            NumberAnimation {
                property: "y"
                duration: 360
                easing.type: Easing.OutCubic
            }
        }

        // animation of other items when removing item
        removeDisplaced: Transition {
            NumberAnimation {
                property: "y"
                duration: 360
                easing.type: Easing.OutCubic
            }
        }

        // ———————————————————————————————————————————ListView 矩形与RowLayout—————————————————————————————————————————————————

        // set the template rectangle for every item
        delegate: Rectangle {
            id: rootItemRect

            // value pass in
            required property int index
            required property string itemName
            required property real totalExpense
            required property string totalExpenseText
            required property string purchaseDateText
            required property int passedDays

            width: itemListView.width
            radius: 14
            color: "#E3F2FD"
            border.color: "#CFD8DC"
            border.width: 1
            implicitHeight: 96

            // clip: true

            // opacity: 0 // set default opacity to 0
            // scale: 0.9 // set default scale to 0.9

            //——————————————————当有新项目添加时，自动滚动到当前项目位置并居中，并播放红色边框动画——————————————————
            // // 为防止item数量溢出屏幕而自动切换到new item时丢失item的添加动画，手写一个Timer强制等待
            // Timer {
            //     id: itemLoadTimer
            //     interval: 380
            //     running: true
            //     repeat: false

            //     onTriggered: {
            //            itemListView.positionViewAtIndex(index, ListView.Center)
            //     }
            // }

            ListView.onAdd: {
                // 延迟加载（亲测直接加载有bug）
                // itemLoadTimer.start()

                Qt.callLater(() => {
                    itemListView.positionViewAtEnd();
                // itemListView.positionViewAtIndex(index, ListView.Center)
                });

                newItemHighlightAnimation.restart();
            }

            // ———————————————————光标按下时变浅, 退出时再闪消失(white transparent mask)———————————————————
            // property real returnMaskOpacity: 0.0

            // function triggerReturnFlash() {
            //     returnMaskOpacity = 0.5
            //     returnMaskAnim.restart()
            // }

            Rectangle {
                id: pressMask
                anchors.fill: parent
                radius: parent.radius
                color: "white"
                opacity: itemMouseArea.pressed ? 0.65 : 0.0

                // opacity: Math.max(itemMouseArea.pressed ? 0.5 : 0.0, returnMaskOpacity)
                z: 2
                Behavior on opacity { NumberAnimation { duration: 80 } }
            }

            // NumberAnimation {
            //     id: returnMaskAnim
            //     target: rootItemRect
            //     property: "returnMaskOpacity"
            //     from: 0.5
            //     to: 0.0
            //     duration: 120
            // }

            // ————————————————red border highlight for newly added item————————————————
            // draw a rectangle bordering new item rectangle
            Rectangle {
                id: newItemHighlight
                anchors.fill: parent // cover the parent layer
                color: "transparent"
                radius: parent.radius
                border.color: "#FF8A80"
                border.width: 3
                opacity: 0
                z: 1 // higher rendering priority
            }

            // 顺序执行动画，而非并行动画
            SequentialAnimation {
                id: newItemHighlightAnimation
                running: false

                // 等待 dialog 动画结束
                PauseAnimation {
                    duration: 120
                }

                // 然后立即显示Action
                NumberAnimation {
                    target: newItemHighlight
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 150
                }

                // remain 1s for the user to be aware of
                PauseAnimation {
                    duration: 1000
                }

                // 淡出红色边框
                NumberAnimation {
                    target: newItemHighlight
                    property: "opacity"
                    to: 0
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            // ——————————the data text display row——————————
            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: itemName
                        font.pointSize: 17
                        font.bold: true
                        color: Material.foreground
                    }

                    Text {
                        text: qsTr("Purchase Date: %1").arg(purchaseDateText)
                        font.pointSize: 13
                        color: "#607D8B"
                    }

                    Text {
                        text: qsTr("Passed Days: %1").arg(passedDays)
                        font.pointSize: 13
                        color: "#607D8B"
                    }
                }

                Text {
                    // 判断当前货币，并调用formatFromUSD 来显示当前的货币符号
                    text: currencyManager.currentCurrencyIndex >= 0
                          ? currencyManager.formatFromUSD(totalExpense)
                          : totalExpenseText
                    Layout.alignment: Qt.AlignRight

                    font.pointSize: 16
                    font.bold: true
                    color: Material.foreground
                }
            }

            // ——————————rotation animation when entering edit mode——————————
            rotation: homeItemList.editMode ? -1 : 0 // 首先初始化，进入editMode的时候先偏转一些

            RotationAnimation on rotation {
                running: homeItemList.editMode
                from: -0.8
                to: 0.8
                duration: 100 + Math.random() * 50  // 添加了随机数，确保不是失了智一样一起晃动，也不是从上到下越来越不动，而是各自有自己的频率
                loops: Animation.Infinite
            }

            // ——————————the delete button & its animation when click the edit button (as entering edit mode) on the header bar——————————
            Rectangle {
                id: redDeleteButton
                width: 30
                height: 30
                radius: width / 2
                color: "transparent"

                anchors.top: parent.top
                anchors.right: parent.right

                anchors.topMargin: 4
                anchors.rightMargin: 4

                // anchors.topMargin: -width/2 // set minus margin, so that the red delete button will show at the corner, half inside, half outside
                // anchors.rightMargin: -height/2

                visible: homeItemList.editMode

                Text {
                    anchors.centerIn: parent
                    text: "❌️"
                    font.bold: true
                    font.pointSize: 15
                }

                // animation of scale and opacity when getting into and getting out of edit mode
                scale: homeItemList.editMode ? 1 : 0.4  // mutual 变大变小
                opacity: homeItemList.editMode ? 1 : 0  // mutual 淡入淡出

                Behavior on scale {
                    NumberAnimation {
                        duration: 160
                        easing.type: homeItemList.editMode ? Easing.OutBack // true 进入为弹入
                        : Easing.OutCubic // false 退出为平滑收回
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 160
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        if (!itemListModel.deleteItem(index)) {
                            console.log("[Error] No item here! Failed to delete item from home edit mode.");
                        } else {
                            console.log("[User Click] Red delete button in the list clicked");
                        }
                    }
                }
            }

            // ————————————————————————————————————————————————————
            // when clicking a specific item
            MouseArea {
                id: itemMouseArea
                anchors.fill: parent
                enabled: !homeItemList.editMode

                onClicked: {
                    // stackview 传递所有信息 pass the value passed from item.cpp into detail page
                    homeItemList.stackViewPass.push(Qt.resolvedUrl("Detail_Page.qml"), {
                        itemIndex: index,
                        stackViewPass: homeItemList.stackViewPass,
                        itemDelegateRef: rootItemRect,
                        itemName: itemName,
                        totalPrice: totalExpense,
                        purchaseDate: new Date(purchaseDateText + "T00:00:00"),
                        passedDays: passedDays
                    });
                }
            }
        }

        // ——————————————————自定义了一下滚动条——————————————————
        ScrollBar.vertical: ScrollBar {
            id: itemListScrollBar
            parent: homeItemList
            active: itemListView.moving || pressed || fadeTimer.running
            // policy: ScrollBar.AsNeeded

            // 直接手写动画了，逻辑有一定问题，滚动栏不会自己消失
            opacity: active ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                }
            }

            // 防止滚动栏刚出现就播放淡出动画，设计等待1秒后退出
            Timer {
                id: fadeTimer
                interval: 1000
                repeat: false
            }

            // 如果用户输入改变了，那么重新计时1秒再fade，否则active为false，opacity->0，播放淡出动画
            onActiveChanged: {
                if (active)
                    fadeTimer.restart();
            }

            implicitWidth: 5 // 建议宽度为5，实际宽度根据运行情况调整

            anchors.top: itemListView.top
            anchors.bottom: itemListView.bottom
            anchors.left: itemListView.right

            anchors.right: homeItemList.right // 虽然在ListView里面，但直接锚点到ItemList上，并加上负值margin，但这样就会贴屏幕边边显示了
            anchors.leftMargin: 6
            anchors.topMargin: 1
            anchors.bottomMargin: 1

            contentItem: Rectangle {
                implicitWidth: 5
                radius: width / 2
                color: "skyblue"
            }

            background: Rectangle {
                color: "transparent"
            }
        }
    }

    // if there is no item in the item list
    Text {
        anchors.centerIn: parent
        text: qsTr("No item yet. Click + to add one")
        visible: itemListView.count === 0
        color: "#90A4AE"
        font.pointSize: 15
    }
}
