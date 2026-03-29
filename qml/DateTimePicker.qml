import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

Item {
    id: root
    Layout.fillWidth: true
    implicitHeight: triggerButton.implicitHeight

    property date selectedDate: new Date()
    property string buttonText: qsTr("Choose Purchase Date")
    property real popupWidthRatio: 0.9
    property int popupHeight: 0
    property int dayCellSize: 42

    signal dateSelected(date pickedDate)

    property date workingDate: new Date()

    function openPicker() {
        workingDate = new Date(selectedDate.getFullYear(),
                               selectedDate.getMonth(),
                               selectedDate.getDate())
        datePopup.open()
    }

    // purchase date popup window activate Button
    Button {
        id: triggerButton
        anchors.left: parent.left
        anchors.right: parent.right
        text: root.buttonText
        font.pointSize: 16
        onClicked: root.openPicker()
    }

    // purchase date value - date-time-picker
    Popup {
        id: datePopup
        modal: true
        parent: Overlay.overlay
        width: root.width * root.popupWidthRatio
        height: root.popupHeight > 0
                ? root.popupHeight
                : pickerColumn.implicitHeight + 20
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        padding: 10

        // 在弹窗中新增一个column放具体部件，包括一个横行显示当前日期，以及切换月份的按钮
        Column {
            id: pickerColumn
            width: parent.width
            spacing: 10

            RowLayout {
                width: parent.width
                spacing: 8

                Button {
                    text: "◀"
                    implicitWidth: 44

                    // 要强调contentItem不然不显示（不知道为什么）
                    contentItem: Text {
                        text: parent.text
                        font.pointSize: 13
                        font.bold: false
                        color: Material.foreground
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        textFormat: Text.PlainText
                    }
                    onClicked: {
                        const y = root.workingDate.getFullYear();
                        const m = root.workingDate.getMonth() - 1;
                        const d = root.workingDate.getDate();
                        const lastDay = new Date(y, m + 1, 0).getDate();
                        root.workingDate = new Date(y, m, Math.min(d, lastDay));
                    }
                }

                // 分隔栏
                Item {
                    Layout.fillWidth: true
                }

                // 当前日期显示行
                Text {
                    text: Qt.formatDate(new Date(root.workingDate.getFullYear(),
                                                 root.workingDate.getMonth(),
                                                 1), "yyyy-MM")
                    font.pointSize: 18
                    font.bold: true
                    color: Material.foreground
                }

                // 分隔栏
                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: "▶"
                    implicitWidth: 44

                    // 要强调contentItem不然不显示（不知道为什么）
                    contentItem: Text {
                        text: parent.text
                        font.pointSize: 13
                        font.bold: false
                        color: Material.foreground
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        textFormat: Text.PlainText
                    }
                    onClicked: {
                        const y = root.workingDate.getFullYear();
                        const m = root.workingDate.getMonth() + 1;
                        const d = root.workingDate.getDate();
                        const lastDay = new Date(y, m + 1, 0).getDate();
                        root.workingDate = new Date(y, m, Math.min(d, lastDay));
                    }
                }
            }

            // 月视图
            MonthGrid {
                id: dateGrid
                width: parent.width
                height: root.dayCellSize * 6
                year: root.workingDate.getFullYear()
                month: root.workingDate.getMonth()
                locale: Qt.locale()
                delegate: Item {
                    required property var model
                    width: Math.floor(dateGrid.width / 7)
                    height: root.dayCellSize

                    property bool isSelected: model.date.getFullYear() === root.workingDate.getFullYear()
                                              && model.date.getMonth() === root.workingDate.getMonth()
                                              && model.date.getDate() === root.workingDate.getDate()
                    property bool isCurrentMonthCell: model.date.getMonth() === dateGrid.month
                                                      && model.date.getFullYear() === dateGrid.year

                    // 选中时有蓝色圆圈
                    Rectangle {
                        anchors.centerIn: parent
                        width: 34
                        height: 34
                        radius: 17
                        color: isSelected ? "#D8ECFF" : "transparent"
                        border.width: isSelected ? 1 : 0
                        border.color: isSelected ? "#90CAF9" : "transparent"
                    }

                    Text {
                        anchors.centerIn: parent
                        text: model.day
                        font.pointSize: 15
                        color: isCurrentMonthCell ? Material.foreground : "#9AA0A6"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.workingDate = model.date;
                        }
                    }
                }
            }

            RowLayout {
                width: parent.width

                Item {
                    Layout.fillWidth: true
                }

                // Confirm按钮放在右下角
                Button {
                    text: qsTr("Confirm")
                    font.pointSize: 16
                    onClicked: {
                        // example: 2026-01-01
                        root.dateSelected(new Date(root.workingDate.getFullYear(),
                                                   root.workingDate.getMonth(),
                                                   root.workingDate.getDate()));
                        datePopup.close();
                    }
                }
            }
        }
    }
}
