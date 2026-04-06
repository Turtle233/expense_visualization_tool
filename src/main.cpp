#include <QGuiApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include "items/item.h"
#include "currency/currency.h"
#include "language/language_manager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Material"); // for Android use only

    // instances
    QQmlApplicationEngine engine;
    ItemListModel itemListModel;
    Currency currencyManager;
    LanguageManager languageManager(&app);

    engine.rootContext()->setContextProperty("itemListModel", &itemListModel);
    engine.rootContext()->setContextProperty("currencyManager", &currencyManager);
    engine.rootContext()->setContextProperty("languageManager", &languageManager);

    // translation
    QObject::connect(&languageManager, &LanguageManager::currentLanguageChanged, &engine, [&engine]()
                     { engine.retranslate(); });

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []()
        { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("expense_visualization_tool_v03", "Main");

    return app.exec();
}
