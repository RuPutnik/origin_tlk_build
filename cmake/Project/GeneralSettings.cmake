#======================= Описание ==========================================

# Основные настройки C++ проекта с использованием Qt

#===========================================================================

# Фильровать многочисленные включения
include_guard()

cmake_minimum_required(VERSION 3.16)

# Настройки c++
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Настройка отображения вывода сборки
set(VERBOSE ON)

# Настройка поиска динамических библиотек рядом с программой
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
#set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE) # NOTE Не трогать
set(CMAKE_INSTALL_RPATH "$ORIGIN")
set(CMAKE_SKIP_RPATH FALSE)
set(CMAKE_SKIP_BUILD_RPATH FALSE)
set(CMAKE_SKIP_INSTALL_RPATH FALSE)

enable_testing()
