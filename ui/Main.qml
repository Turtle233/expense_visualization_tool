import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 360
    height: 740
    title: qsTr("See your Cost")


    // ——————————————————————————————————————默认配色部分——————————————————————————————————————————
    // 这是在 item list panel, detail page panel, settings panel 贯穿的全局默认配色
    property color panelColor: "#E3F2FD"
    // 这是在 add button 和 滚动条的默认配色
    property color buttonColor: "skyblue"
    // 这是链接的默认配色
    property color linkColor: "#1E88E5"

    // (this part was coded by Codex) 根据彩蛋颜色的深浅程度，动态计算当前标题文字颜色，以及小文字的颜色
    readonly property real panelLuma: (0.299 * panelColor.r) + (0.587 * panelColor.g) + (0.114 * panelColor.b) // 实时刷新值，为当前对比度值。luma值越小，颜色越暗。
    readonly property bool panelColorIsDark: panelLuma < 0.6 // 当前对比度值小于对比度基准值的，被判断为暗色（白字）；大于对比度基准值的，被判断为亮色（黑字）。
    property color panelTitleTextColor: panelColorIsDark ? "white" : Material.foreground // 暗色取白色字，亮色取系统默认值（黑字）
    property color panelInfoTextColor: panelColorIsDark ? "white" : "#607D8B" // 暗色取白色字，亮色取淡灰色

    // Android Material Design color default setting    
    Material.theme: Material.Light
    Material.accent: Material.Blue
    // —————————————————————————————————————————————————————————————————————————————————————————————

    // 开屏时，有一个0.3s的淡入动画
    Item {
        id: startupFadeLayer
        anchors.fill: parent
        opacity: 0

        Component.onCompleted: opacity = 1

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        // 第一层继承，所有子类全部用这里的stackViewPass对象。
        // 让stackViewPass来显示继承stackView，因为stackView不能嵌套传递。
        // StackView的原理是在push时传一个实例，记录一个点位，这样pop时就会依据这个实例去popout.
        StackView {
            id: stackView
            anchors.fill: parent

            initialItem: Home_Page {
                stackViewPass: stackView
            }
        }
    }
}
