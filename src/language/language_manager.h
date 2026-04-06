#pragma once

#include <QObject>
#include <QStringList>
#include <QTranslator>

class QGuiApplication;

class LanguageManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int currentLanguageIndex
                   READ currentLanguageIndex
                       WRITE setCurrentLanguageIndex
                           NOTIFY currentLanguageChanged
                               FINAL)
    Q_PROPERTY(QString currentLanguageCode
                   READ currentLanguageCode
                       NOTIFY currentLanguageChanged
                           FINAL)

public:
    // constructor
    explicit LanguageManager(QGuiApplication *app, QObject *parent = nullptr);

    // getter and setter
    int currentLanguageIndex() const;
    void setCurrentLanguageIndex(int index);
    QString currentLanguageCode() const;

    // 下拉菜单
    Q_INVOKABLE QStringList languageOptions() const;

    // 写入json文件保存设置
    void saveToFile();
    // 读取json设置文件
    void readFromFile();

signals:
    void currentLanguageChanged();

private:
    // language operation functions
    static QString indexToLanguageCode(int index);
    static int languageCodeToIndex(const QString &languageCode);
    bool applyLanguage(const QString &languageCode);

    // variables
    QGuiApplication *m_app = nullptr;
    QTranslator m_translator;
    QString m_currentLanguageCode = QStringLiteral("en_US"); // default language code
};
