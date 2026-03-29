#include "language_manager.h"

#include <QCoreApplication>
#include <QDir>
#include <QGuiApplication>

LanguageManager::LanguageManager(QGuiApplication *app, QObject *parent)
    : QObject(parent)
    , m_app(app)
{
}

int LanguageManager::currentLanguageIndex() const
{
    return languageCodeToIndex(m_currentLanguageCode);
}

void LanguageManager::setCurrentLanguageIndex(int index)
{
    const QString nextLanguageCode = indexToLanguageCode(index);
    if (nextLanguageCode == m_currentLanguageCode) {
        return;
    }

    const bool applied = applyLanguage(nextLanguageCode);
    const QString appliedLanguageCode = applied ? nextLanguageCode : QStringLiteral("en_US");

    if (appliedLanguageCode == m_currentLanguageCode) {
        return;
    }

    m_currentLanguageCode = appliedLanguageCode;
    emit currentLanguageChanged();
}

QString LanguageManager::currentLanguageCode() const
{
    return m_currentLanguageCode;
}

QStringList LanguageManager::languageOptions() const
{
    return {
        QStringLiteral("English"),
        QStringLiteral("Chinese"),
        QStringLiteral("Japanese")
    };
}

QString LanguageManager::indexToLanguageCode(int index)
{
    if (index == 1) {
        return QStringLiteral("zh_CN");
    }
    if (index == 2) {
        return QStringLiteral("ja_JP");
    }
    return QStringLiteral("en_US");
}

int LanguageManager::languageCodeToIndex(const QString &languageCode)
{
    if (languageCode == QStringLiteral("zh_CN")) {
        return 1;
    }
    if (languageCode == QStringLiteral("ja_JP")) {
        return 2;
    }
    return 0;
}

bool LanguageManager::applyLanguage(const QString &languageCode)
{
    if (!m_app) {
        return false;
    }

    m_app->removeTranslator(&m_translator);
    if (languageCode == QStringLiteral("en_US")) {
        return true;
    }

    const QString qmFileName = languageCode + QStringLiteral(".qm");
    const QStringList candidatePaths = {
        QStringLiteral(":/i18n/%1").arg(qmFileName),
        QStringLiteral("translations/%1").arg(qmFileName),
        QCoreApplication::applicationDirPath() + QStringLiteral("/translations/") + qmFileName,
        QCoreApplication::applicationDirPath() + QStringLiteral("/../translations/") + qmFileName,
        QCoreApplication::applicationDirPath() + QStringLiteral("/../../translations/") + qmFileName
    };

    for (const QString &path : candidatePaths) {
        const QString cleanPath = QDir::cleanPath(path);
        if (m_translator.load(cleanPath)) {
            m_app->installTranslator(&m_translator);
            return true;
        }
    }

    return false;
}
