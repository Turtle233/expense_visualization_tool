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

set(APP_TARGET see_your_cost)

qt_add_executable(${APP_TARGET}
    src/main.cpp
)

qt_add_qml_module(${APP_TARGET}
    URI expense_visualization_tool_v03
    QML_FILES ui/Main.qml
        QML_FILES ui/Home_HeaderBar.qml
        QML_FILES ui/Home_NaviBar.qml
        QML_FILES ui/Home_AddItemDialog.qml
        QML_FILES ui/Home_ItemList.qml
        QML_FILES ui/Detail_Page.qml
        QML_FILES ui/Detail_EditDialog.qml
        QML_FILES ui/DateTimePicker.qml
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
    RESOURCES ui/icons/resources.qrc
    RESOURCES docs/README.CN.md docs/README.JA.md docs/README.md
    RESOURCES docs/modeling/class_diagram.xml docs/modeling/sequence_diagram.xml docs/modeling/state_chart.xml docs/modeling/use_case_diagram.xml
    RESOURCES docs/testing/black_box_testing.txt
)

# Translation files add as application resource
set(APP_TS_FILES
    translations/zh_CN.ts
    translations/ja_JP.ts
)

qt_add_translations(${APP_TARGET}
    TS_FILES ${APP_TS_FILES}
    QM_FILES_OUTPUT_VARIABLE APP_QM_FILES
)

qt_add_resources(${APP_TARGET} "app_i18n_translations"
    PREFIX "/i18n"
    BASE "${CMAKE_CURRENT_BINARY_DIR}"
    FILES ${APP_QM_FILES}
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(${APP_TARGET} PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.SeeyourCost
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# This place was changed and should be replaced with this each time
target_link_libraries(${APP_TARGET}
   PRIVATE Qt6::Quick
   PRIVATE Qt6::QuickControls2
)

if(ANDROID)
    set_target_properties(${APP_TARGET} PROPERTIES
        QT_ANDROID_APP_NAME "SeeyourCost"
        QT_ANDROID_PACKAGE_NAME "org.qtproject.example.seeyourcost"
    )

    set_property(TARGET ${APP_TARGET} PROPERTY
        QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android
    )
endif()

# Explicitly tell the builder which folders should be include
target_include_directories(${APP_TARGET}
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
install(TARGETS ${APP_TARGET}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
