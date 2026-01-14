cmake_minimum_required(VERSION 3.16)

project(kivk_lib_base_qt
        VERSION 1.0
        LANGUAGES CXX
        DESCRIPTION "Проект базового функционала kivk_lib с использованием Qt"
)

# Определить имя таргета проекта
set(TARGET_NAME KivkLibBaseQt)

# Фильтровать повторное подключение таргета
include_guard(GLOBAL)

# Модуль основных настроек
include(GeneralSettings)

#=========================== Настройки таргетов =================================

include(SourceSettings)

# Определить таргет проекта
add_kivk_library(TARGET_NAME ${TARGET_NAME} STATIC)

# Задать исходные тексты
set_sources_to_target(TARGET_NAME ${TARGET_NAME})

# Пробросить интерфейс
set_interface_to_target(TARGET_NAME ${TARGET_NAME} INTERFACE_DIRECTORIES ${CMAKE_CURRENT_SOURCE_DIR}/interface)

#============================= Библиотеки =======================================

include(LibsSettingsQt)

link_qt_libraries(TARGET_NAME ${TARGET_NAME} QT_LIBS "Core")

link_subdir_libraries(
    PUBLIC
    TARGET_NAME ${TARGET_NAME}
    MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../kivk_lib_base"
    MODULE_TARGETS "KivkLibBase"
)

