import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

ApplicationWindow {
    // ---------------------------------------homepage window---------------------------------------
    id: mainWindow
    visible: true
    width: 360
    height: 740
    title: qsTr("See Expense")

    // Material Design initialization
    Material.theme: Material.Light
    Material.accent: Material.Blue

    // 跳转StackView
    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: Home_Page {
            // 第一层继承，所有子类全部用这里的stackViewPass对象。
            // 让stackViewPass来显示继承stackView，因为stackView不能嵌套传递。
            // StackView的原理是在push时传一个实例，记录一个点位，这样pop时就会依据这个实例去popout.
            stackViewPass: stackView
        }
    }
}
