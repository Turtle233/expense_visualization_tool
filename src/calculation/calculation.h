#pragma once

#include <QDate>
#include <QDebug>
#include <QObject>
#include <QVector>

// friend classes
class ItemListModel;
class Graph;

class Cal : public QObject
{
    Q_OBJECT
    friend class ItemListModel;
    friend class Graph;

private:
    struct date
    {
        QDate currentDate;
        QDate purchaseDate;

        // function calculate range from purchaseDate to currentDate
        int totalDays() const
        {
            return purchaseDate.daysTo(currentDate);
        }
    };

    // homepage display only
    struct scales
    {
        double expensePerDay = 0.00;
        double expensePerWeek = 0.00;
        double expensePerMonth = 0.00;
        double expensePerYear = 0.00;
    };

    // structure instances
    date d;
    scales sl;

    // detail page graph display preparation
    QVector<QDate> vDates;         // vector storing all days since purchase date
    QVector<double> vDailyExpense; // values in y-axis

public:
    // functions
    void calculateExpense();
    void calculateDailySeries();

    // initialization
    double totalExpense = 0.00;

    // prevention
    bool validate()
    {
        int totalDays = d.totalDays();

        if (totalDays <= 0)
        {
            qDebug() << "[Error] Invalid date range!";
            return false;
        }
        if (totalExpense <= 0.00)
        {
            qDebug() << "[Error] Invalid expense range!";
            return false;
        }

        return true;
    }
};
