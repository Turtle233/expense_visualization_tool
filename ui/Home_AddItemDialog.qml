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

    standardButtons: Dialog.Save | Dialog.Cancel

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

    onAccepted: {
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
