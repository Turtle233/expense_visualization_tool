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
    src/main.cpp
)

qt_add_qml_module(appexpense_visualization_tool_v03
    URI expense_visualization_tool_v03
    QML_FILES ui/Main.qml
        QML_FILES ui/Home_HeaderBar.qml
        QML_FILES ui/Home_NaviBar.qml
        QML_FILES ui/Home_AddItemDialog.qml
        QML_FILES ui/Home_ItemList.qml
        QML_FILES ui/Detail_Page.qml
        QML_FILES ui/Detail_EditDialog.qml
        QML_FILES ui/DateTimePicker.qml
        QML_FILES ui/Example_Item.qml
        QML_FILES ui/Home_Page.qml
        QML_FILES ui/Settings_Page.qml
    SOURCES src/calculation/calculation.h
    SOURCES src/calculation/calculation.cpp
    SOURCES src/items/item.h
    SOURCES src/items/item.cpp
    SOURCES src/graph/graph.h
    SOURCES src/graph/graph.cpp
    SOURCES src/sorting/sorting.h
    SOURCES src/sorting/sorting.cpp
    SOURCES src/currency/currency.h 
    SOURCES src/currency/currency.cpp
    SOURCES src/language/language_manager.h 
    SOURCES src/language/language_manager.cpp
)

set(APP_TS_FILES
    src/translations/zh_CN.ts
    src/translations/ja_JP.ts
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
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        ${CMAKE_CURRENT_SOURCE_DIR}/src/calculation
        ${CMAKE_CURRENT_SOURCE_DIR}/src/currency
        ${CMAKE_CURRENT_SOURCE_DIR}/src/graph
        ${CMAKE_CURRENT_SOURCE_DIR}/src/items
        ${CMAKE_CURRENT_SOURCE_DIR}/src/language
        ${CMAKE_CURRENT_SOURCE_DIR}/src/sorting
)


include(GNUInstallDirs)
install(TARGETS appexpense_visualization_tool_v03
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
