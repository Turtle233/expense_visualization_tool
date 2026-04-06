#pragma once

#include <QObject>
#include <QString>
#include <QStringList>

class Currency : public QObject
{
    Q_OBJECT

    // 属性宏，配置index
    Q_PROPERTY(int currentCurrencyIndex
                   READ currentCurrencyIndex
                       WRITE setCurrentCurrencyIndex
                           NOTIFY currentCurrencyChanged
                               FINAL)

    Q_PROPERTY(QString currentCurrencyCode
                   READ currentCurrencyCode
                       NOTIFY currentCurrencyChanged
                           FINAL)

    Q_PROPERTY(QString currentCurrencySymbol
                   READ currentCurrencySymbol
                       NOTIFY currentCurrencyChanged
                           FINAL)

public:
    // 枚举
    enum CurrencyType {
        USD = 0,
        CNY,
        JPY,
        EUR
    };

    Q_ENUM(CurrencyType)

    // 构造函数
    Currency(QObject *parent = nullptr);

    // getter and setter
    int currentCurrencyIndex() const;
    void setCurrentCurrencyIndex(int index);

    // 返回当前货币代码（如USD）和货币符号（如$）
    QString currentCurrencyCode() const;
    QString currentCurrencySymbol() const;

    // 用于和QML交互的函数
    Q_INVOKABLE QStringList currencyOptions() const; // 下拉列表

    Q_INVOKABLE double convertFromUSD(double amountUSD) const; // 输入USD时
    Q_INVOKABLE double convertToUSD(double amountInCurrentCurrency) const; // 输入其他货币时

    Q_INVOKABLE double parseAmountToUSD(const QString &amountText) const; // 从其余货币转入USD计算
    Q_INVOKABLE QString formatFromUSD(double amountUSD) const; // 处理数据格式

    // 写入json文件保存设置
    void saveToFile();
    // 读取json设置文件
    void readFromFile();

signals:
    void currentCurrencyChanged(); // 货币被切换时需要调用什么函数

private:
    CurrencyType m_currentCurrency = USD; // 默认QEnum的货币类型为USD
    static double rateFromUSD(CurrencyType type); // 货币汇率设置为静态全局
};
