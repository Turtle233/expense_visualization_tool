#include "language_manager.h"

#include <QCoreApplication>
#include <QDir>
#include <QGuiApplication>

LanguageManager::LanguageManager(QGuiApplication *app, QObject *parent)
    : QObject(parent), m_app(app)
{
}

int LanguageManager::currentLanguageIndex() const
{
    return languageCodeToIndex(m_currentLanguageCode);
}

// choose current language
void LanguageManager::setCurrentLanguageIndex(int index)
{
    const QString nextLanguageCode = indexToLanguageCode(index);
    if (nextLanguageCode == m_currentLanguageCode)
    {
        return;
    }

    const bool applied = applyLanguage(nextLanguageCode);
    const QString appliedLanguageCode = applied ? nextLanguageCode : QStringLiteral("en_US");

    if (appliedLanguageCode == m_currentLanguageCode)
    {
        return;
    }

    m_currentLanguageCode = appliedLanguageCode;
    emit currentLanguageChanged();
}

QString LanguageManager::currentLanguageCode() const
{
    return m_currentLanguageCode;
}

// drop down menu
QStringList LanguageManager::languageOptions() const
{
    return {
        QStringLiteral("English / 英文 / 英語"),
        QStringLiteral("Chinese (Simplified) / 简体中文 / 中国語"),
        QStringLiteral("Japanese / 日语 / 日本語")};
}

// language code index to much .qm file
QString LanguageManager::indexToLanguageCode(int index)
{
    if (index == 1)
    {
        return QStringLiteral("zh_CN");
    }
    if (index == 2)
    {
        return QStringLiteral("ja_JP");
    }
    return QStringLiteral("en_US");
}

int LanguageManager::languageCodeToIndex(const QString &languageCode)
{
    if (languageCode == QStringLiteral("zh_CN"))
    {
        return 1;
    }
    if (languageCode == QStringLiteral("ja_JP"))
    {
        return 2;
    }
    return 0;
}

// translation hot apply
bool LanguageManager::applyLanguage(const QString &languageCode)
{
    m_app->removeTranslator(&m_translator);
    if (languageCode == QStringLiteral("en_US"))
    {
        return true;
    }

    const QString qmFileName = languageCode + QStringLiteral(".qm");
    const QStringList candidatePaths = {
        QStringLiteral(":/i18n/%1").arg(qmFileName),
        QStringLiteral("translations/%1").arg(qmFileName),
        QCoreApplication::applicationDirPath() + QStringLiteral("/translations/") + qmFileName,
        QCoreApplication::applicationDirPath() + QStringLiteral("/../translations/") + qmFileName,
        QCoreApplication::applicationDirPath() + QStringLiteral("/../../translations/") + qmFileName};

    for (const QString &path : candidatePaths)
    {
        const QString cleanPath = QDir::cleanPath(path);
        if (m_translator.load(cleanPath))
        {
            m_app->installTranslator(&m_translator);
            return true;
        }
    }

    return false;
}
