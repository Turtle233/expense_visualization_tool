#pragma once

#include <QDate>
#include <QString>

class Sorting
{
public:
    Sorting();
    static bool sortByDateAscending(const QDate &leftDate, const QDate &rightDate);
    static bool sortByDateDescending(const QDate &leftDate, const QDate &rightDate);
    static bool sortByNameAscending(const QString &leftName, const QString &rightName);
    static bool sortByNameDescending(const QString &leftName, const QString &rightName);
};
