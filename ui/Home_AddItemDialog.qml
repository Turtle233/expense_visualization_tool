import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

// ---------------------------------------popup dialog window---------------------------------------
// ------new dialog------
Dialog {
    id: addItemDialog
    modal: true
    dim: true
    width: Overlay.overlay.width * 0.85
    anchors.centerIn: Overlay.overlay
    title: qsTr("New Item")

    // two buttons in the footer of the dialog
    footer: DialogButtonBox {
        id: box
        standardButtons: DialogButtonBox.Save | DialogButtonBox.Cancel
    }

    onVisibleChanged: {
        if (visible) {
            box.standardButton(DialogButtonBox.Save).text = qsTr("Save")
            box.standardButton(DialogButtonBox.Cancel).text = qsTr("Cancel")
        }
    }

    // shared value. when popped up, the default date is set to today
    property date selectedDate: new Date()
    signal addItemRequested(string itemName, string itemExpense, string purchaseDateText)

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 8

        // item name text
        TextField {
            id: itemNameField
            placeholderText: qsTr("Item Name")
            Layout.fillWidth: true
        }

        // item expense text
        TextField {
            id: expenseField
            placeholderText: qsTr("Total Expense (%1)").arg(currencyManager.currentCurrencyCode) // show current currency character
            inputMethodHints: Qt.ImhFormattedNumbersOnly // only allow numbers as input
            Layout.fillWidth: true
        }

        // text label displaying the chosen date by the user
        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignLeft

            text: qsTr("Purchase Date: %1").arg(Qt.formatDate(addItemDialog.selectedDate, "yyyy-MM-dd"))

            font.pointSize: 16
            color: Material.foreground
        }

        // purchase date popup window activate Button
        DateTimePicker {
            id: dateTimePicker
            buttonText: qsTr("Choose Purchase Date")
            Layout.fillWidth: true
            Layout.bottomMargin: -4
            selectedDate: addItemDialog.selectedDate
            onDateSelected: function (date) {
                addItemDialog.selectedDate = date;
            }
        }
    }

    // toast information popup for invalid input
    Popup {
        id: invalidInputToast
        parent: Overlay.overlay
        modal: false
        focus: false
        closePolicy: Popup.NoAutoClose

        // automatic width
        width: Math.min((parent ? parent.width : addItemDialog.width) * 0.9, invalidInputToastText.implicitWidth + 32)
        x: (parent.width - width) / 2
        y: parent.height - height - 72
        padding: 12
        z: 1000

        background: Rectangle {
            radius: 10
            color: "#323232"
            opacity: 0.95
        }

        contentItem: Text {
            id: invalidInputToastText
            text: qsTr("Please type in valid item name, item expense, and purchase date.")
            color: "white"
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // timer for auto close toast
    Timer {
        id: invalidInputToastTimer
        interval: 4000
        repeat: false
        onTriggered: invalidInputToast.close()
    }

    onAccepted: {
        // validate name and expense
        const nameText = itemNameField.text.trim();
        const expenseText = expenseField.text.trim();
        const expenseValue = Number(expenseText);

        // validation function, checking if there is empty value, invalid value, or space/tab value
        if (nameText.length === 0 || !Number.isFinite(expenseValue) || expenseValue <= 0) {
            Qt.callLater(function () {
                addItemDialog.open();
                invalidInputToast.open();
                invalidInputToastTimer.restart();
            });
            return;
        }

        console.log("[User Input] Item Name:", itemNameField.text);
        console.log("[User Input] Item Expense:", expenseField.text);

        // pass back the edited parameters
        addItemDialog.addItemRequested(itemNameField.text, expenseField.text, Qt.formatDate(addItemDialog.selectedDate, "yyyy-MM-dd"));

        // clear the input values after value pass
        itemNameField.text = "";
        expenseField.text = "";
    }

    onRejected: {
        // clear the input values
        itemNameField.text = "";
        expenseField.text = "";
    }
}
// ------end new dialog------
