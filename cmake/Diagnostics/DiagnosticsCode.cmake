cmake_minimum_required(VERSION 3.16)

# Перекладная переменная, чтобы запомнить путь до текущей директории
set(_ABS_PATH_TO_DIAGNOSTICS_SETTINGS ${CMAKE_CURRENT_LIST_DIR} CACHE STRING "Путь к директории cmake")

include(${CMAKE_CURRENT_LIST_DIR}/PVS-Studio.cmake)

#[====[.rst:
Функция включения основных предупреждений компилятора для таргета :command:`main_compilation_warn_on`::

main_compilation_warn_on(TARGET_NAME name
                        )

Необходимо передать:
 ``TARGET_NAME`` - Имя таргета

#]====]

function(main_compilation_warn_on)
    set(oneValueArgs TARGET_NAME)
    cmake_parse_arguments(MCWO "" "${oneValueArgs}" "" ${ARGN})

    set(MAIN_WARN_OPTIONS_GCC
        -Wall -Wpedantic -Wextra
       )

    set(MAIN_WARN_OPTIONS_CLANG
        -Wall -Wpedantic -Wextra
       )

   if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
       set(MAIN_WARN_OPTIONS ${MAIN_WARN_OPTIONS_GCC})
   elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
       set(MAIN_WARN_OPTIONS ${MAIN_WARN_OPTIONS_CLANG})
   else()
       message(WARNING "Unknown compiler type! Options are not defeined!")
       return()
   endif()

    if(NOT DEFINED MCWO_TARGET_NAME)
        message(FATAL_ERROR "Parameter TARGET_NAME must be set!")
    endif()

    target_compile_options(${MCWO_TARGET_NAME} PRIVATE ${MAIN_WARN_OPTIONS})
endfunction()


#[====[.rst:
Функция включения дополнительных предупреждений компилятора для таргета :command:`additional_compilation_warn_on`::

additional_compilation_warn_on(TARGET_NAME name
                              )

Необходимо передать:
 ``TARGET_NAME`` - Имя таргета

#]====]

function(additional_compilation_warn_on)
    set(oneValueArgs TARGET_NAME)
    cmake_parse_arguments(ADCWO "" "${oneValueArgs}" "" ${ARGN})

    set(ADDITIONAL_WARN_OPTIONS_GCC
        -Wcast-align -Wcast-qual -Wctor-dtor-privacy -Wduplicated-branches -Wredundant-decls
        -Wduplicated-cond -Wextra-semi -Wfloat-equal -Wconversion -Wlogical-op
        -Wnon-virtual-dtor -Wsign-conversion -Wsign-promo -Wzero-as-null-pointer-constant
       )

    set(ADDITIONAL_WARN_OPTIONS_CLANG
        -Wcast-align -Wcast-qual -Wctor-dtor-privacy -Wredundant-decls
        -Wextra-semi -Wfloat-equal -Wconversion
        -Wnon-virtual-dtor -Wsign-conversion -Wsign-promo -Wzero-as-null-pointer-constant
        -Wabstract-vbase-init
        -Walloca
        -Warc-maybe-repeated-use-of-weak
        -Warc-repeated-use-of-weak
        -Warray-bounds-pointer-arithmetic
        -Warray-parameter
        -Wassign-enum
        -Wlong-long
        -Wbad-function-cast
        -Wbitfield-width
        -Wbitwise-instead-of-logical
        -Wc++11-extensions
        -Wgnu
       )

    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        set(ADDITIONAL_WARN_OPTIONS ${ADDITIONAL_WARN_OPTIONS_GCC})
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        set(ADDITIONAL_WARN_OPTIONS ${ADDITIONAL_WARN_OPTIONS_CLANG})
    else()
        message(WARNING "Unknown compiler type! Options are not defeined!")
        return()
    endif()

    if(NOT DEFINED ADCWO_TARGET_NAME)
        message(FATAL_ERROR "Parameter TARGET_NAME must be set!")
    endif()

    target_compile_options(${ADCWO_TARGET_NAME} PRIVATE ${ADDITIONAL_WARN_OPTIONS})
endfunction()


#[====[.rst:
Функция включения всех доступных предупреждений компилятора для таргета :command:`all_compilation_warn_on`::

all_compilation_warn_on(TARGET_NAME name
                        )

Необходимо передать:
 ``TARGET_NAME`` - Имя таргета

#]====]

function(all_compilation_warn_on)
    set(oneValueArgs TARGET_NAME)
    cmake_parse_arguments(ALCWO "" "${oneValueArgs}" "" ${ARGN})

    if(NOT DEFINED ALCWO_TARGET_NAME)
        message(FATAL_ERROR "Parameter TARGET_NAME must be set!")
    endif()

    main_compilation_warn_on(TARGET_NAME ${ALCWO_TARGET_NAME})
    additional_compilation_warn_on(TARGET_NAME ${ALCWO_TARGET_NAME})
endfunction()


#[====[.rst:
Функция включения санитайзеров (ASan, UbSan) для таргета :command:`use_sanitizers`::

use_sanitizers(TARGET_NAME name
              )

Необходимо передать:
 ``TARGET_NAME`` - Имя таргета

#]====]

function(use_sanitizers)
    set(oneValueArgs TARGET_NAME)
    cmake_parse_arguments(US "" "${oneValueArgs}" "" ${ARGN})

    if(NOT DEFINED US_TARGET_NAME)
        message(FATAL_ERROR "Parameter TARGET_NAME must be set!")
    endif()

    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        set(SANITIZE_COMPILE_OPTIONS "-fsanitize=address,undefined" "-ggdb3" "-fno-omit-frame-pointer")
        set(SANITIZE_LINK_OPTIONS "-fsanitize=address,undefined")
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        set(SANITIZE_COMPILE_OPTIONS "-fsanitize=address,undefined" "-g" "-O1" "-fno-omit-frame-pointer")
        set(SANITIZE_LINK_OPTIONS "-g" "-fsanitize=address,undefined")
    else()
        message(WARNING "Unknown compiler type! Options are not defeined!")
        return()
    endif()

    target_compile_options(${US_TARGET_NAME} PUBLIC ${SANITIZE_COMPILE_OPTIONS})
    target_link_options(${US_TARGET_NAME} PUBLIC ${SANITIZE_LINK_OPTIONS})

    # Копировать файл со списком игнорируемых утечек
    # Прописать: LSAN_OPTIONS="suppressions=asan_suppressions.txt"
    configure_file("${_ABS_PATH_TO_DIAGNOSTICS_SETTINGS}/asan_suppressions.txt" ${CMAKE_BINARY_DIR} COPYONLY)
endfunction()

if((TARGET cppCheck) OR (TARGET clangTidy))
    return()
endif()

# Кастомные таргеты статических анализаторов кода
#TODO Перед -I должен быть пробел
#TODO также нужно похоже добавлять в -I все поддиректории текущего проекта
function(use_cppCheck_and_clangTidy)
add_custom_target(cppCheck COMMAND /bin/cppcheck --enable=all --verbose --quiet --inconclusive --std=c++14 ${PROJECT_SOURCE_DIR})

set(_BASE_QT_DIR /usr/include/x86_64-linux-gnu/qt5/)
set(_QT_INCLUDE_DIRS_I)
set(_CLANG_TIDY_FLAGS -header-filter=.*,-checks=*,-cppcoreguidelines-avoid-non-const-global-variables,-llvmlibc-implementation-in-namespace)

file(GLOB_RECURSE _ALL_SOURCE_FILES *.cpp *.h)
file(GLOB _QT_INCLUDE_DIRS ${_BASE_QT_DIR}*)

foreach(_QT_INCLUDE_DIR ${_QT_INCLUDE_DIRS})
    if(IS_DIRECTORY ${_QT_INCLUDE_DIR})

        string(APPEND _QT_INCLUDE_DIRS_I -I${_QT_INCLUDE_DIR}/)
    endif()
endforeach()
string(APPEND _QT_INCLUDE_DIRS_I -I${_BASE_QT_DIR})
string(APPEND _QT_INCLUDE_DIRS_I -I${CMAKE_SOURCE_DIR}/)

add_custom_target(clangTidy COMMAND /bin/clang-tidy ${_ALL_SOURCE_FILES} ${_CLANG_TIDY_FLAGS}
                  --
                  ${_QT_INCLUDE_DIRS_I}
                  -std=c++1z)
endfunction()

#[====[.rst:
Функция, добавляющая возможность использования анализатора PVS :command:`use_pvs`::

use_pvs(TARGET_NAME name
        [REPORT_FORMAT format]
       )

Необходимо передать:
 ``TARGET_NAME`` - Имя таргета, для файлов которого будет выполняться анализ
 ``REPORT_FORMAT`` - формат вывода предупреждений (json, xml, tasklist и др.)

#]====]

function(use_pvs)
    set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
    # Парсить параметры
    set(_ONE_VALUE_ARGS TARGET_NAME REPORT_FORMAT)

    cmake_parse_arguments(PVS "" "${_ONE_VALUE_ARGS}" ""  "${ARGN}")

    # Проверить обязательные параметры функции
    _check_parameters(PREFIX PVS PARAMETERS "TARGET_NAME")

    # Проверить опциональные параметры функции
    _check_optional_parameters(PREFIX PVS PARAMETERS "REPORT_FORMAT")

    if(NOT TARGET ${PVS_TARGET_NAME})
        message(FATAL "Переданное имя не является именем таргета!")
    endif()

    if(NOT DEFINED PVS_REPORT_FORMAT)
        set(PVS_REPORT_FORMAT tasklist)
    endif()

    set(PVS_FULL_TARGET PVS_check_${PVS_TARGET_NAME})

    pvs_studio_add_target(TARGET ${PVS_FULL_TARGET}
                          PLATFORM linux64
                          OUTPUT FORMAT ${PVS_REPORT_FORMAT}
                          ANALYZE ${PVS_TARGET_NAME}
                          COMPILE_COMMANDS
                          MODE 'GA:1,2,3+64:1,2+OP:1,2,3+CS:1,2,3'
                          LOG pvs_cmake_log
                          ARGS -j 14
                               -e *_autogen/* -e */flex_bison/* -e */Tests/* -e */moc_*)

    add_custom_command(TARGET ${PVS_FULL_TARGET} POST_BUILD COMMAND rm -rf ARGS "../.PVS-Studio/logs")
endfunction()
