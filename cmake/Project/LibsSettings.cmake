#======================= Описание ==========================================

# Определить правила работы с библиотеками

#===========================================================================

# Фильровать многочисленные включения
include_guard()

cmake_minimum_required(VERSION 3.16)

# Подключить модуль поддержки
include(${CMAKE_CURRENT_LIST_DIR}/../_Services/_Support.cmake)

# Перекладная переменная, чтобы запомнить путь до текущей директории
set(_ABS_PATH_TO_LIBS_SETTINGS ${CMAKE_CURRENT_LIST_DIR} CACHE STRING "Путь к директории cmake")

#[====[.rst:

    Найти и подключить модуль :command:`link_subdir_libraries`::

add_subdir_library(MODULE_PATH path
                   [MODULE_DESTINATION_PATH path]
                   )

    ======== Параметры ==========

                ``MODULE_PATH`` - Исходный путь до модуля

    ======= Опционально =========

    ``MODULE_DESTINATION_PATH`` - Конечный путь до модуля

#]====]

function(add_subdir_library)

    #============================ Парсинг параметров функции ================================

    # Задать префикс парсинга
    set(_PREFIX "_PAR")

    # Задать конфигурацию параметров парсинга
    set(_ONE_VALUE_ARGS MODULE_PATH)
    set(_OPTIONAL_ONE_VALUE_ARGS MODULE_DESTINATION_PATH)

    # Парсить параметры
    cmake_parse_arguments("${_PREFIX}" "" "${_ONE_VALUE_ARGS};${_OPTIONAL_ONE_VALUE_ARGS}" "" "${ARGN}")

    # Проверить обязательные параметры функции
    _check_parameters(PREFIX "${_PREFIX}" PARAMETERS "${_ONE_VALUE_ARGS}" "")

    # Проверить опциональные параметры функции
    _check_optional_parameters(PREFIX "${_PREFIX}" PARAMETERS "${_OPTIONAL_ONE_VALUE_ARGS}")

    #======================== Конец парсинга параметров функции =============================

    # Вычислить абсолютный путь к модулю
    get_filename_component(_ABS_PATH_TO_MODULE "${${_PREFIX}_MODULE_PATH}" ABSOLUTE)

    # Вычислить хэш от мути к модулю
    string(SHA256 _MODULE_HASH "${_ABS_PATH_TO_MODULE}")

    # Подключить модуль только один раз за всю конфигурацию
    # (в отличие от кеширования, проверка производится заново на каждом этапе конфигурации)
    if ("$ENV{ALREADY_LINKED_${_MODULE_HASH}}" STREQUAL "true")

        # Прервать функцию
        return()

    endif()

    # Отметить факт подключения модуля
    set(ENV{ALREADY_LINKED_${_MODULE_HASH}} "true")

    # Проверить что директория существует
    _check_directory_exists(DIRECTORY "${_ABS_PATH_TO_MODULE}")

    # Вычислить путь к модулю относительно корня проекта
    file(RELATIVE_PATH _REL_PATH_TO_MODULE ${CMAKE_SOURCE_DIR} "${_ABS_PATH_TO_MODULE}")

    # Проверить, что модуль является частью проекта
    if (_REL_PATH_TO_MODULE MATCHES "^\.\./")
        message(FATAL_ERROR "Модуль '${_ABS_PATH_TO_MODULE}' не является частью основного проекта")
    endif()

    # Если задан кастомный путь сборки
    if (DEFINED "${_PREFIX}_MODULE_DESTINATION_PATH")

        # Путь сборки модуля
        set(_MODULE_BINARY_DIR "${${_PREFIX}_MODULE_DESTINATION_PATH}")

    else()

        # Путь сборки модуля по умолчанию
        set(_MODULE_BINARY_DIR "${CMAKE_BINARY_DIR}/${_REL_PATH_TO_MODULE}")

    endif()

    # Подключить модуль
    add_subdirectory("${_ABS_PATH_TO_MODULE}" "${_MODULE_BINARY_DIR}")

endfunction()

#[====[.rst:

    Найти и подключить указанные библиотеки из поддиректории :command:`link_subdir_libraries`::

link_subdir_libraries(TARGET_NAME name
                      MODULE_PATH path
                      MODULE_DESTINATION_PATH path
                      [PUBLIC | PRIVATE | INTERFACE]
                      LIBS target1 target2 ...
                      )

    ======== Параметры ==========

    ``TARGET_NAME`` - Имя таргета
    ``MODULE_PATH`` - Исходный путь до модуля
           ``LIBS`` - Список таргетов библиотек, которые необходимо подключить

    ======= Опционально =========
    ``MODULE_DESTINATION_PATH`` - Конечный путь до модуля
    ``PUBLIC, PRIVATE, INTERFACE`` - Модификаторы, определяющие видимость модулей для внешних таргетов (по умолчанию PUBLIC)

#]====]

function(link_subdir_libraries)

    #============================ Парсинг параметров функции ================================

    # Задать префикс парсинга
    set(_PREFIX "_PAR")

    # Задать конфигурацию параметров парсинга
    set(_UNIQUE_MODIFIERS PUBLIC PRIVATE INTERFACE)
    set(_ONE_VALUE_ARGS TARGET_NAME MODULE_PATH)
    set(_OPTIONAL_ONE_VALUE_ARGS MODULE_DESTINATION_PATH)
    set(_MULTIPLE_VALUE_ARGS MODULE_TARGETS)

    # Парсить параметры
    cmake_parse_arguments("${_PREFIX}" "${_UNIQUE_MODIFIERS}" "${_ONE_VALUE_ARGS};${_OPTIONAL_ONE_VALUE_ARGS}" "${_MULTIPLE_VALUE_ARGS}" "${ARGN}")

    # Проверить обязательные параметры функции
    _check_parameters(PREFIX "${_PREFIX}" PARAMETERS "${_ONE_VALUE_ARGS}" "${_MULTIPLE_VALUE_ARGS}" UNIQUE_FLAGS "${_UNIQUE_MODIFIERS}")

    # Проверить опциональные параметры функции
    _check_optional_parameters(PREFIX "${_PREFIX}" PARAMETERS "${_OPTIONAL_ONE_VALUE_ARGS}")

    #======================== Конец парсинга параметров функции =============================

    # Проверить существование основного таргета
    if (NOT TARGET "${${_PREFIX}_TARGET_NAME}")
        message(FATAL_ERROR "Нет такого таргета: ${${_PREFIX}_TARGET_NAME}")
    endif()

    # Подключить модуль
    if (DEFINED "${_PREFIX}_MODULE_DESTINATION_PATH")
        add_subdir_library(MODULE_PATH "${${_PREFIX}_MODULE_PATH}"
                           MODULE_DESTINATION_PATH "${${_PREFIX}_MODULE_DESTINATION_PATH}")
    else()
        add_subdir_library(MODULE_PATH "${${_PREFIX}_MODULE_PATH}")
    endif()

    # Задать текущий модификатор в зависимости от флага
    if (${_PREFIX}_PUBLIC)
        set(_MODIFIER PUBLIC)
    elseif (${_PREFIX}_PRIVATE)
        set(_MODIFIER PRIVATE)
    elseif (${_PREFIX}_INTERFACE)
        set(_MODIFIER INTERFACE)
    else()
        # Значение по умолчанию
        set(_MODIFIER PUBLIC)
    endif()

    # Подключить модули
    foreach(_LIB ${${_PREFIX}_MODULE_TARGETS})

        # Проверить существование библиотеки
        if (NOT TARGET "${_LIB}")
            message(FATAL_ERROR "Нет такого таргета: ${_LIB}")
        endif()

        # Пропускать подключение таргета самого к себе
        if ("${${_PREFIX}_TARGET_NAME}" STREQUAL "${_LIB}")
            continue()
        endif()

        # Подключить библиотеку
        target_link_libraries("${${_PREFIX}_TARGET_NAME}" ${_MODIFIER} "${_LIB}")

    endforeach()

endfunction()
