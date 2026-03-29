#include "currency.h"

Currency::Currency(QObject *parent): QObject(parent) {}

// currency rate converting creteria
double Currency::rateFromUSD(CurrencyType type)
{
    if (type == CNY) {
        return 7.00;
    }
    if (type == JPY) {
        return 160.00;
    }
    if (type == EUR) {
        return 0.80;
    }
    return 1.00; // USD
}

// get currency index
int Currency::currentCurrencyIndex() const
{
    return static_cast<int>(m_currentCurrency);
}

// set currency index
void Currency::setCurrentCurrencyIndex(int index)
{
    CurrencyType nextCurrency = USD;

    if (index == CNY) {
        nextCurrency = CNY;
    }
    else if (index == JPY) {
        nextCurrency = JPY;
    }
    else if (index == EUR) {
        nextCurrency = EUR;
    }

    // 如果仍然选中当前货币，则直接返回
    if (m_currentCurrency == nextCurrency) {
        return;
    }

    m_currentCurrency = nextCurrency;
    emit currentCurrencyChanged();
}

QString Currency::currentCurrencyCode() const
{
    if (m_currentCurrency == CNY) {
        return QStringLiteral("CNY");
    }
    if (m_currentCurrency == JPY) {
        return QStringLiteral("JPY");
    }
    if (m_currentCurrency == EUR) {
        return QStringLiteral("EUR");
    }
    return QStringLiteral("USD");
}

QString Currency::currentCurrencySymbol() const
{
    if (m_currentCurrency == EUR) {
        return QStringLiteral("€");
    }
    if (m_currentCurrency == USD) {
        return QStringLiteral("$");
    }

    // 日元人民币符号一样就直接return
    return QStringLiteral("¥");
}

// drop down currency menu for settings page
QStringList Currency::currencyOptions() const
{
    return {
        QStringLiteral("USD ($)"),
        QStringLiteral("CNY (¥)"),
        QStringLiteral("JPY (¥)"),
        QStringLiteral("EUR (€)")
    };
}

double Currency::convertFromUSD(double amountUSD) const
{
    return amountUSD * rateFromUSD(m_currentCurrency);
}

double Currency::convertToUSD(double amountInCurrentCurrency) const
{
    const double rate = rateFromUSD(m_currentCurrency);
    return amountInCurrentCurrency / rate;
}

// 把带货币符号的金额QString 解析为数值 最后转化为USD
double Currency::parseAmountToUSD(const QString &amountText) const
{
    QString normalized = amountText.trimmed(); // 去除空格

    // 去除货币符号和逗号
    normalized.remove(QStringLiteral("$"));
    normalized.remove(QStringLiteral("¥"));
    normalized.remove(QStringLiteral("¥"));
    normalized.remove(QStringLiteral("€"));
    normalized.remove(QStringLiteral(","));

    // 去除货币代码和空格
    normalized.remove(QStringLiteral("USD"), Qt::CaseInsensitive);
    normalized.remove(QStringLiteral("CNY"), Qt::CaseInsensitive);
    normalized.remove(QStringLiteral("JPY"), Qt::CaseInsensitive);
    normalized.remove(QStringLiteral("EUR"), Qt::CaseInsensitive);
    normalized = normalized.trimmed();

    double parsedAmount = normalized.toDouble();
    return convertToUSD(parsedAmount);
}

// 处理显示的数据格式
QString Currency::formatFromUSD(double amountUSD) const
{
    const double converted = convertFromUSD(amountUSD);
    return QStringLiteral("%1%2").arg(currentCurrencySymbol(),
                                      QString::number(converted, 'f', 2));
}
