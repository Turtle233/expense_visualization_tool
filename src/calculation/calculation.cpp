#include "calculation.h"

using namespace std;

void Cal::calculateExpense()
{
    if (!validate())
        return;
    int totalDays = d.totalDays();

    sl.expensePerDay = totalExpense / (totalDays * 1.00);
    sl.expensePerWeek = 7.00 * sl.expensePerDay;
    sl.expensePerMonth = 30.4375 * sl.expensePerDay;

    // 月和年都是近似模糊计算�?    sl.expensePerMonth = 30.4375 * sl.expensePerDay;
    sl.expensePerYear = 365.2425 * sl.expensePerDay;
}

// 计算日均序列，作为二级图表坐标基础
void Cal::calculateDailySeries()
{
    vDates.clear();
    vDailyExpense.clear();

    int totalDays = d.totalDays();

    for (int i = 1; i <= totalDays; i++)
    {
        // x-axis (Time)
        QDate currentPosDate = d.purchaseDate.addDays(i);
        vDates.push_back(currentPosDate);

        // y-axis (Daily Expense)
        double currentPosDailyExpense = totalExpense / i;
        vDailyExpense.push_back(currentPosDailyExpense);
    }
}
