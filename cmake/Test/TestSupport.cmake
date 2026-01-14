cmake_minimum_required(VERSION 3.16)

set(CMAKE_MODULES ${CMAKE_CURRENT_LIST_DIR}/..)

include(${CMAKE_MODULES}/Project/TargetLinkObjects.cmake)
include(${CMAKE_MODULES}/Project/GeneralSettings.cmake)
include(${CMAKE_MODULES}/Project/LibsSettingsQt.cmake)
include(${CMAKE_MODULES}/_Services/_Support.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/QtTest.cmake)

#[====[.rst:

Функция создания и регистрации в системе CTest своего QTest :command:`generate_qtest`::

generate_qtest(NAME_TEST name
              [NAME_MAIN_BINARY name_binary]
              [SOURCES sources1 sources2...]
              [LINK_OBJECTS]
              [DIR_OBJECTS dir]
              [USED_OBJECTS obj1 obj2...]
              [USED_LIBS lib1 lib2...]
              [INCLUDE_DIRS dir1 dir2...]
              )

 Необходимо передать:
 ``NAME_TEST`` - Имя теста. Будет создан подпроект и таргет с этим именем. В результате будет создан бинарный файл теста с таким же именем
 ``NAME_MAIN_BINARY`` (опционально) - Имя главной программы (классы которой тестируются). Если не задано, то
 не будет установлена зависимость проекта теста от главного проекта, что может ускорить сборку (будет собираться параллельно с главным проектом),
 но может привести к ошибкам, если линкуемый файл не будет собран раньше попытки его слинковать. Это важно только если идет линковка к отдельным объектным файлам.
 Зависимость от линкуемых элементов из ``USED_LIBS`` устанавливается автоматически
 ``SOURCES`` (опционально) - Список исходных файлов теста. Если не задан, будут автоматически найдены и скомпилированы все исходные файлы (*.cpp, *.h) в текущем каталоге и его подкаталогах
 ``LINK_OBJECTS`` (опционально) - Флаг, который указывает, что должны линковаться объектные файлы. При использовании, необходимо передать также параметр ``DIR_OBJECTS`` и опционально ``USED_OBJECTS``
 ``DIR_OBJECTS`` (опционально) - Путь к папке, где лежат линкуемые объектые файлы
 ``USED_OBJECTS`` (опционально) - Линкуемые объекты. Если не задан, будут линковаться все объектные файлы в папке ``DIR_OBJECTS``
 ``USED_LIBS`` (опционально) - Переменная, в которую можно передать список библиотек для линковки
 ``INCLUDE_DIRS`` (опционально) - Переменная, в которую можно передать список директорий, относительно которых будет производится поиск файлов для директив #include препроцессора

#]====]

function(generate_qtest)
    set(optionArgs LINK_OBJECTS)
    set(oneValueArgs NAME_TEST NAME_MAIN_BINARY DIR_OBJECTS)
    set(multipleValueArgs SOURCES USED_OBJECTS USED_LIBS INCLUDE_DIRS)

    cmake_parse_arguments(GQT "${optionArgs}" "${oneValueArgs}" "${multipleValueArgs}" ${ARGN})

    # Эти параметры должны быть заданы ВСЕГДА
    if(NOT DEFINED GQT_NAME_TEST)
        message(FATAL_ERROR "Parameter NAME_TEST must be set!")
    endif()

    if(GQT_LINK_OBJECTS AND (NOT DEFINED GQT_DIR_OBJECTS))
        message(FATAL_ERROR "Parameter DIR_OBJECTS must be set!")
    endif()

    _check_optional_parameters(PREFIX GQT PARAMETERS ${multipleValueArgs})

    #Если не задан, будут компилироваться все .cpp и .h файлы данного проекта
    if(NOT DEFINED GQT_SOURCES)
        message(NOTICE "Parameter SOURCES wasn't set! Files ((*.h), (*.cpp)) will be found automatically!")
        file(GLOB_RECURSE GQT_SOURCES "*.cpp" "*.h")
    endif()

    list(LENGTH GQT_USED_OBJECTS GQT_USED_OBJECTS_AMOUNT)
    list(LENGTH GQT_SOURCES GQT_SOURCES_AMOUNT)

    if(GQT_SOURCES_AMOUNT LESS 1)
        message(FATAL_ERROR "Parameter SOURCES must have more 0 elements!")
    endif()

    project(${GQT_NAME_TEST} LANGUAGES CXX)
    add_executable(${GQT_NAME_TEST})
    target_sources(${GQT_NAME_TEST} PRIVATE ${GQT_SOURCES})

    if(GQT_LINK_OBJECTS)
        if(GQT_USED_OBJECTS_AMOUNT GREATER 0)
            target_link_objects(TARGET_NAME ${GQT_NAME_TEST} LINKED_OBJECTS GQT_USED_OBJECTS DIR_OBJECTS GQT_DIR_OBJECTS)
        else()
            message(NOTICE "Empty list USED_OBJECTS! All objects in DIR_OBJECTS will be linked")
            target_link_all_objects(TARGET_NAME ${GQT_NAME_TEST} DIR_OBJECTS GQT_DIR_OBJECTS)
        endif()
    endif()

    if((NOT DEFINED GQT_NAME_MAIN_BINARY) AND (DEFINED GQT_USED_OBJECTS))
        message(WARNING "Parameter NAME_MAIN_BINARY for USED_OBJECTS wasn't set! Test is detached from a binary file of a main program. Parallel building of this project might be failed!")
    elseif((DEFINED GQT_NAME_MAIN_BINARY) AND (DEFINED GQT_USED_OBJECTS))
        add_dependencies(${GQT_NAME_TEST} ${GQT_NAME_MAIN_BINARY})
    endif()

    target_include_directories(${GQT_NAME_TEST} PRIVATE ${CMAKE_SOURCE_DIR})
    link_qt_libraries(TARGET_NAME ${GQT_NAME_TEST} QT_LIBS "Test")

    foreach(USED_LIBRARY ${GQT_USED_LIBS})
        target_link_libraries(${GQT_NAME_TEST} PRIVATE ${USED_LIBRARY})
        add_dependencies(${GQT_NAME_TEST} ${USED_LIBRARY})
    endforeach()

    target_include_directories(${GQT_NAME_TEST} PRIVATE ${GQT_INCLUDE_DIRS})

    qtest_discover_tests(${GQT_NAME_TEST})
endfunction()
