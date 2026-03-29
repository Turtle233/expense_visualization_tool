#include "sorting.h"

Sorting::Sorting() {}

bool Sorting::sortByDateAscending(const QDate &leftDate, const QDate &rightDate)
{
    return leftDate < rightDate;    // small to large
}

bool Sorting::sortByDateDescending(const QDate &leftDate, const QDate &rightDate)
{

    return leftDate > rightDate; // large to small
}

bool Sorting::sortByNameAscending(const QString &leftName, const QString &rightName)
{
    return QString::localeAwareCompare(leftName, rightName) < 0; // small to large
}

bool Sorting::sortByNameDescending(const QString &leftName, const QString &rightName)
{
    return QString::localeAwareCompare(leftName, rightName) > 0; // large to small
}
