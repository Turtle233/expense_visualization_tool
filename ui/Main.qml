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

    Material.theme: Material.Light
    Material.accent: Material.Blue

    Item {
        id: startupFadeLayer
        anchors.fill: parent
        opacity: 0

        Component.onCompleted: opacity = 1

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        StackView {
            id: stackView
            anchors.fill: parent

            initialItem: Home_Page {
                stackViewPass: stackView
            }
        }
    }
}
