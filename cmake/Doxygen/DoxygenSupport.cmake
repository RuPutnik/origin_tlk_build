cmake_minimum_required(VERSION 3.16)

#[====[.rst:

Функция включения файла Doxyfile для дальнейшего использования с помощью команды doxygen_add_docs :command:`include_doxyfile`::

include_doxyfile(PATH_DOXYFILE pathFile
                )

Необходимо передать:
 ``PATH_DOXYFILE`` - Путь к докси-файлу относительно корня CMake проекта

#]====]

function(include_doxyfile)
    set(oneValueArgs PATH_DOXYFILE)

    cmake_parse_arguments(DG "" "${oneValueArgs}" "" ${ARGN})

    if(NOT DEFINED DG_PATH_DOXYFILE)
        message(FATAL_ERROR "Parameter PATH_DOXYFILE must be set!")
    endif()

    set(DOX_PREFIX DOXYGEN_)
    set(DOXYFILE_ABS_PATH ${CMAKE_SOURCE_DIR}/${DG_PATH_DOXYFILE})
    set(DOXYGEN_VERBATIM_VARS_LIST)
    if(NOT EXISTS ${DOXYFILE_ABS_PATH})
        message(STATUS "include_doxyfile ==> Doxyfile ${DG_PATH_DOXYFILE} doesn't exist!")
        return()
    else()
        message(STATUS "include_doxyfile ==> Doxyfile ${DG_PATH_DOXYFILE} exist!")
    endif()

    file(STRINGS ${DOXYFILE_ABS_PATH} LINES_DOXYFILE REGEX "^[^#]+$")

    foreach(DOXYFILE_LINE ${LINES_DOXYFILE})
        string(REPLACE "=" ";" PARTS_DOXLINE ${DOXYFILE_LINE})

        list(GET PARTS_DOXLINE 0 DOX_PARAM_NAME)
        list(GET PARTS_DOXLINE 1 DOX_PARAM_VALUE)

        string(STRIP ${DOX_PARAM_NAME} DOX_PARAM_NAME)
        string(PREPEND DOX_PARAM_NAME ${DOX_PREFIX})

        if(NOT ${DOX_PARAM_VALUE} STREQUAL "")
            string(STRIP ${DOX_PARAM_VALUE} DOX_PARAM_VALUE)
            string(REGEX REPLACE "[ ]+" " " DOX_PARAM_VALUE ${DOX_PARAM_VALUE})

            string(REPLACE " " ";" DOX_PARAM_VALUE_COMPONENTS ${DOX_PARAM_VALUE})
            list(LENGTH DOX_PARAM_VALUE_COMPONENTS LENGTH_COMPONENTS_VALUE_LIST)

            if(${LENGTH_COMPONENTS_VALUE_LIST} GREATER "1")
                list(APPEND DOXYGEN_VERBATIM_VARS_LIST ${DOX_PARAM_NAME})
            endif()
        endif()

        set(${DOX_PARAM_NAME} ${DOX_PARAM_VALUE} CACHE STRING "Doxygen option" FORCE)
    endforeach()

    set(DOXYGEN_VERBATIM_VARS ${DOXYGEN_VERBATIM_VARS_LIST}
                              CACHE STRING "Doxygen option" FORCE)
endfunction()

add_custom_target(docCreate COMMAND doxygen ${PROJECT_SOURCE_DIR}/Doxyfile)
