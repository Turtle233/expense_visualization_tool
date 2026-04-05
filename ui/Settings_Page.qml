import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

Item {
    id: settingsRoot
    property string projectLink: "https://github.com/Turtle233/expense_visualization_tool"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // 大标题
        Text {
            text: qsTr("Settings")
            font.pointSize: 24
            font.bold: true
            color: Material.foreground
        }

        // 一个大的隐形矩形，包含ColumnLayout（内包含Currency方块）
        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: "#E3F2FD"
            border.color: "#CFD8DC"
            border.width: 1
            implicitHeight: currencyColumn.implicitHeight + 24

            ColumnLayout {
                id: currencyColumn
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Text {
                    text: qsTr("Currency")
                    font.pointSize: 16
                    font.bold: true
                    color: Material.foreground
                }

                // 下拉菜单
                ComboBox {
                    Layout.fillWidth: true
                    model: currencyManager.currencyOptions()
                    currentIndex: currencyManager.currentCurrencyIndex
                    onActivated: function (index) {
                        currencyManager.currentCurrencyIndex = index;
                    }
                }
            }
        }

        // 一个大的隐形矩形，包含ColumnLayout（内包含Language方块）
        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: "#E3F2FD"
            border.color: "#CFD8DC"
            border.width: 1
            implicitHeight: languageColumn.implicitHeight + 24

            ColumnLayout {
                id: languageColumn
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Text {
                    text: qsTr("Language")
                    font.pointSize: 16
                    font.bold: true
                    color: Material.foreground
                }

                // 下拉菜单
                ComboBox {
                    Layout.fillWidth: true
                    model: languageManager.languageOptions()
                    currentIndex: languageManager.currentLanguageIndex
                    onActivated: function (index) {
                        languageManager.currentLanguageIndex = index;
                    }
                }
            }
        }

        // 分割空间
        Item {
            Layout.fillHeight: true
        }

        // 作者信息栏
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                Layout.fillWidth: true
                text: qsTr("See your Cost\nNSU CapStone Project App\nRuixuan Zhang\n2026/01 - 2026/04")
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                color: "#607D8B"
            }

            // 项目链接栏
            Text {
                Layout.fillWidth: true
                Layout.topMargin: -4
                text: qsTr("Project Link")
                horizontalAlignment: Text.AlignHCenter
                color: "#1E88E5"
                font.underline: true

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Qt.openUrlExternally(settingsRoot.projectLink);
                    }
                }
            }
        }
    }
}
