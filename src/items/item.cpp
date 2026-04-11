/* Notice:

 * Some parts of this item.cpp was optimized with the help of Codex extension in VSCode.
 * The prompt I used was similar to:
 * # Optimize my current item data and signal logic to make them more production-ready and comprehensive.

*/

#include "item.h"
#include "calculation/calculation.h"
#include "sorting/sorting.h"

#include <algorithm>
#include <QDir>
#include <QFile>
#include <QIODevice>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

// ---------------------------------------helper functions begins---------------------------------------
namespace
{
    // keep data in ./data/itemData.json under current project folder
    QString resolveDataFilePath()
    {
        QDir dir(QDir::currentPath());
        dir.mkpath(QStringLiteral("data"));
        return dir.filePath(QStringLiteral("data/itemData.json"));
    }

    // validation: name, expense, date
    bool parseItemInput(const QString &itemName,
                        const QString &expenseText,
                        const QString &purchaseDateText,
                        QString &normalizedName,
                        double &totalExpense,
                        QDate &purchaseDate)
    {
        normalizedName = itemName.trimmed();
        if (normalizedName.isEmpty())
        {
            return false;
        }

        QString normalizedExpense = expenseText.trimmed();
        normalizedExpense.remove(u'$');

        bool expenseOk = false;
        totalExpense = normalizedExpense.toDouble(&expenseOk);
        if (!expenseOk || totalExpense <= 0.0)
        {
            return false;
        }

        purchaseDate = QDate::fromString(purchaseDateText, Qt::ISODate);
        return purchaseDate.isValid();
    }
}
// ---------------------------------------helper functions ends---------------------------------------


// ---------------------------------------model lifecycle begins---------------------------------------
// initialization
ItemListModel::ItemListModel(QObject *parent)
    : QAbstractListModel(parent), m_dataFilePath(resolveDataFilePath())
{
    loadFromFile();
}
// ---------------------------------------model lifecycle ends---------------------------------------


// ---------------------------------------model data access begins---------------------------------------
// check row count
int ItemListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
    {
        return 0;
    }

    return m_items.size();
}

QVariant ItemListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_items.size())
    {
        return {};
    }

    const ItemRecord &record = m_items.at(index.row());

    switch (role)
    {
    case ItemNameRole:
        return record.itemName;
    case TotalExpenseRole:
        return record.totalExpense;
    case TotalExpenseTextRole:
        return QStringLiteral("$%1").arg(record.totalExpense, 0, 'f', 2);
    case PurchaseDateRole:
        return record.purchaseDate;
    case PurchaseDateTextRole:
        return record.purchaseDate.toString(QStringLiteral("yyyy-MM-dd"));
    case PassedDaysRole:
        return passedDaysAt(index.row());
    default:
        return {};
    }
}

QHash<int, QByteArray> ItemListModel::roleNames() const
{
    return {
        {ItemNameRole, "itemName"},
        {TotalExpenseRole, "totalExpense"},
        {TotalExpenseTextRole, "totalExpenseText"},
        {PurchaseDateRole, "purchaseDate"},
        {PurchaseDateTextRole, "purchaseDateText"},
        {PassedDaysRole, "passedDays"}};
}
// ---------------------------------------model data access ends---------------------------------------


// ---------------------------------------item CRUD begins---------------------------------------
bool ItemListModel::addItem(const QString &itemName,
                            const QString &expenseText,
                            const QString &purchaseDateText)
{
    QString normalizedName;
    double totalExpense = 0.0;
    QDate purchaseDate;
    if (!parseItemInput(itemName, expenseText, purchaseDateText, normalizedName, totalExpense, purchaseDate))
    {
        return false;
    }

    // notify qml that one row will be inserted
    const int insertRow = m_items.size();
    beginInsertRows(QModelIndex(), insertRow, insertRow);
    m_items.push_back({normalizedName, totalExpense, purchaseDate});
    endInsertRows();
    saveToFile();
    return true;
}

bool ItemListModel::updateItem(int index,
                               const QString &itemName,
                               const QString &expenseText,
                               const QString &purchaseDateText)
{
    if (index < 0 || index >= m_items.size())
    {
        return false;
    }

    QString normalizedName;
    double totalExpense = 0.0;
    QDate purchaseDate;
    if (!parseItemInput(itemName, expenseText, purchaseDateText, normalizedName, totalExpense, purchaseDate))
    {
        return false;
    }

    ItemRecord &record = m_items[index];
    record.itemName = normalizedName;
    record.totalExpense = totalExpense;
    record.purchaseDate = purchaseDate;

    // notify qml that this row changed
    const QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {ItemNameRole, TotalExpenseRole, TotalExpenseTextRole, PurchaseDateRole, PurchaseDateTextRole, PassedDaysRole});
    saveToFile();
    return true;
}

bool ItemListModel::deleteItem(int index)
{
    if (index < 0 || index >= m_items.size())
    {
        return false;
    }

    beginRemoveRows(QModelIndex(), index, index);
    m_items.removeAt(index);
    endRemoveRows();
    saveToFile();
    return true;
}
// ---------------------------------------item CRUD ends---------------------------------------


// ---------------------------------------calculation helpers begins---------------------------------------
int ItemListModel::passedDaysAt(int index) const
{
    if (index < 0 || index >= m_items.size())
    {
        return 0;
    }

    // reuse date-diff logic from calculation module
    Cal calculation;
    calculation.d.purchaseDate = m_items.at(index).purchaseDate;
    calculation.d.currentDate = QDate::currentDate();
    const int days = calculation.d.totalDays();
    return days > 0 ? days : 0;
}

double ItemListModel::weeklyCostAt(int index) const
{
    Cal calculation;
    calculation.totalExpense = m_items.at(index).totalExpense;
    calculation.d.purchaseDate = m_items.at(index).purchaseDate;
    calculation.d.currentDate = QDate::currentDate();
    calculation.calculateExpense();
    return calculation.sl.expensePerWeek;
}

double ItemListModel::monthlyCostAt(int index) const
{
    Cal calculation;
    calculation.totalExpense = m_items.at(index).totalExpense;
    calculation.d.purchaseDate = m_items.at(index).purchaseDate;
    calculation.d.currentDate = QDate::currentDate();
    calculation.calculateExpense();
    return calculation.sl.expensePerMonth;
}

double ItemListModel::yearlyCostAt(int index) const
{
    Cal calculation;
    calculation.totalExpense = m_items.at(index).totalExpense;
    calculation.d.purchaseDate = m_items.at(index).purchaseDate;
    calculation.d.currentDate = QDate::currentDate();
    calculation.calculateExpense();
    return calculation.sl.expensePerYear;
}
// ---------------------------------------calculation helpers ends---------------------------------------


// ---------------------------------------model reset begins---------------------------------------
void ItemListModel::clear()
{
    if (m_items.isEmpty())
    {
        return;
    }

    beginResetModel();
    m_items.clear();
    endResetModel();
    saveToFile();
}
// ---------------------------------------model reset ends---------------------------------------


// ---------------------------------------sorting logic begins---------------------------------------
void ItemListModel::sortByDateAscending()
{
    if (m_items.size() < 2)
    {
        return;
    }

    beginResetModel();
    std::stable_sort(m_items.begin(), m_items.end(), [](const ItemRecord &left, const ItemRecord &right)
                     {
        if (left.purchaseDate == right.purchaseDate) {
            return Sorting::sortByNameAscending(left.itemName, right.itemName);
        }
        return Sorting::sortByDateAscending(left.purchaseDate, right.purchaseDate); });
    endResetModel();
    saveToFile();
}

void ItemListModel::sortByDateDescending()
{
    if (m_items.size() < 2)
    {
        return;
    }

    beginResetModel();
    std::stable_sort(m_items.begin(), m_items.end(), [](const ItemRecord &left, const ItemRecord &right)
                     {
        if (left.purchaseDate == right.purchaseDate) {
            return Sorting::sortByNameAscending(left.itemName, right.itemName);
        }
        return Sorting::sortByDateDescending(left.purchaseDate, right.purchaseDate); });
    endResetModel();
    saveToFile();
}

void ItemListModel::sortByNameAscending()
{
    if (m_items.size() < 2)
    {
        return;
    }

    beginResetModel();
    std::stable_sort(m_items.begin(), m_items.end(), [](const ItemRecord &left, const ItemRecord &right)
                     {
        if (left.itemName == right.itemName) {
            return Sorting::sortByDateAscending(left.purchaseDate, right.purchaseDate);
        }
        return Sorting::sortByNameAscending(left.itemName, right.itemName); });
    endResetModel();
    saveToFile();
}

void ItemListModel::sortByNameDescending()
{
    if (m_items.size() < 2)
    {
        return;
    }

    beginResetModel();
    std::stable_sort(m_items.begin(), m_items.end(), [](const ItemRecord &left, const ItemRecord &right)
                     {
        if (left.itemName == right.itemName) {
            return Sorting::sortByDateAscending(left.purchaseDate, right.purchaseDate);
        }
        return Sorting::sortByNameDescending(left.itemName, right.itemName); });
    endResetModel();
    saveToFile();
}

// ---------------------------------------sorting logic ends---------------------------------------

// ---------------------------------------.json file handling begins---------------------------------------
void ItemListModel::loadFromFile()
{
    QFile file(m_dataFilePath);
    if (!file.exists() || !file.open(QIODevice::ReadOnly))
    {
        return;
    }

    const QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    if (!doc.isArray())
    {
        return;
    }

    const QJsonArray items = doc.array();
    beginResetModel();
    m_items.clear();

    for (const QJsonValue &value : items)
    {
        if (!value.isObject())
        {
            continue;
        }

        const QJsonObject obj = value.toObject();

        const QString name = obj.value(QStringLiteral("itemName")).toString().trimmed();
        const double expense = obj.value(QStringLiteral("totalExpense")).toDouble();
        const QDate date = QDate::fromString(obj.value(QStringLiteral("purchaseDate")).toString(), Qt::ISODate);

        // skip broken records to keep loading simple and stable
        if (name.isEmpty() || expense <= 0.0 || !date.isValid())
        {
            continue;
        }

        m_items.push_back({name, expense, date});
    }

    endResetModel();
}

void ItemListModel::saveToFile() const
{
    QJsonArray items;

    for (const ItemRecord &record : m_items)
    {
        QJsonObject obj;

        obj.insert(QStringLiteral("itemName"), record.itemName);
        obj.insert(QStringLiteral("totalExpense"), record.totalExpense);
        obj.insert(QStringLiteral("purchaseDate"), record.purchaseDate.toString(Qt::ISODate));

        items.append(obj);
    }

    QFile file(m_dataFilePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
    {
        return;
    }

    // write all records as a JSON array
    file.write(QJsonDocument(items).toJson());
}
// ---------------------------------------.json file handling ends---------------------------------------
