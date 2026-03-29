/* Notice:

 * A certain part of this graph.cpp was implemented with the help of Codex extension in VSCode.
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

#include "../graph/graph.h"

#include <QEventPoint>
#include <QLinearGradient>
#include <QMouseEvent>
#include <QRadialGradient>
#include <QTouchEvent>
#include <QVector>

// constructor
Graph::Graph(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{
    setAntialiasing(true);
    setAcceptedMouseButtons(Qt::LeftButton);
    setAcceptTouchEvents(true);
}

double Graph::getTotalExpense() const
{
    return m_calculation.totalExpense;
}

void Graph::setTotalExpense(double value)
{
    m_calculation.totalExpense = value;
    emit totalExpenseChanged(); // refresh total expense as y
    if (hasCurrentPoint())
    {
        emit currentPointChanged();
    }
    update();
}

int Graph::getPassedDays() const
{
    return m_passedDays;
}

QString Graph::currencyCode() const
{
    return m_currencyCode;
}

QString Graph::currentPointDate() const
{
    if (!hasCurrentPoint())
    {
        return QString();
    }

    return m_cachedDates.at(m_currentPointIndex).toString(QStringLiteral("yyyy-MM-dd"));
}

QString Graph::currentPointCost() const
{
    if (!hasCurrentPoint())
    {
        return QString();
    }

    return QStringLiteral("%1%2").arg(currentCurrencyPrefix(),
                                      QString::number(m_cachedExpenses.at(m_currentPointIndex), 'f', 2));
}

bool Graph::hasCurrentPoint() const
{
    return m_currentPointIndex >= 0 && m_currentPointIndex < m_cachedPoints.size();
}

QString Graph::currentCurrencyPrefix() const
{
    if (m_currencyCode == QStringLiteral("CNY") || m_currencyCode == QStringLiteral("JPY"))
    {
        return QStringLiteral("¥");
    }
    if (m_currencyCode == QStringLiteral("EUR"))
    {
        return QStringLiteral("€");
    }
    return QStringLiteral("$");
}

void Graph::updateCurrentPointByPosition(const QPointF &position)
{
    // ignore tracking before graph data is prepared
    if (m_cachedPoints.isEmpty() || !m_cachedAxisRect.contains(position))
    {
        clearCurrentPoint();
        return;
    }

    if (m_cachedDataRect.width() <= 0.0)
    {
        return;
    }

    double xRatio = (position.x() - m_cachedDataRect.left()) / m_cachedDataRect.width();
    if (xRatio < 0.0)
    {
        xRatio = 0.0;
    }
    else if (xRatio > 1.0)
    {
        xRatio = 1.0;
    }

    int nextIndex = static_cast<int>(xRatio * (m_cachedPoints.size() - 1) + 0.5);
    if (nextIndex < 0)
    {
        nextIndex = 0;
    }
    else if (nextIndex >= m_cachedPoints.size())
    {
        nextIndex = m_cachedPoints.size() - 1;
    }

    if (m_currentPointIndex == nextIndex)
    {
        return;
    }

    m_currentPointIndex = nextIndex;
    emit currentPointChanged();
    update();
}

void Graph::clearCurrentPoint()
{
    if (m_currentPointIndex < 0)
    {
        return;
    }

    m_currentPointIndex = -1;
    emit currentPointChanged();
    update();
}

void Graph::setPassedDays(int value)
{
    m_passedDays = value;
    emit passedDaysChanged(); // refresh passed days as x
    if (hasCurrentPoint())
    {
        emit currentPointChanged();
    }
    update();
}

void Graph::setCurrencyCode(const QString &value)
{
    // skip redraw if currency code is unchanged
    if (m_currencyCode == value)
    {
        return;
    }

    m_currencyCode = value;
    emit currencyCodeChanged();
    if (hasCurrentPoint())
    {
        emit currentPointChanged();
    }
    update();
}

void Graph::mousePressEvent(QMouseEvent *event)
{
    // track point on press for mouse and touchpad
    updateCurrentPointByPosition(event->position());
    event->accept();
}

void Graph::mouseMoveEvent(QMouseEvent *event)
{
    if (event->buttons() & Qt::LeftButton)
    {
        updateCurrentPointByPosition(event->position());
    }
    event->accept();
}

void Graph::mouseReleaseEvent(QMouseEvent *event)
{
    Q_UNUSED(event);
    clearCurrentPoint();
}

void Graph::touchEvent(QTouchEvent *event)
{
    if (event->points().isEmpty())
    {
        event->ignore();
        return;
    }

    const QEventPoint &point = event->points().first();
    if (event->type() == QEvent::TouchEnd || event->type() == QEvent::TouchCancel || point.state() == QEventPoint::Released)
    {
        clearCurrentPoint();
    }
    else
    {
        // track point while finger is moving in graph area
        updateCurrentPointByPosition(point.position());
    }
    event->accept();
}

// main painter
void Graph::paint(QPainter *painter)
{
    // outer border area
    QRectF bounds = boundingRect();

    double leftPadding = 60.0;
    double rightPadding = 16.0;
    double topPadding = 14.0;
    double bottomPadding = 42.0;

    double plotWidth = bounds.width() - leftPadding - rightPadding;
    double plotHeight = bounds.height() - topPadding - bottomPadding;

    if (plotWidth < 1.0)
    {
        plotWidth = 1.0;
    }
    if (plotHeight < 1.0)
    {
        plotHeight = 1.0;
    }

    // visible axis frame
    QRectF axisRect(
        bounds.left() + leftPadding,
        // bounds.right() + rightPadding,
        // bounds.bottom() + bottomPadding,
        bounds.top() + topPadding,
        plotWidth,
        plotHeight);

    double axisGap = 1.5;

    // actual line drawing frame
    QRectF dataRect(
        axisRect.left(),
        axisRect.top() + axisGap,
        axisRect.width() - axisGap,
        axisRect.height() - axisGap);

    if (dataRect.width() < 1.0)
    {
        dataRect.setWidth(1.0);
    }
    if (dataRect.height() < 1.0)
    {
        dataRect.setHeight(1.0);
    }

    QPen axisPen(Qt::black);
    axisPen.setWidthF(1.5);
    painter->setPen(axisPen);
    painter->drawLine(axisRect.bottomLeft(), axisRect.bottomRight());
    painter->drawLine(axisRect.bottomLeft(), axisRect.topLeft());

    int days = m_passedDays;
    // keep at least one day on x-axis
    if (days < 1)
    {
        days = 1;
    }

    m_calculation.d.currentDate = QDate::currentDate();
    m_calculation.d.purchaseDate = m_calculation.d.currentDate.addDays(-days);
    m_calculation.calculateDailySeries();

    // pass the x and y data from calcualtion.cpp
    QVector<QDate> xDates = m_calculation.vDates;
    QVector<double> yExpenses = m_calculation.vDailyExpense;
    days = yExpenses.size();

    if (days < 1)
    {
        return;
    }

    QVector<QPointF> points;
    points.reserve(days);

    // set y data
    double minY = yExpenses.first();
    double maxY = yExpenses.first();

    for (int i = 0; i < yExpenses.size(); ++i)
    {
        if (yExpenses[i] < minY)
        {
            minY = yExpenses[i];
        }
        if (yExpenses[i] > maxY)
        {
            maxY = yExpenses[i];
        }
    }

    // y-axis value range
    double yRange = maxY - minY;

    // avoid yRange equals 0
    if (maxY == minY)
    {
        yRange = 1.0;
    }

    // split y-axis into 4 levels: max, upper, lower, min
    const double lowerTickValue = minY + (yRange / 3.0);
    const double upperTickValue = minY + (yRange * 2.0 / 3.0);
    const double lowerTickY = dataRect.bottom() - ((lowerTickValue - minY) / yRange) * dataRect.height();
    const double upperTickY = dataRect.bottom() - ((upperTickValue - minY) / yRange) * dataRect.height();

    // generate one point for each day
    for (int i = 0; i < xDates.size(); ++i)
    {
        // calculate dynamic x-axis scale
        double xRatio = 0.0;

        if (days > 1)
        {
            xRatio = double(i) / double(days - 1);
        }

        double x = dataRect.left() + xRatio * dataRect.width();
        double yRatio = (yExpenses[i] - minY) / yRange;
        double y = dataRect.bottom() - yRatio * dataRect.height();
        points.append(QPointF(x, y));
    }

    // cache data for slider tracking
    m_cachedDates = xDates;
    m_cachedExpenses = yExpenses;
    m_cachedPoints = points;
    m_cachedAxisRect = axisRect;
    m_cachedDataRect = dataRect;
    if (m_currentPointIndex >= m_cachedPoints.size())
    {
        m_currentPointIndex = -1;
        emit currentPointChanged();
    }

    // gradient area between curve and x-axis
    QPainterPath linePath;
    linePath.moveTo(points.first());
    for (int i = 1; i < points.size(); ++i)
    {
        linePath.lineTo(points.at(i));
    }

    QLinearGradient areaGradient(dataRect.left(), dataRect.top(), dataRect.left(), axisRect.bottom());
    areaGradient.setColorAt(0.0, QColor(255, 152, 0, 120));
    areaGradient.setColorAt(1.0, QColor(255, 152, 0, 15));

    QPainterPath areaPath(linePath);
    areaPath.lineTo(points.last().x(), axisRect.bottom());
    areaPath.lineTo(points.first().x(), axisRect.bottom());
    areaPath.closeSubpath();
    painter->fillPath(areaPath, areaGradient);

    // draw two middle dashed guide lines
    QPen gridPen(QColor("#D5D5D5"));
    gridPen.setColor(QColor("#ECECEC"));
    gridPen.setWidthF(0.7);
    gridPen.setStyle(Qt::DashLine);
    painter->setPen(gridPen);
    painter->drawLine(QPointF(axisRect.left(), lowerTickY), QPointF(axisRect.right(), lowerTickY));
    painter->drawLine(QPointF(axisRect.left(), upperTickY), QPointF(axisRect.right(), upperTickY));

    // line itself
    QLinearGradient lineGradient(dataRect.left(), dataRect.top(), dataRect.right(), dataRect.top());
    lineGradient.setColorAt(0.0, QColor("#FFB74D"));
    lineGradient.setColorAt(1.0, QColor("#EF6C00"));

    QPen linePen(QBrush(lineGradient), 3.0, Qt::SolidLine, Qt::FlatCap, Qt::RoundJoin);
    painter->setPen(linePen);
    if (points.size() == 1)
    {
        painter->drawEllipse(points.first(), 3.0, 3.0);
    }
    else
    {
        painter->drawPath(linePath);
    }

    painter->setPen(axisPen);
    painter->drawLine(axisRect.bottomLeft(), axisRect.bottomRight());
    painter->drawLine(axisRect.bottomLeft(), axisRect.topLeft());

    // draw an orange gradient marker for current tracked point
    if (hasCurrentPoint())
    {
        const QPointF markerCenter = m_cachedPoints.at(m_currentPointIndex);
        QRadialGradient markerGradient(markerCenter, 11.0);
        markerGradient.setColorAt(0.0, QColor("#FFD180"));
        markerGradient.setColorAt(0.7, QColor("#FFB74D"));
        markerGradient.setColorAt(1.0, QColor("#EF6C00"));

        painter->setPen(QPen(QColor("#FB8C00"), 1.2));
        painter->setBrush(markerGradient);
        painter->drawEllipse(markerCenter, 8.0, 8.0);

        painter->setPen(Qt::NoPen);
        painter->setBrush(QColor("#FFF3E0"));
        painter->drawEllipse(markerCenter, 2.5, 2.5);
    }

    // label texts
    painter->setPen(Qt::black);
    QFont labelFont = painter->font();
    labelFont.setPointSizeF(12.0);
    painter->setFont(labelFont);

    // show purchase date as the x-axis start label
    const QString purchaseDateText = m_calculation.d.purchaseDate.toString(QStringLiteral("yyyy-MM-dd"));
    painter->drawText(
        QRectF(axisRect.left() - 8.0, axisRect.bottom() + 4.0, 96.0, bottomPadding - 4.0),
        Qt::AlignLeft | Qt::AlignTop,
        purchaseDateText); // x-axis start
    painter->drawText(
        QRectF(axisRect.right() - 104.0, axisRect.bottom() + 4.0, 104.0, bottomPadding - 4.0),
        Qt::AlignRight | Qt::AlignTop,
        tr("Today (%1)").arg(days)); // x-axis end

    // map currency code to symbol prefix
    const QString currencyPrefix = currentCurrencyPrefix();

    const QString maxYText = QStringLiteral("%1%2").arg(currencyPrefix, QString::number(maxY, 'f', 2));
    const QString upperTickText = QStringLiteral("%1%2").arg(currencyPrefix, QString::number(upperTickValue, 'f', 2));
    const QString lowerTickText = QStringLiteral("%1%2").arg(currencyPrefix, QString::number(lowerTickValue, 'f', 2));
    const QString minYText = QStringLiteral("%1%2").arg(currencyPrefix, QString::number(minY, 'f', 2));

    // draw all 4 y-axis labels
    painter->drawText(
        QRectF(bounds.left(), axisRect.top() - 4.0, leftPadding - 8.0, 24.0),
        Qt::AlignRight | Qt::AlignVCenter,
        maxYText); // max y-value
    painter->drawText(
        QRectF(bounds.left(), upperTickY - 12.0, leftPadding - 8.0, 24.0),
        Qt::AlignRight | Qt::AlignVCenter,
        upperTickText);
    painter->drawText(
        QRectF(bounds.left(), lowerTickY - 12.0, leftPadding - 8.0, 24.0),
        Qt::AlignRight | Qt::AlignVCenter,
        lowerTickText);
    painter->drawText(
        QRectF(bounds.left(), axisRect.bottom() - 12.0, leftPadding - 8.0, 24.0),
        Qt::AlignRight | Qt::AlignVCenter,
        minYText); // min y-value
}
