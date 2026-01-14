cmake_minimum_required(VERSION 3.16)

project(kivk_lib_base
        VERSION 1.0
        LANGUAGES CXX
        DESCRIPTION "Проект базового функционала kivk_lib"
)

# Определить имя таргета проекта
set(TARGET_NAME KivkLibBase)

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
