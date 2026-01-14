#======================= Описание ==========================================

# Вспомогательные функции cmake

#===========================================================================

#[====[.rst:

    Проверить параметры функции после парсинга :command:`_check_parameters`::

_check_parameters(PREFIX prefix
                  PARAMETERS par1 par2 ...
                  [UNIQUE_FLAGS flag1 flag2 ...]
                  )

    ======== Параметры ==========

        ``PREFIX`` - Префикс парсинга исходной функции
    ``PARAMETERS`` - Обязательные параметры функции, которые должны быть определены и у которых должны быть определены значения

    ======= Опционально =========
    ``UNIQUE_FLAGS`` - Список флагов, из которых допустимо использовать только один

#]====]

function(_check_parameters)

    # TODO: в разработке
#    if (NOT DEFINED _CHECK_MACRO_PREFIX)
#        # Парсить параметры функции проверки
#        cmake_parse_arguments("_CHECK_MACRO" "" "PREFIX" "PARAMETERS" ${ARGN})
#        message("FIRST CHECK CALL. _CHECK_MACRO_PREFIX: ${_CHECK_MACRO_PREFIX}")
#        message("${${_CHECK_MACRO_PREFIX}_KEYWORDS_MISSING_VALUES}")
#        _check_parameters(PREFIX "_CHECK_MACRO" PARAMETERS "PREFIX" "PARAMETERS")
#    else()
#        message("SECOND CHECK CALL. _CHECK_MACRO_PREFIX: ${_CHECK_MACRO_PREFIX}")
#        cmake_parse_arguments("_CHECK_MACRO_SELF" "" "PREFIX" "PARAMETERS" ${ARGN})
#    endif()

#    if (DEFINED _CHECK_MACRO_SELF_PREFIX)
#        message("Проверка себя")
#        set(_CURRENT_PREFIX "_CHECK_MACRO_SELF")
#    else()
#        message("Проверка функции")
##        cmake_parse_arguments("_CHECK_MACRO" "" PREFIX PARAMETERS ${ARGN})
#        set(_CURRENT_PREFIX "_CHECK_MACRO")

#        if (NOT DEFINED _CHECK_MACRO_PREFIX)
#            message("Стал недоступен ${_CHECK_MACRO_PREFIX}")
#        endif()
#    endif()

#    message("_CHECK_MACRO_PREFIX " "${_CHECK_MACRO_PREFIX}")
#    message("${_CHECK_MACRO_PREFIX}_PREFIX " "${${_CHECK_MACRO_PREFIX}_PREFIX}")

#    if (NOT ${_CHECK_MACRO_PREFIX} STREQUAL "_CHECK_MACRO")
#        message("NOT EQUAL")
#    else()
#        message("EQUAL")
#    endif()

#    message("ARGN ${ARGN}")
#    message("${_CURRENT_PREFIX}_PARAMETERS ${${_CURRENT_PREFIX}_PARAMETERS}")


    set(_CURRENT_PREFIX "_CHECK_MACRO")

    cmake_parse_arguments(${_CURRENT_PREFIX} "" "PREFIX" "PARAMETERS;UNIQUE_FLAGS" ${ARGN})

    # Проверить наличие обязательных параметров и их пропущенные значения
    foreach(_VALUE_ARG ${${_CURRENT_PREFIX}_PARAMETERS})

        # Проверить что для параметра задано значение
        list(FIND "${${_CURRENT_PREFIX}_PREFIX}_KEYWORDS_MISSING_VALUES" ${_VALUE_ARG} _ARG_INDEX)
        if (NOT ${_ARG_INDEX} EQUAL -1)
            message(FATAL_ERROR "У параметра ${_VALUE_ARG} не задано значение")
        endif()

        # Проверить что параметр определен
        if (NOT DEFINED "${${_CURRENT_PREFIX}_PREFIX}_${_VALUE_ARG}")
            message(FATAL_ERROR "Параметр ${_VALUE_ARG} должен быть определен")
        endif()

    endforeach()

    # Проверить, что активирован может быть только один уникальный флаг
    set(_ACTIVE_FLAGS_COUNT 0)
    foreach(_FLAG ${${_CURRENT_PREFIX}_UNIQUE_FLAGS})

        # Если флаг активен
        if (${${_CURRENT_PREFIX}_PREFIX}_${_FLAG})
            set(_FLAGS_NAMES "${_FLAGS_NAMES} ${_FLAG}")
            math(EXPR _ACTIVE_FLAGS_COUNT "${_ACTIVE_FLAGS_COUNT} + 1")
        endif()

    endforeach()

    # Если задано больше одного флага
    if (${_ACTIVE_FLAGS_COUNT} GREATER 1)
        message(FATAL_ERROR "Флаги не могут быть использованны одновременно: ${_FLAGS_NAMES}")
    endif()

    # Проверить наличие лишних параметров
    if (DEFINED "${${_CURRENT_PREFIX}_PREFIX}_UNPARSED_ARGUMENTS")

        # Создать список с пробелами
        string(REPLACE ";" " " _UNPARSED_SPACE_LIST "${${${_CURRENT_PREFIX}_PREFIX}_UNPARSED_ARGUMENTS}")

        message(FATAL_ERROR "Присутствуют лишние параметры: ${_UNPARSED_SPACE_LIST}")

    endif()

endfunction()

#[====[.rst:

    Проверить опциональные параметры функции после парсинга :command:`_check_optional_parameters`::

_check_optional_parameters(PREFIX prefix
                           PARAMETERS par1 par2 ...
                           )

    ======== Параметры ==========

        ``PREFIX`` - Префикс парсинга исходной функции
    ``PARAMETERS`` - Опциональные параметры функции. Если они заданы, то у них должны быть определены значения

#]====]

function(_check_optional_parameters)

    set(_CURRENT_PREFIX "_CHECK_FUNC")

    cmake_parse_arguments(${_CURRENT_PREFIX} "" "PREFIX" "PARAMETERS" ${ARGN})

    # Проверить пропущенные значения параметров
    foreach(_VALUE_ARG ${${_CURRENT_PREFIX}_PARAMETERS})

        # Проверить что для параметра задано значение
        list(FIND "${${_CURRENT_PREFIX}_PREFIX}_KEYWORDS_MISSING_VALUES" ${_VALUE_ARG} _ARG_INDEX)
        if (NOT ${_ARG_INDEX} EQUAL -1)
            message(FATAL_ERROR "У параметра ${_VALUE_ARG} не задано значение")
        endif()

    endforeach()

endfunction()

#[====[.rst:

    Проверить, что указанная директория существует :command:`_check_directory_exists`::

_check_directory_exists(DIRECTORY dir
                       )

    ======== Параметры ==========

    ``DIRECTORY`` - Директория

#]====]

function(_check_directory_exists)

    #============================ Парсинг параметров функции ================================

    # Задать префикс парсинга
    set(_PREFIX "_CHECK_FUNC")

    # Задать конфигурацию параметров парсинга
    set(_ONE_VALUE_ARGS DIRECTORY)

    # Парсить параметры
    cmake_parse_arguments("${_PREFIX}" "" "${_ONE_VALUE_ARGS}" "" "${ARGN}")

    # Проверить обязательные параметры функции
    _check_parameters(PREFIX "${_PREFIX}" PARAMETERS "${_ONE_VALUE_ARGS}")

    #======================== Конец парсинга параметров функции =============================

    # Проверить что директория существует
    if (NOT IS_DIRECTORY "${${_PREFIX}_DIRECTORY}")
        message(FATAL_ERROR "Не существует директории: ${${_PREFIX}_DIRECTORY}")
    endif()

endfunction()

#[====[.rst:

Функция автоподключения всех подпроектов в каталоге :command:`add_subdirs`::

add_subdirs([ERROR_IF_NO_CMAKELISTS]
           )

Необходимо передать:

``ERROR_IF_NO_CMAKELISTS`` (Опционально) - Флаг, активация которого ведет к тому, что если поддиректория не имеет файла CMakeLists.txt,
будет выведена ошибка и дальнейшая работа прекратится. Без флага будет только предупреждение

#]====]

function(add_subdirs)
    set(PARSE_PREFIX AD)
    set(optionParams ERROR_IF_NO_CMAKELISTS)
    set(CMAKE_FILENAME CMakeLists.txt)
    cmake_parse_arguments(${PARSE_PREFIX} ${optionParams} "" "" ${ARGN})

    file(GLOB SUBDIRS "*")

    foreach(SUBDIR ${SUBDIRS})
        if(IS_DIRECTORY ${SUBDIR})
            if(EXISTS ${SUBDIR}/${CMAKE_FILENAME})
                add_subdirectory(${SUBDIR})
            else()
                if(${PARSE_PREFIX}_ERROR_IF_NO_CMAKELISTS)
                    message(FATAL_ERROR "Директория ${SUBDIR} не имеет файла ${CMAKE_FILENAME}. Подключение подпроектов далее невозможно!")
                else()
                    message(WARNING "Директория ${SUBDIR} не имеет файла ${CMAKE_FILENAME} и будет пропущена!")
                endif()
            endif()
        endif()
    endforeach()
endfunction()
