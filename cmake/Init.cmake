cmake_minimum_required(VERSION 3.16)

# Добавить в список корневую папку cmake модулей
list(APPEND _CMAKE_MODULES_DIRS ${CMAKE_CURRENT_LIST_DIR})

# Найти все содержимое папки с модулями cmake
file(GLOB_RECURSE _CMAKE_TOOLS_FILES_ANS_DIRS
    LIST_DIRECTORIES true
    ${CMAKE_CURRENT_LIST_DIR}/*
)

# Отделить и добавить в список поддиректории с модулями cmake
foreach(_ELEM ${_CMAKE_TOOLS_FILES_ANS_DIRS})
    if (IS_DIRECTORY ${_ELEM})
        list(APPEND _CMAKE_MODULES_DIRS ${_ELEM})
    endif()
endforeach()

# Задать переменную для поиска модулей cmake при сборке
set(CMAKE_MODULE_PATH ${_CMAKE_MODULES_DIRS} CACHE STRING "Путь к модулям cmake")

include(${CMAKE_CURRENT_LIST_DIR}/_Services/_Support.cmake)
