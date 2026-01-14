#======================= Описание ==========================================

# Определить функции поиска исходников и проброса интерфейса

#===========================================================================

# Фильровать многочисленные включения
include_guard()

cmake_minimum_required(VERSION 3.16)

# Подключить модуль поддержки
include(${CMAKE_CURRENT_LIST_DIR}/../_Services/_Support.cmake)

# Перекладная переменная, чтобы запомнить путь до текущей директории
set(_ABS_PATH_TO_SOURCE_SETTINGS ${CMAKE_CURRENT_LIST_DIR} CACHE STRING "Путь к директории cmake")

#[====[.rst:

    Функция рекурсивного подключения исходных текстов из директории исходных текстов текущего проекта указанному таргету :command:`set_sources_to_target`::

set_sources_to_target(TARGET_NAME name
                     [SOURCE_DIRECTORIES dir1 dir2... INTERFACE_DIRECTORIES i_dir1 i_dir2...]
                     )

    ======== Параметры ==========

    ``TARGET_NAME`` - Имя таргета.
    ``SOURCE_DIRECTORIES`` (опционально) - Имя главной программы (классы которой тестируются).
                                           Если не задано, то поиск исходных текстов проводится рекурсивно для директории CMAKE_CURRENT_SOURCE_DIR
    ``EXCLUDE_REGEXP`` (опционально) - регулярные выражения для исключаемых из списка файлов

    ======= Опционально =========
    ``PUBLIC, PRIVATE, INTERFACE`` - Модификаторы, определяющие видимость для внешних таргетов (по умолчанию PRIVATE)

#]====]

function(set_sources_to_target)

    #============================ Парсинг параметров функции ================================

    # Задать префикс парсинга
    set(_PREFIX "_PAR")

    # Задать конфигурацию параметров парсинга
    set(_OPTIONS NO_RECURSION)
    set(_UNIQUE_MODIFIERS PUBLIC PRIVATE INTERFACE)
    set(_ONE_VALUE_ARGS TARGET_NAME)
    set(_OPTIONAL_MULTIPLE_VALUE_ARGS SOURCE_DIRECTORIES EXCLUDE_REGEXP)

    # Парсить параметры
    cmake_parse_arguments("${_PREFIX}" "${_UNIQUE_MODIFIERS};${_OPTIONS}" "${_ONE_VALUE_ARGS}" "${_OPTIONAL_MULTIPLE_VALUE_ARGS}" "${ARGN}")

    # Проверить обязательные параметры функции
    _check_parameters(PREFIX "${_PREFIX}" PARAMETERS "${_ONE_VALUE_ARGS}" UNIQUE_FLAGS "${_UNIQUE_MODIFIERS}")

    # Проверить опциональные параметры функции
    _check_optional_parameters(PREFIX "${_PREFIX}" PARAMETERS "${_OPTIONAL_MULTIPLE_VALUE_ARGS}")

    #======================== Конец парсинга параметров функции =============================

    # Задать текущий модификатор интерфейса в зависимости от флага
    if (${_PREFIX}_PUBLIC)
        set(_MODIFIER PUBLIC)
    elseif (${_PREFIX}_PRIVATE)
        set(_MODIFIER PRIVATE)
    elseif (${_PREFIX}_INTERFACE)
        set(_MODIFIER INTERFACE)
    else()
        # Значение по умолчанию
        set(_MODIFIER PRIVATE)
    endif()

    # Если задан список директорий, то искать в них
    if (DEFINED "${_PREFIX}_SOURCE_DIRECTORIES")
        set(_SOURCE_DIRECTORIES "${${_PREFIX}_SOURCE_DIRECTORIES}")
    # Иначе искать в текущей директории исходных текстов
    else()
        set(_SOURCE_DIRECTORIES "${CMAKE_CURRENT_SOURCE_DIR}")
    endif()

    # Рекурсивно найти и задать исходники во всех указанных поддиректориях
    foreach(_SOURCE_DIRECTORY ${_SOURCE_DIRECTORIES})

        # Проверить что директория существует
        _check_directory_exists(DIRECTORY "${_SOURCE_DIRECTORY}")

        if (${_PREFIX}_NO_RECURSION)
            set(_RECURSE GLOB)
        else()
            set(_RECURSE GLOB_RECURSE)
        endif()

        # Найти исходники
        file(${_RECURSE} _SOURCES
            "${_SOURCE_DIRECTORY}/*.cpp"
            "${_SOURCE_DIRECTORY}/*.h"
            "${_SOURCE_DIRECTORY}/*.ui"
            "${_SOURCE_DIRECTORY}/*.l"
            "${_SOURCE_DIRECTORY}/*.y"
        )

        # Найти файлы ресурсов
        file(${_RECURSE} _QRC_SOURCES
            "${_SOURCE_DIRECTORY}/*.qrc"
        )

        # Отсеять по регулярке
        if(DEFINED "${_PREFIX}_EXCLUDE_REGEXP")
            foreach(REGEXP ${${_PREFIX}_EXCLUDE_REGEXP})
                list(FILTER _SOURCES EXCLUDE REGEX ${REGEXP})
                list(FILTER _QRC_SOURCES EXCLUDE REGEX ${REGEXP})
            endforeach()
        endif()

        # Задать исходники таргету
        target_sources("${${_PREFIX}_TARGET_NAME}" ${_MODIFIER} "${_SOURCES}")

        # Задать файлы ресурсов таргету (публично)
        target_sources("${${_PREFIX}_TARGET_NAME}" PUBLIC "${_QRC_SOURCES}")

    endforeach()

endfunction()

#[====[.rst:

    Пробросить таргету интерфейс со всеми поддиректориями :command:`set_interface_to_target`::

set_interface_to_target(TARGET_NAME name
                       [PUBLIC | PRIVATE | INTERFACE]
                        INTERFACE_DIRECTORIES dir1 dir2 ...
                       )

    ======== Параметры ==========

           ``TARGET_NAME``    - Имя таргета. Если задано только имя, то поиск исходных текстов производится в CMAKE_CURRENT_SOURCE_DIR
    ``INTERFACE_DIRECTORIES`` - Список директорий интерфейсов, которые нужно подключить к таргету

    ======= Опционально =========
    ``PUBLIC, PRIVATE, INTERFACE`` - Модификаторы, определяющие видимость интерфейса для внешних таргетов (по умолчанию PUBLIC)

#]====]

function(set_interface_to_target)

    #============================ Парсинг параметров функции ================================

    # Задать префикс парсинга
    set(_PREFIX "_PAR")

    # Задать конфигурацию параметров парсинга
    set(_OPTIONS NO_RECURSION)
    set(_UNIQUE_MODIFIERS PUBLIC PRIVATE INTERFACE)
    set(_ONE_VALUE_ARGS TARGET_NAME)
    set(_MULTIPLE_VALUE_ARGS INTERFACE_DIRECTORIES)

    # Парсить параметры
    cmake_parse_arguments("${_PREFIX}" "${_UNIQUE_MODIFIERS};${_OPTIONS}" "${_ONE_VALUE_ARGS}" "${_MULTIPLE_VALUE_ARGS}" "${ARGN}")

    # Проверить обязательные параметры функции
    _check_parameters(PREFIX "${_PREFIX}" PARAMETERS "${_ONE_VALUE_ARGS}" "${_MULTIPLE_VALUE_ARGS}" UNIQUE_FLAGS "${_UNIQUE_MODIFIERS}")

    #======================== Конец парсинга параметров функции =============================

    # Задать текущий модификатор интерфейса в зависимости от флага
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

    # Для всех интерфейсных директорий
    foreach(_INTERFACE_DIR ${${_PREFIX}_INTERFACE_DIRECTORIES})

        # Проверить, что такая директория существует
        _check_directory_exists(DIRECTORY "${_INTERFACE_DIR}")

        if (${_PREFIX}_NO_RECURSION)
            file(GLOB _INTERFACE_FILES_AND_SUBDIRS
                LIST_DIRECTORIES true
                "${_INTERFACE_DIR}/*"
            )
        else()
            # Найти все файлы и поддиректории интерфейса
            file(GLOB_RECURSE _INTERFACE_FILES_AND_SUBDIRS
                LIST_DIRECTORIES true
               "${_INTERFACE_DIR}/*"
            )
        endif()

        # Пробросить интерфейс для текущего проекта и проектов верхнего уровня
        target_include_directories("${${_PREFIX}_TARGET_NAME}" ${_MODIFIER} "${_INTERFACE_DIR}")

        # Пробросить все поддиректории интерфейса
        foreach(_INTERFACE_SUBDIR ${_INTERFACE_FILES_AND_SUBDIRS})

            if (IS_DIRECTORY "${_INTERFACE_SUBDIR}")
                target_include_directories("${${_PREFIX}_TARGET_NAME}" ${_MODIFIER} "${_INTERFACE_SUBDIR}")
            endif()

        endforeach()

    endforeach()

endfunction()

#[====[.rst:

    Сгенерировать исходные файлы Flex/Bison и подключить их для целевого таргета :command:`set_flex_bison_to_target`::

set_flex_bison_to_target(TARGET_NAME name
                         LEXER_FILE lexer_file
                         PARSER_FILE parser_file
                         BISON_COMPILE_FLAGS flags
                         INCLUDE_DIRECTORIES dir1 dir2 ...
                         )

    ======== Параметры ==========

            ``TARGET_NAME`` - Имя таргета
             ``LEXER_FILE`` - Исходный файл лексера
            ``PARSER_FILE`` - Исходный файл лексера
    ``BISON_COMPILE_FLAGS`` - Флаги компиляции bison
    ``INCLUDE_DIRECTORIES`` - Список директорий, файлы из которых должны включаться в исходные файлы флекса и бизона

#]====]

function(set_flex_bison_to_target)

    #============================ Парсинг параметров функции ================================

    # Задать префикс парсинга
    set(_PREFIX "_PAR")

    # Задать конфигурацию параметров парсинга
    set(_UNIQUE_MODIFIERS PUBLIC PRIVATE)
    set(_ONE_VALUE_ARGS TARGET_NAME LEXER_FILE PARSER_FILE)
    set(_OPTIONAL_ONE_VALUE_ARGS BISON_COMPILE_FLAGS)
    set(_MULTIPLE_VALUE_ARGS INCLUDE_DIRECTORIES)

    # Парсить параметры
    cmake_parse_arguments("${_PREFIX}" "${_UNIQUE_MODIFIERS}" "${_ONE_VALUE_ARGS};${_OPTIONAL_ONE_VALUE_ARGS}" "${_MULTIPLE_VALUE_ARGS}" "${ARGN}")

    # Проверить обязательные параметры функции
    _check_parameters(PREFIX "${_PREFIX}" PARAMETERS "${_ONE_VALUE_ARGS}" "${_MULTIPLE_VALUE_ARGS}" UNIQUE_FLAGS "${_UNIQUE_MODIFIERS}")

    # Проверить опциональные параметры функции
    _check_optional_parameters(PREFIX "${_PREFIX}" PARAMETERS "${_OPTIONAL_ONE_VALUE_ARGS}")

    #======================== Конец парсинга параметров функции =============================

    # Задать текущий модификатор для проброса директорий flex/bison
    if (${_PREFIX}_PUBLIC)
        set(_MODIFIER PUBLIC)
    elseif (${_PREFIX}_PRIVATE)
        set(_MODIFIER PRIVATE)
    else()
        # Значение по умолчанию
        set(_MODIFIER PRIVATE)
    endif()

    # Найти модули флекса и бизона
    find_package(FLEX REQUIRED)
    find_package(BISON REQUIRED)

    # Создать директорию, куда попадут целевые файлы флекса и бизона
    file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/flex_bison")

    # Получить имена исходных файлов без расширений
    get_filename_component(_LEXER_CLEAR_FILE_NAME "${${_PREFIX}_LEXER_FILE}" NAME_WE)
    get_filename_component(_PARSER_CLEAR_FILE_NAME "${${_PREFIX}_PARSER_FILE}" NAME_WE)

    # Создать и получить целевые файлы флекса и бизона
    FLEX_TARGET(
        _LEXER_TARGET
        "${${_PREFIX}_LEXER_FILE}"
        "${CMAKE_CURRENT_BINARY_DIR}/flex_bison/${_LEXER_CLEAR_FILE_NAME}.cpp"
    )
    BISON_TARGET(
        _PARSER_TARGET
        "${${_PREFIX}_PARSER_FILE}"
        "${CMAKE_CURRENT_BINARY_DIR}/flex_bison/${_PARSER_CLEAR_FILE_NAME}.cpp"
        COMPILE_FLAGS "${${_PREFIX}_BISON_COMPILE_FLAGS}"
    )

    # Установить зависимость между флексом и бизоном
    add_flex_bison_dependency(_LEXER_TARGET _PARSER_TARGET)

    # Подключить директории, в которых лежат файлы, требуемые для подключения в файлах флекса и бизона, в целевой таргет
    foreach(_DIRECTORY_TO_INCLUDE ${${_PREFIX}_INCLUDE_DIRECTORIES})
        if (IS_DIRECTORY "${_DIRECTORY_TO_INCLUDE}")
            target_include_directories("${${_PREFIX}_TARGET_NAME}" ${_MODIFIER} "${_DIRECTORY_TO_INCLUDE}")
        endif()
    endforeach()

    # Подключить директорию с целевыми файлами флекса и бизона
    target_include_directories("${${_PREFIX}_TARGET_NAME}" ${_MODIFIER} "${CMAKE_CURRENT_BINARY_DIR}/flex_bison")

    # Задать целевому таргету целевые файлы флекса и бизона
    target_sources("${${_PREFIX}_TARGET_NAME}" PRIVATE
        "${FLEX__LEXER_TARGET_OUTPUTS}"
        "${BISON__PARSER_TARGET_OUTPUTS}"
    )

endfunction()

#[====[.rst:

    Задать путь сборки для таргетов :command:`set_targets_binary_dir`::

set_targets_binary_dir(BINARY_DIR name
                       TARGETS target1 target2 ...
                       )

    ======== Параметры ==========

    ``BINARY_DIR`` - Путь куда должны собраться таргеты (если такой директории нет, она будет создана)
       ``TARGETS`` - Имена таргетов

#]====]

function(set_targets_binary_dir)

    #============================ Парсинг параметров функции ================================

    # Задать префикс парсинга
    set(_PREFIX "_PAR")

    # Задать конфигурацию параметров парсинга
    set(_ONE_VALUE_ARGS BINARY_DIR)
    set(_MULTIPLE_VALUE_ARGS TARGETS)

    # Парсить параметры
    cmake_parse_arguments("${_PREFIX}" "" "${_ONE_VALUE_ARGS}" "${_MULTIPLE_VALUE_ARGS}" "${ARGN}")

    # Проверить параметры функции
    _check_parameters(PREFIX "${_PREFIX}" PARAMETERS "${_ONE_VALUE_ARGS}" "${_MULTIPLE_VALUE_ARGS}")

    #======================== Конец парсинга параметров функции =============================

    # Создать директорию сборки
    file(MAKE_DIRECTORY "${${_PREFIX}_BINARY_DIR}")

    # Подключить либы
    foreach(_TARGET ${${_PREFIX}_TARGETS})
        set_target_properties(
            "${_TARGET}"
            PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY "${${_PREFIX}_BINARY_DIR}"
            LIBRARY_OUTPUT_DIRECTORY "${${_PREFIX}_BINARY_DIR}"
            ARCHIVE_OUTPUT_DIRECTORY "${${_PREFIX}_BINARY_DIR}"
        )
    endforeach()

endfunction()

#[====[.rst:

    Функция рекурсивного подключения исходных текстов заданному таргету
    с использованием вложенных таргетов поддиректорий (работает на черной магии).
    Используется вместо функции set_sources_to_target и рекурсивно создает вложенные таргеты для каждой
    поддиректории папки с исходными текстами. Каждый вложенный таргет получает зависимости основного таргета.
    :command:`set_targets_binary_dir`::

set_targets_binary_dir(BINARY_DIR name
                       TARGETS target1 target2 ...
                       )

    ======== Параметры ==========

    ``BINARY_DIR`` - Путь куда должны собраться таргеты (если такой директории нет, она будет создана)
       ``TARGETS`` - Имена таргетов

#]====]

function(full_target_recursive_initialize)

    #============================ Парсинг параметров функции ================================

    # Задать префикс парсинга
    set(_PREFIX "_PAR")

    # Задать конфигурацию параметров парсинга
    set(_ONE_VALUE_ARGS TARGET_NAME SOURCE_DIRECTORY)

    # Парсить параметры
    cmake_parse_arguments("${_PREFIX}" "" "${_ONE_VALUE_ARGS}" "" "${ARGN}")

    # Проверить обязательные параметры функции
    _check_parameters(PREFIX "${_PREFIX}" PARAMETERS "TARGET_NAME")

    # Проверить опциональные параметры функции
    _check_optional_parameters(PREFIX "${_PREFIX}" PARAMETERS "SOURCE_DIRECTORY")

    #======================== Конец парсинга параметров функции =============================

    # Если задана директория, то искать в ней
    if (DEFINED "${_PREFIX}_SOURCE_DIRECTORY")
        set(_SOURCE_DIRECTORY "${${_PREFIX}_SOURCE_DIRECTORY}")
    # Иначе искать в текущей директории исходных текстов
    else()
        set(_SOURCE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
    endif()

    # Проверить что директория существует
    _check_directory_exists(DIRECTORY "${_SOURCE_DIRECTORY}")

    # Проверить что директория является поддиректорией CMAKE_CURRENT_SOURCE_DIR
    file(RELATIVE_PATH _RELATIVE_PATH "${CMAKE_CURRENT_SOURCE_DIR}" "${_SOURCE_DIRECTORY}")
    string(FIND "${_RELATIVE_PATH}" "../" _PARENT_DIRECOTRY_INDEX)
    if (NOT ${_PARENT_DIRECOTRY_INDEX} EQUAL -1)
        message(FATAL_ERROR "Директория ${_RELATIVE_PATH} не является поддиректорией ${CMAKE_CURRENT_SOURCE_DIR}")
    endif()

    # Найти все поддиректории в текущей директории
    file(GLOB _FILES_AND_SUBDIRS
        RELATIVE "${_SOURCE_DIRECTORY}"
        LIST_DIRECTORIES TRUE
        "${_SOURCE_DIRECTORY}/*"
    )

    # Для каждой поддиректоии
    foreach(_DIR ${_FILES_AND_SUBDIRS})

        if (IS_DIRECTORY "${_SOURCE_DIRECTORY}/${_DIR}")

            # Создать имя таргета поддиректории
            string(REPLACE "/" "__" _TARGET_POSTFIX "${_DIR}")
            set(_SUBTARGET_NAME "${${_PREFIX}_TARGET_NAME}__${_TARGET_POSTFIX}")

            # Создать таргет поддиректории
            add_library("${_SUBTARGET_NAME}" STATIC)

            # Задать таргету путь сборки
            set_targets_binary_dir(BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/SubdirsTargets TARGETS "${_SUBTARGET_NAME}")

            # Рекурсивно инициализировать вложенный таргет директории
            full_target_recursive_initialize(TARGET_NAME "${_SUBTARGET_NAME}" SOURCE_DIRECTORY "${_SOURCE_DIRECTORY}/${_DIR}")

            # Взять для вложенного таргета зависимости из таргета выше уровнем
            target_link_libraries("${_SUBTARGET_NAME}" PUBLIC "${${_PREFIX}_TARGET_NAME}")

            # Определить зависимость таргета от вложенного таргета
            target_link_libraries("${${_PREFIX}_TARGET_NAME}" PRIVATE "${_SUBTARGET_NAME}")

        endif()

    endforeach()

    # Найти исходники
    file(GLOB _SOURCES
        "${_SOURCE_DIRECTORY}/*.cpp"
        "${_SOURCE_DIRECTORY}/*.h"
    )

    # Задать исходники таргету
    target_sources("${${_PREFIX}_TARGET_NAME}" PRIVATE
        "${_SOURCES}"
    )

endfunction()

#[====[.rst:

    Настроить параметры сборки таргета в зависимости от типа сборки :command:`_configure_typed_target`::

    _configure_typed_target(TARGET_NAME name
                           )

    ======== Параметры ==========

    ``TARGET_NAME`` - Таргет

#]====]

function(_configure_typed_target)

    #============================ Парсинг параметров функции ================================

    # Задать префикс парсинга
    set(_PREFIX "_CHECK_FUNC")

    # Задать конфигурацию параметров парсинга
    set(_ONE_VALUE_ARGS TARGET_NAME)

    # Парсить параметры
    cmake_parse_arguments("${_PREFIX}" "" "${_ONE_VALUE_ARGS}" "" "${ARGN}")

    # Проверить обязательные параметры функции
    _check_parameters(PREFIX "${_PREFIX}" PARAMETERS "${_ONE_VALUE_ARGS}")

    #======================== Конец парсинга параметров функции =============================

    include(${_ABS_PATH_TO_SOURCE_SETTINGS}/LibsSettings.cmake)

    # Подключить базовый kivk lib
    link_subdir_libraries(
        PUBLIC
        TARGET_NAME "${${_PREFIX}_TARGET_NAME}"
        MODULE_PATH "${_ABS_PATH_TO_SOURCE_SETTINGS}/cpp_tools/kivk_lib_base"
        MODULE_TARGETS "KivkLibBase"
    )

    if(CMAKE_BUILD_TYPE MATCHES "Release")

        # Задать опции сборки в релизе
        target_compile_options("${${_PREFIX}_TARGET_NAME}" PRIVATE -O2)

        # Определить c++ макрос выключенной отладки
        target_compile_definitions("${${_PREFIX}_TARGET_NAME}" PRIVATE NDEBUG)

    elseif(CMAKE_BUILD_TYPE MATCHES "Debug")

        # Подключить либу с фичами для отладки
        link_subdir_libraries(
            PUBLIC
            TARGET_NAME "${${_PREFIX}_TARGET_NAME}"
            MODULE_PATH "${_ABS_PATH_TO_SOURCE_SETTINGS}/cpp_tools/dev_tools"
            MODULE_TARGETS "DevTools"
        )

        # Подключить модуль диагностики
        include(${_ABS_PATH_TO_SOURCE_SETTINGS}/../Diagnostics/DiagnosticsCode.cmake)

        # Использовать санитайзеры
        use_sanitizers(TARGET_NAME "${${_PREFIX}_TARGET_NAME}")

        # Включить все предупреждения
        all_compilation_warn_on(TARGET_NAME "${${_PREFIX}_TARGET_NAME}")

        # Использовать анализатор кода
        use_pvs(TARGET_NAME "${${_PREFIX}_TARGET_NAME}")

    endif()

endfunction()

#[====[.rst:

Создать таргет библиотеки :command:`add_kivk_library`::

add_kivk_library(TARGET_NAME name
                 [STATIC | SHARED | MODULE | OBJECT | INTERFACE]
                 [EXCLUDE_FROM_ALL]
                 SOURCES source1 source2...
                 )

======== Параметры ==========

``TARGET_NAME`` - Имя таргета
``SOURCES``     - Список исходных текстов

======= Опционально =========
``EXCLUDE_FROM_ALL``                          - Исключить из таргета all
``STATIC, SHARED, MODULE, OBJECT, INTERFACE`` - Модификаторы, определяющие тип библиотеки

#]====]

function(add_kivk_library)

    #============================ Парсинг параметров функции ================================

    # Задать префикс парсинга
    set(_PREFIX "_PAR")

    # Задать конфигурацию параметров парсинга
    set(_OPTIONS EXCLUDE_FROM_ALL)
    set(_UNIQUE_MODIFIERS STATIC SHARED MODULE OBJECT INTERFACE)
    set(_ONE_VALUE_ARGS TARGET_NAME)
    set(_OPTIONAL_MULTIPLE_VALUE_ARGS SOURCES)

    # Парсить параметры
    cmake_parse_arguments("${_PREFIX}" "${_UNIQUE_MODIFIERS};${_OPTIONS}" "${_ONE_VALUE_ARGS}" "${_OPTIONAL_MULTIPLE_VALUE_ARGS}" "${ARGN}")

    # Проверить обязательные параметры функции
    _check_parameters(PREFIX "${_PREFIX}" PARAMETERS "${_ONE_VALUE_ARGS}" UNIQUE_FLAGS "${_UNIQUE_MODIFIERS}")

    # Проверить опциональные параметры функции
    _check_optional_parameters(PREFIX "${_PREFIX}" PARAMETERS "${_OPTIONAL_MULTIPLE_VALUE_ARGS}")

    #======================== Конец парсинга параметров функции =============================

    if (${_PREFIX}_STATIC)
        set(_MODIFIER STATIC)
    elseif (${_PREFIX}_SHARED)
        set(_MODIFIER SHARED)
    elseif (${_PREFIX}_MODULE)
        set(_MODIFIER MODULE)
    elseif (${_PREFIX}_OBJECT)
        set(_MODIFIER OBJECT)
    elseif (${_PREFIX}_INTERFACE)
        set(_MODIFIER INTERFACE)
    else()
        # Модификатора нет по умолчанию
        unset(_MODIFIER)
    endif()

    if (${_PREFIX}_EXCLUDE_FROM_ALL)
        set(_EXCLUDE EXCLUDE_FROM_ALL)
    else()
        unset(_EXCLUDE)
    endif()

    add_library("${${_PREFIX}_TARGET_NAME}" ${_MODIFIER} ${_EXCLUDE} ${${_PREFIX}_SOURCES})

    _configure_typed_target(TARGET_NAME "${${_PREFIX}_TARGET_NAME}")

endfunction()

#[====[.rst:

Создать таргет программы :command:`add_kivk_executable`::

add_kivk_executable(TARGET_NAME name
                    [EXCLUDE_FROM_ALL]
                    SOURCES source1 source2...
                    )

======== Параметры ==========

``TARGET_NAME`` - Имя таргета
``SOURCES``     - Список исходных текстов

======= Опционально =========
``EXCLUDE_FROM_ALL`` - Исключить из таргета all

#]====]

function(add_kivk_executable)

    #============================ Парсинг параметров функции ================================

    # Задать префикс парсинга
    set(_PREFIX "_PAR")

    # Задать конфигурацию параметров парсинга
    set(_OPTIONS EXCLUDE_FROM_ALL)
    set(_ONE_VALUE_ARGS TARGET_NAME)
    set(_OPTIONAL_MULTIPLE_VALUE_ARGS SOURCES)

    # Парсить параметры
    cmake_parse_arguments("${_PREFIX}" "${_OPTIONS}" "${_ONE_VALUE_ARGS}" "${_OPTIONAL_MULTIPLE_VALUE_ARGS}" "${ARGN}")

    # Проверить обязательные параметры функции
    _check_parameters(PREFIX "${_PREFIX}" PARAMETERS "${_ONE_VALUE_ARGS}")

    # Проверить опциональные параметры функции
    _check_optional_parameters(PREFIX "${_PREFIX}" PARAMETERS "${_OPTIONAL_MULTIPLE_VALUE_ARGS}")

    #======================== Конец парсинга параметров функции =============================

    if (${_PREFIX}_EXCLUDE_FROM_ALL)
        set(_EXCLUDE EXCLUDE_FROM_ALL)
    else()
        unset(_EXCLUDE)
    endif()

    add_executable("${${_PREFIX}_TARGET_NAME}" ${_EXCLUDE} ${${_PREFIX}_SOURCES})

    _configure_typed_target(TARGET_NAME "${${_PREFIX}_TARGET_NAME}")

endfunction()
