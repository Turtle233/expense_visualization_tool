cmake_minimum_required(VERSION 3.16)

project(expense_visualization_tool_v03 VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

# This place was changed and should be replaced with this each time
find_package(Qt6 REQUIRED COMPONENTS
    Quick
    QuickControls2
    LinguistTools
)
qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appexpense_visualization_tool_v03
    main.cpp
)

qt_add_qml_module(appexpense_visualization_tool_v03
    URI expense_visualization_tool_v03
    QML_FILES Main.qml
        QML_FILES qml/Home_HeaderBar.qml
        QML_FILES qml/Home_NaviBar.qml
        QML_FILES qml/Home_AddItemDialog.qml
        QML_FILES qml/Home_ItemList.qml
        QML_FILES qml/Detail_Page.qml
        QML_FILES qml/Detail_EditDialog.qml
        QML_FILES qml/DateTimePicker.qml
        QML_FILES qml/Example_Item.qml
        QML_FILES qml/Home_Page.qml
        QML_FILES qml/Settings_Page.qml
    SOURCES calculation/calculation.h
    SOURCES calculation/calculation.cpp
    SOURCES items/item.h
    SOURCES items/item.cpp
    SOURCES graph/graph.h
    SOURCES graph/graph.cpp
    SOURCES sorting/sorting.h
    SOURCES sorting/sorting.cpp
    SOURCES currency/currency.h currency/currency.cpp
    SOURCES language/language_manager.h language/language_manager.cpp
)

set(APP_TS_FILES
    translations/zh_CN.ts
    translations/ja_JP.ts
)

qt_add_translations(appexpense_visualization_tool_v03
    TS_FILES ${APP_TS_FILES}
    QM_FILES_OUTPUT_VARIABLE APP_QM_FILES
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appexpense_visualization_tool_v03 PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appexpense_visualization_tool_v03
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# This place was changed and should be replaced with this each time
target_link_libraries(appexpense_visualization_tool_v03
   PRIVATE Qt6::Quick
   PRIVATE Qt6::QuickControls2
)

# set_property(TARGET appexpense_visualization_tool_v03 PROPERTY
#     QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android
# )

# Explicitly tell the builder which folders should be include
target_include_directories(appexpense_visualization_tool_v03
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/calculation
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/items
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/graph
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/currency
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/language
)


include(GNUInstallDirs)
install(TARGETS appexpense_visualization_tool_v03
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
