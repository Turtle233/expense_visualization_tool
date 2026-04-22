import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import QtCore

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 360
    height: 740
    title: qsTr("See your Cost")

    Color {
        id: themeColor
    }

    // color properties 连接UI的各个控件
    property color panelColor: themeColor.panelColor
    property color buttonColor: themeColor.buttonColor
    property color linkColor: themeColor.linkColor
    property color lineColor: themeColor.lineColor
    property color borderColor: themeColor.borderColor
    property color panelTitleTextColor: themeColor.panelTitleTextColor
    property color panelInfoTextColor: themeColor.panelInfoTextColor

    // Color.qml 传过来的属性，并非具体值
    property var themeColor: themeColor
    property int selectedColorIndex: themeColor.selectedColorIndex

    // Android Material Design color setting switch
    property int accentIndex : themeColor.selectedColorIndex

    Material.accent: accentIndex === 0 ? Material.Blue : // default (light colors are not using secondary theme color as material accent)
                     accentIndex === 1 ? "#FFE500" : // yellow (light colors are not using secondary theme color as material accent)
                     accentIndex === 2 ? "#D7ECFF" : // sea blue
                     accentIndex === 3 ? "#DDF7E8" : // green
                     accentIndex === 4 ? "#FFE0EF" : // pink
                     "#FFE4D6" // (accentIndex 5) orange

    Material.theme: accentIndex === 0 ? Material.Light : // default
                    accentIndex === 1 ? Material.Light : // yellow
                    accentIndex === 2 ? Material.Dark : // sea blue
                    accentIndex === 3 ? Material.Dark : // green
                    accentIndex === 4 ? Material.Dark : // pink
                    Material.Dark // (accentIndex 5) orange

    // —————————————————————————————————————————————————————————————————————————————————————————————

    // 开屏时，有一个0.3s的淡入动画
    Item {
        id: startupFadeLayer
        anchors.fill: parent
        opacity: 0

        Component.onCompleted: opacity = 1

        Behavior on opacity {
            NumberAnimation {
                duration: 300
            }
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
