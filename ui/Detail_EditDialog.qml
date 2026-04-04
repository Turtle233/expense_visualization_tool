import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

Dialog {
    id: detailEditDialog
    modal: true
    dim: true
    width: Overlay.overlay.width * 0.85
    anchors.centerIn: Overlay.overlay

    title: qsTr("Edit Current Item")

    standardButtons: Dialog.Save | Dialog.Cancel

    property date selectedDate: new Date();

    // pass in existed parameters into the dialog, and pass out after edited
    signal editItemRequested(string itemName, string itemExpense, string purchaseDateText)

    function openWithValues(currentItemName, currentExpense, currentPurchaseDate) {
        itemNameField.text = currentItemName

        const parsedExpense = Number(currentExpense)
        const convertedExpense = currencyManager.convertFromUSD(parsedExpense)

        expenseField.text = Number.isFinite(convertedExpense)
                ? convertedExpense.toFixed(2)
                : String(currentExpense)

        selectedDate = new Date(currentPurchaseDate.getFullYear(),
                                currentPurchaseDate.getMonth(),
                                currentPurchaseDate.getDate())

        detailEditDialog.open()
    }

    // dialog main part
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

            text: qsTr("Purchase Date: %1")
                        .arg(Qt.formatDate(detailEditDialog.selectedDate, "yyyy-MM-dd"))

            font.pointSize: 16
            color: Material.foreground
        }

        // purchase date popup window activate Button
        DateTimePicker {
            id: dateTimePicker
            buttonText: qsTr("Choose Purchase Date")
            Layout.fillWidth: true
            Layout.topMargin: -2
            selectedDate: detailEditDialog.selectedDate
            onDateSelected: function(date){
                detailEditDialog.selectedDate = date
            }
        }

    }

    onAccepted: {
        console.log("[User Input] Item Name:", itemNameField.text)
        console.log("[User Input] Item Expense:", expenseField.text)

        // pass back the edited parameters
        detailEditDialog.editItemRequested(
                    itemNameField.text,
                    expenseField.text,
                    Qt.formatDate(detailEditDialog.selectedDate, "yyyy-MM-dd"))

        // clear the input values after value pass
        itemNameField.text = ""
        expenseField.text = ""
    }

    onRejected: {
        // clear the input values
        itemNameField.text = ""
        expenseField.text = ""
    }
}

