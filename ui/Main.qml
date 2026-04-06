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
    color: "#f5f5f5"

    // Material Design initialization
    Material.theme: Material.Light
    Material.accent: Material.Blue

    Item {
        id: startupFadeLayer
        anchors.fill: parent
        opacity: 0

        // 【防止闪屏】载入应用时的强制淡入淡出动画
        Component.onCompleted: {
            opacity = 1
        }

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        // stack view for page navigation
        // hint: 第一层继承，所有子类全部用这里的stackViewPass对象。让stackViewPass来显示继承stackView，因为stackView不能嵌套传递。
        // hint_continue: StackView的原理是在push时传一个实例，记录一个点位，这样pop时就会依据这个实例去popout.
        StackView {
            id: stackView
            anchors.fill: parent

            initialItem: Home_Page {
                stackViewPass: stackView
            }
        }
    }
}
