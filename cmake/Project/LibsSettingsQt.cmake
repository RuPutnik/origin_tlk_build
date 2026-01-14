# Фильровать многочисленные включения
include_guard()

cmake_minimum_required(VERSION 3.16)

# Найти пакеты Qt
find_package(QT NAMES Qt6 Qt5 REQUIRED)

# Запомнить глобально версию Qt
set(QT_VERSION_MAJOR "${QT_VERSION_MAJOR}" CACHE STRING "Максимальная версия Qt")

# Подключить модуль работы с библиотеками
include(${CMAKE_CURRENT_LIST_DIR}/LibsSettings.cmake)

#[====[.rst:

    Найти и подключить указанные библиотеки Qt :command:`link_qt_libraries`::

link_qt_libraries(TARGET_NAME name
                  QT_LIBS qtLib1 qtLib2 ...
                  )

    ======== Параметры ==========

    ``TARGET_NAME`` - Имя таргета
        ``QT_LIBS`` - Список библиотек Qt (Core, Gui, ...)

    ======= Опционально =========
    ``PUBLIC, PRIVATE, INTERFACE`` - Модификаторы, определяющие видимость модулей для внешних таргетов (по умолчанию PUBLIC)

#]====]

function(link_qt_libraries)

    #============================ Парсинг параметров функции ================================

    # Задать префикс парсинга
    set(_PREFIX "_PAR")

    # Задать конфигурацию параметров парсинга
    set(_UNIQUE_MODIFIERS PUBLIC PRIVATE INTERFACE)
    set(_ONE_VALUE_ARGS TARGET_NAME)
    set(_MULTIPLE_VALUE_ARGS QT_LIBS)

    # Парсить параметры
    cmake_parse_arguments("${_PREFIX}" "${_UNIQUE_MODIFIERS}" "${_ONE_VALUE_ARGS}" "${_MULTIPLE_VALUE_ARGS}" "${ARGN}")

    # Проверить обязательные параметры функции
    _check_parameters(PREFIX "${_PREFIX}" PARAMETERS "${_ONE_VALUE_ARGS}" "${_MULTIPLE_VALUE_ARGS}" UNIQUE_FLAGS "${_UNIQUE_MODIFIERS}")

    #======================== Конец парсинга параметров функции =============================

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

    # Найти библиотеки Qt
    find_package("Qt${QT_VERSION_MAJOR}" COMPONENTS "${${_PREFIX}_QT_LIBS}" REQUIRED)

    # Включить MOC для таргета
    # NOTE атрибуты наследуются хреново, поэтому стоит вызывать текущую функцию для всех таргетов,
    # наследующих таргетам, использующим Qt (хотя бы для подключения Core)
    set_target_properties("${${_PREFIX}_TARGET_NAME}" PROPERTIES
                          AUTOUIC ON
                          AUTOMOC ON
                          AUTORCC ON
    )

    # Подключить библиотеки Qt
    foreach(_QT_LIB ${${_PREFIX}_QT_LIBS})
        target_link_libraries("${${_PREFIX}_TARGET_NAME}" ${_MODIFIER} "Qt${QT_VERSION_MAJOR}::${_QT_LIB}")
    endforeach()

    # Подключить базовый kivk lib для Qt (публично)
    link_subdir_libraries(
        ${_MODIFIER}
        TARGET_NAME "${${_PREFIX}_TARGET_NAME}"
        MODULE_PATH "${_ABS_PATH_TO_LIBS_SETTINGS}/cpp_tools/kivk_lib_base_qt"
        MODULE_TARGETS "KivkLibBaseQt"
    )

endfunction()
