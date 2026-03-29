#pragma once

#include <QObject>
#include <QStringList>
#include <QTranslator>

class QGuiApplication;

class LanguageManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int currentLanguageIndex READ currentLanguageIndex WRITE setCurrentLanguageIndex NOTIFY currentLanguageChanged FINAL)
    Q_PROPERTY(QString currentLanguageCode READ currentLanguageCode NOTIFY currentLanguageChanged FINAL)

public:
    explicit LanguageManager(QGuiApplication *app, QObject *parent = nullptr);

    int currentLanguageIndex() const;
    void setCurrentLanguageIndex(int index);

    QString currentLanguageCode() const;
    Q_INVOKABLE QStringList languageOptions() const;

signals:
    void currentLanguageChanged();

private:
    static QString indexToLanguageCode(int index);
    static int languageCodeToIndex(const QString &languageCode);
    bool applyLanguage(const QString &languageCode);

    QGuiApplication *m_app = nullptr;
    QTranslator m_translator;
    QString m_currentLanguageCode = QStringLiteral("en_US");
};
