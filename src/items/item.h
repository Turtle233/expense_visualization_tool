/* Notice:

 * Some parts of this item.h was optimized with the help of Codex extension in VSCode.
 * The prompt I used was similar to:
 * # Optimize my current item data and signal logic to make them more production-ready and comprehensive.

*/

#pragma once

#include <QAbstractListModel>
#include <QDate>
#include <QString>
#include <QVector>

class ItemListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit ItemListModel(QObject *parent = nullptr);

    enum ItemRoles {
        ItemNameRole = Qt::UserRole + 1,
        TotalExpenseRole,
        TotalExpenseTextRole,
        PurchaseDateRole,
        PurchaseDateTextRole,
        PassedDaysRole
    };
    Q_ENUM(ItemRoles)

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE bool addItem(const QString &itemName,
                             const QString &expenseText,
                             const QString &purchaseDateText);
    Q_INVOKABLE bool updateItem(int index,
                                const QString &itemName,
                                const QString &expenseText,
                                const QString &purchaseDateText);
    Q_INVOKABLE bool deleteItem(int index);
    Q_INVOKABLE int passedDaysAt(int index) const;
    Q_INVOKABLE void clear();
    Q_INVOKABLE void sortByDateAscending();
    Q_INVOKABLE void sortByDateDescending();
    Q_INVOKABLE void sortByNameAscending();
    Q_INVOKABLE void sortByNameDescending();

private:
    // one record in the list model
    struct ItemRecord
    {
        QString itemName;
        double totalExpense = 0.0;
        QDate purchaseDate;
    };

    // local JSON read/write
    void loadFromFile();
    void saveToFile() const;

    QString m_dataFilePath;
    QVector<ItemRecord> m_items;
};
