import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

Item {
    id: settingsRoot
    property string projectLink: "https://github.com/Turtle233/expense_visualization_tool"

    // color 彩蛋，基于Android Material Design Color Sets
    readonly property var accentValues: [Material.Blue, Material.Teal, Material.DeepOrange,
        Material.Pink, Material.Green, Material.Grey,
        Material.Cyan, Material.DeepPurple, Material.DeepPurple,
        Material.Dark, Material.Indigo, Material.Orange,
        Material.Red, Material.Teal, Material.Yellow]

    // Color 色块预览色
    readonly property var accentPreviewColors: ["#2196F3", "#009688", "#FF5722",
        "#E91E63", "#4CAF50", "#9E9E9E",
        "#00BCD4", "#673AB7", "#673AB7",
        "#212121", "#3F51B5", "#FF9800",
        "#F44336", "#009688", "#FFEB3B"]
    property int currentAccentIndex: 0
    property real colorTileOpacity: 0.0

    // 为 combobox 下拉菜单的字体文本单独配置，因为使用了Material foreground

    // Color 色块默认隐藏，用户误触才能发现
    Timer {
        id: colorTileFadeTimer
        interval: 1200
        repeat: false
        onTriggered: settingsRoot.colorTileOpacity = 0.0
    }

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
            color: Window.window ? Window.window.panelColor : "#E3F2FD"
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
                    color: Window.window.panelTitleTextColor;
                }

                // 下拉菜单
                ComboBox {
                    Layout.fillWidth: true
                    model: currencyManager.currencyOptions()

                    // 我没有能成功让combox的文字颜色也根据对比度luma值动态切换，因为它与Material深度绑定。
                    // contentItem: Text {
                    //     text: control.displayText
                    //     color: "skyblue"  // 仅动态切换combo box的文字颜色（黑或白）
                    //     verticalAlignment: Text.AlignVCenter
                    //     elide: Text.ElideRight
                    // }

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
            color: Window.window ? Window.window.panelColor : "#E3F2FD"
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
                    color: Window.window.panelTitleTextColor;
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

        // Color 色块框框
        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: Window.window ? Window.window.panelColor : "#E3F2FD"
            border.color: "#CFD8DC"
            border.width: 1
            implicitHeight: 64
            opacity: settingsRoot.colorTileOpacity

            // 默认隐藏喵
            Behavior on opacity {
                NumberAnimation { duration: 220 }
            }

            Text {
                anchors.centerIn: parent
                text: qsTr("color?!")
                font.pointSize: 16
                font.bold: true
                color: Window.window ? Window.window.panelTitleTextColor : Material.foreground
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    const hostWindow = settingsRoot.Window.window;
                    if (!hostWindow || settingsRoot.accentValues.length === 0) {
                        return;
                    }

                    // (this part had bugs and was resolved by Codex) 15种颜色的出现是随机的喵
                    let nextIndex = Math.floor(Math.random() * settingsRoot.accentValues.length);
                    if (settingsRoot.accentValues.length > 1) {
                        while (nextIndex === settingsRoot.currentAccentIndex) {
                            nextIndex = Math.floor(Math.random() * settingsRoot.accentValues.length);
                        }
                    }

                    settingsRoot.currentAccentIndex = nextIndex;
                    hostWindow.Material.accent = settingsRoot.accentValues[nextIndex];
                    hostWindow.panelColor = settingsRoot.accentPreviewColors[nextIndex];
                    hostWindow.buttonColor = settingsRoot.accentPreviewColors[nextIndex];
                    hostWindow.linkColor = settingsRoot.accentPreviewColors[nextIndex];
                    settingsRoot.colorTileOpacity = 1.0;
                    
                    colorTileFadeTimer.restart();
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
                color: Window.window ? Window.window.linkColor : "#87CEEB"
                // color: "#87CEEB" // "#87CEEB" is default link color
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
