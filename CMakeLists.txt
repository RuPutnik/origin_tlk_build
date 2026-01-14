cmake_minimum_required(VERSION 3.16)

project(tlk_build)

# Отображать файлы tlk_build в режиме "Проекты" в qtCreator
file(GLOB_RECURSE ALL_TLK_FILES "*")
list(FILTER ALL_TLK_FILES EXCLUDE REGEX "[.]git.*")
list(FILTER ALL_TLK_FILES EXCLUDE REGEX ".*[.]txt[.]user")
add_custom_target(${PROJECT_NAME} SOURCES ${ALL_TLK_FILES})

# Настроить возможность подключения модулей cmake
include(cmake/Init.cmake)

# TODO Попытаться разобраться (шансов мало)
# Необходимая опция для сборки статических библиотек в проекте динамической библиотеки
add_compile_options(-fPIC)
