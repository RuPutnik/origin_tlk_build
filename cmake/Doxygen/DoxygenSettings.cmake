#======================= Описание ==========================================

# Определить настройки и функции генерации документации doxygen

#===========================================================================

cmake_minimum_required(VERSION 3.16)

# Подключить модуль поддержки
include(${CMAKE_CURRENT_LIST_DIR}/../_Services/_Support.cmake)

#[====[.rst:
     Задать настройки и сгенерировать документацию doxygen :command:`generate_doxygen`::

generate_doxygen(TARGET_NAME name
                )

    ======== Параметры ==========

    ``TARGET_NAME`` - Имя таргета.
#]====]
#
function(generate_doxygen)

    #============================ Парсинг параметров функции ================================

    # Задать префикс парсинга
    set(_PREFIX "_PAR")

    # Задать конфигурацию параметров парсинга
    set(_ONE_VALUE_ARGS TARGET_NAME)

    # Парсить параметры
    cmake_parse_arguments("${_PREFIX}" "" "${_ONE_VALUE_ARGS}" ""  "${ARGN}")

    # Проверить обязательные параметры функции
    _check_parameters(PREFIX "${_PREFIX}" PARAMETERS "${_ONE_VALUE_ARGS}")

    #======================== Конец парсинга параметров функции =============================

    # Поиск Doxygen. В результате должна быть установлена переменная DOXYGEN_FOUND
    # Если Doxygen был найден, то переменная DOXYGEN_VERSION также будет устанолена
    # равной версии найденного doxygen
    find_package(Doxygen REQUIRED)

    # Переопределение выходной диретории doxygen, которая по умолчанию равна CMAKE_CURRENT_BINARY_DIR.
    set(DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/docs/${_TARGET_NAME}")

    # Признак формирования HTML документации
    set(DOXYGEN_GENERATE_HTML YES)

    # Признак формирования страниц для MAN
    # set(DOXYGEN_GENERATE_MAN YES)

    # Признак поддержки markdown
    set(DOXYGEN_MARKDOWN_SUPPORT YES)

    # Признак поддержки автолинковки
    set(DOXYGEN_AUTOLINK_SUPPORT YES)

    # Признак поддержки графов dot
    set(DOXYGEN_HAVE_DOT YES)

    # Признак включения диаграм взаимодействия в документацию по классам
    set(DOXYGEN_COLLABORATION_GRAPH YES)

    # Признак включения диаграм классов в документацию
    set(DOXYGEN_CLASS_GRAPH YES)

    # Признак генерации UML-графов
    set(DOXYGEN_UML_LOOK YES)

    # Признак включения информации о типах и параметрах в UML графы
    set(DOXYGEN_DOT_UML_DETAILS YES)

    # Максимальный размер строки для содержимого графов
    set(DOXYGEN_DOT_WRAP_THRESHOLD 100)

    # Признак отрисовки графов вызовов для функций
    set(DOXYGEN_CALL_GRAPH YES)

    # Признак "тихой" работыDoxygen
    set(DOXYGEN_QUIET YES)

    # Установка русского языка в интерфейсе
    set(DOXYGEN_OUTPUT_LANGUAGE "Russian")

    # Запустить генерацию документации
    doxygen_add_docs(
        ${_TARGET_NAME}Doxygen
        "${CMAKE_CURRENT_SOURCE_DIR}"
        ALL
        COMMENT "Генерация документации для таргета ${_TARGET_NAME} с помощью Doxygen"
    )

endfunction()
