cmake_minimum_required(VERSION 3.16)

project(dev_tools
        VERSION 1.0
        LANGUAGES CXX
        DESCRIPTION "Проект фич для отладки"
)

# Определить имя таргета проекта
set(TARGET_NAME DevTools)

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

# NOTE данный проект предполагается подключать вообще ко всем таргетам,
# по этой причине зависимость от Qt (и вобще от каких-либо либ) должна быть закрытой (PRIVATE)
link_qt_libraries(PRIVATE TARGET_NAME ${TARGET_NAME} QT_LIBS "Core")

link_subdir_libraries(
    PRIVATE
    TARGET_NAME ${TARGET_NAME}
    MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../kivk_lib_base_qt"
    MODULE_TARGETS "KivkLibBaseQt"
)
