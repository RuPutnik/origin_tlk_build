cmake_minimum_required(VERSION 3.16)

include(${CMAKE_CURRENT_LIST_DIR}/../_Services/_Support.cmake)

#[====[.rst:

Функция линковки к указанному таргету указанных объектных файлов :command:`target_link_objects`::

target_link_objects(TARGET_NAME name
                    LINKED_OBJECTS object1 object2...
                    DIR_OBJECTS dir
                    )

 Необходимо передать:
 ``TARGET_NAME`` - Имя таргета, к которому нужно линковать объектные файлы
 ``LINKED_OBJECTS`` - Список файлов, которые должны линковаться. Имя файла должно быть указано относительно пути, записанного в ``DIR_OBJECTS``
 ``DIR_OBJECTS`` - Путь к директории в которой (рекурсивно) будут искаться все указанные в списке ``LINKED_OBJECTS`` объектные файлы для последующей линковки

#]====]

function(target_link_objects)
    set(oneValueArgs TARGET_NAME DIR_OBJECTS)
    set(multipleValueArgs LINKED_OBJECTS)

    cmake_parse_arguments(TLO "" "${oneValueArgs}" "${multipleValueArgs}" ${ARGN})

    _check_parameters(PREFIX TLO PARAMETERS ${oneValueArgs} ${multipleValueArgs})

    message(STATUS "target_link_objects ==> Link objects for ${TLO_TARGET_NAME}")
    list(LENGTH ${TLO_LINKED_OBJECTS} COUNT_OBJECTS)

    if(${COUNT_OBJECTS} LESS 1)
        message(WARNING "target_link_objects ==> Empty objects list")
        return()
    endif()

    if(NOT TLO_DIR_OBJECTS)
        message(WARNING "target_link_objects ==> Empty DIR_OBJECTS")
        return()
    endif()

    foreach(OBJ ${${TLO_LINKED_OBJECTS}})
        string(PREPEND OBJ "${${TLO_DIR_OBJECTS}}/")

        if(NOT EXISTS ${OBJ})
            message(WARNING "target_link_objects ==> Linked file ${OBJ} doesn't exist yet!")
        endif()

        target_link_libraries(${TLO_TARGET_NAME} PRIVATE ${OBJ})
    endforeach()
endfunction()

#[====[.rst:

Функция линковки к указанному таргету всех найденных в директории объектных файлов :command:`target_link_all_objects`::

target_link_all_objects(TARGET_NAME name
                        [INCLUDE_MAIN]
                        DIR_OBJECTS dir
                        )

 Необходимо передать:
 ``TARGET_NAME`` - Имя таргета, к которому нужно линковать объектные файлы
 ``INCLUDE_MAIN`` (Опционально) - Опция, при активации которой линкуется объектный файл main.cpp.o main.o и подобные (содержащие слово main и имеющие тип .o)
 ``DIR_OBJECTS`` - Путь к директории в которой (рекурсивно) будут искаться объектные файлы (кроме main, если не активирована опция ``INCLUDE_MAIN``) для последующей линковки

#]====]

function(target_link_all_objects)
    set(optionsValue INCLUDE_MAIN)
    set(oneValueArgs TARGET_NAME DIR_OBJECTS)

    cmake_parse_arguments(TLAO "${optionsValue}" "${oneValueArgs}" "" ${ARGN})

    _check_parameters(PREFIX TLAO PARAMETERS ${multipleValueArgs})

    message(STATUS "target_link_all_objects ==> Link objects for ${TLAO_TARGET_NAME}")
    file(GLOB_RECURSE LINKED_OBJECTS "${${TLAO_DIR_OBJECTS}}/*.o")
    list(LENGTH LINKED_OBJECTS COUNT_OBJECTS)

    if(${COUNT_OBJECTS} LESS 1)
        message(STATUS "target_link_all_objects ==> Passed dir has no objects")
        return()
    endif()

    if(NOT TLAO_INCLUDE_MAIN)
        list(FILTER LINKED_OBJECTS EXCLUDE REGEX "(^|.*/)main[.]*.*[.]*o")
    endif()

    if(NOT TLAO_DIR_OBJECTS)
        message(WARNING "target_link_all_objects ==> Empty DIR_OBJECTS")
        return()
    endif()

    foreach(OBJ ${LINKED_OBJECTS})
        target_link_libraries(${TLAO_TARGET_NAME} PRIVATE ${OBJ})
    endforeach()
endfunction()
