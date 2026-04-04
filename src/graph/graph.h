/* Notice:

 * A certain part of this graph.h was implemented with the help of Codex extension in VSCode.
 * The prompt I used was:
 * # As a finger slides horizontally across the chart area,
 * # the current position on the x-axis should be displayed in real-time;
 * # subsequently, based on the specific x-axis value,
 * # the corresponding y-axis value should also be displayed.
 * # This data should appear directly beneath the "Daily Cost:" line,
 * # formatted as: "Current Date: | Cost of Current Point: ".
 * # Additionally, the chart must provide visual feedback indicating the user's current sliding position,
 * # specifically in the form of an orange gradient circle.

*/

#pragma once

#include <QQuickPaintedItem>
#include <QQuickItem>
#include <QPainter>
#include <QPainterPath>
#include <QString>
#include <QtQmlIntegration/qqmlintegration.h>
#include "calculation/calculation.h"

class QPainter;
class QMouseEvent;
class QTouchEvent;

class Graph : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(double totalExpense
                   READ getTotalExpense
                       WRITE setTotalExpense
                           NOTIFY totalExpenseChanged
                               FINAL)
    Q_PROPERTY(int passedDays
                   READ getPassedDays
                       WRITE setPassedDays
                           NOTIFY passedDaysChanged
                               FINAL)

    Q_PROPERTY(QString currencyCode
                   READ currencyCode
                       WRITE setCurrencyCode
                           NOTIFY currencyCodeChanged
                               FINAL)
    Q_PROPERTY(QString currentPointDate
                   READ currentPointDate
                       NOTIFY currentPointChanged
                           FINAL)
    Q_PROPERTY(QString currentPointCost
                   READ currentPointCost
                       NOTIFY currentPointChanged
                           FINAL)
    Q_PROPERTY(bool hasCurrentPoint
                   READ hasCurrentPoint
                       NOTIFY currentPointChanged
                           FINAL)

    QML_NAMED_ELEMENT(ExpenseGraph) // used in qml/Detail_Page.qml

public:
    Graph(QQuickItem *parent = nullptr);

    // getter
    double getTotalExpense() const;
    int getPassedDays() const;
    QString currencyCode() const;
    QString currentPointDate() const;
    QString currentPointCost() const;
    bool hasCurrentPoint() const;

    // setter
    void setTotalExpense(double value);
    void setPassedDays(int value);
    void setCurrencyCode(const QString &value);

    void paint(QPainter *painter) override;

    // events
protected:
    void mousePressEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
    void touchEvent(QTouchEvent *event) override;

signals:
    void totalExpenseChanged();
    void passedDaysChanged();
    void currencyCodeChanged();
    void currentPointChanged();

private:
    void updateCurrentPointByPosition(const QPointF &position);
    void clearCurrentPoint();
    QString currentCurrencyPrefix() const;

    Cal m_calculation;
    int m_passedDays = 0;
    QString m_currencyCode = QStringLiteral("USD");
    QVector<QDate> m_cachedDates;
    QVector<double> m_cachedExpenses;
    QVector<QPointF> m_cachedPoints;
    QRectF m_cachedAxisRect;
    QRectF m_cachedDataRect;
    int m_currentPointIndex = -1;
};
