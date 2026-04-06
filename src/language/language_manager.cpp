#include "language_manager.h"

#include <QCoreApplication>
#include <QDir>
#include <QGuiApplication>
#include <QJsonDocument>
#include <QJsonObject>
#include <QFile>

LanguageManager::LanguageManager(QGuiApplication *app, QObject *parent)
    : QObject(parent), m_app(app)
{
    // 一旦创建对象就先读取设置
    readFromFile();
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

    // 将当前语言设置存入settings.json
    saveToFile();
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
    if (index == 1) // 1 = Chinese
        return QStringLiteral("zh_CN");
    if (index == 2) // 2 = Japanese
        return QStringLiteral("ja_JP");
    return QStringLiteral("en_US"); // 0 = English
}

int LanguageManager::languageCodeToIndex(const QString &languageCode)
{
    if (languageCode == QStringLiteral("zh_CN"))
    {
        return 1; // 1 = Chinese
    }
    if (languageCode == QStringLiteral("ja_JP"))
    {
        return 2; // 2 = Japanese
    }
    return 0;  // 0 = English
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

//--------------------------文件读写-------------------------------
// keep settings in ./data/settings.json under current project folder
QString languageSettingFilePath()
{
    QDir dir(QDir::currentPath());
    dir.mkpath(QStringLiteral("data"));
    return dir.filePath(QStringLiteral("data/languageSetting.json"));
}

// 将设置保存到json文件
void LanguageManager::saveToFile(){
    QFile file(languageSettingFilePath());

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return;

    // store values
    QJsonObject settingsObj;
    settingsObj["language"] = currentLanguageCode();

    QJsonDocument settingsDoc(settingsObj);
    file.write(settingsDoc.toJson());
}

// 读取设置json文件
void LanguageManager::readFromFile(){
    QFile file(languageSettingFilePath());
    if(!file.open(QIODevice::ReadOnly))
        return;

    const QJsonDocument settingsDoc  = QJsonDocument::fromJson(file.readAll());
    const QString languageCodeRead = settingsDoc.object().value("language").toString();

    // 读取然后set到上次保存的语言
    if (languageCodeRead == "zh_CN")
        setCurrentLanguageIndex(1);
    else if (languageCodeRead == "ja_JP")
        setCurrentLanguageIndex(2);
    else if (languageCodeRead == "en_US")
        setCurrentLanguageIndex(0);
}
