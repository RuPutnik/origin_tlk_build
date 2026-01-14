cmake_minimum_required(VERSION 3.16)

# Важные переменные, необходимо установить перекд включением данного модуля!

if(NOT DEFINED DEB_PACKAGE_NAME)
    message(FATAL_ERROR "[Package.cmake] You must set DEB_PACKAGE_NAME variable!")
endif()

if(NOT DEFINED DEB_PACKAGE_DESCRIPTION_SUMMARY)
    message(FATAL_ERROR "[Package.cmake] You must set DEB_PACKAGE_DESCRIPTION_SUMMARY variable!")
endif()

if(NOT DEFINED DEB_PACKAGE_CONTACT)
    message(FATAL_ERROR "[Package.cmake] You must set DEB_PACKAGE_CONTACT variable!")
endif()

if(NOT DEFINED DEB_PACKAGING_INSTALL_PREFIX)
    message(FATAL_ERROR "[Package.cmake] You must set DEB_PACKAGING_INSTALL_PREFIX variable!")
endif()

if(NOT DEFINED DEB_PACKAGE_HOMEPAGE_URL)
    message(WARNING "[Package.cmake] Variable DEB_PACKAGE_HOMEPAGE_URL wasn't set!")
endif()

if((NOT DEFINED DEB_PACKAGE_DESCRIPTION) AND (NOT DEFINED DEB_PACKAGE_DESCRIPTION_FILE))
    message(WARNING "[Package.cmake] Variable DEB_PACKAGE_DESCRIPTION and DEB_PACKAGE_DESCRIPTION_FILE wasn't set!")
endif()

# Задаем параметры deb-пакету

set(CPACK_PACKAGE_NAME ${DEB_PACKAGE_NAME}
    CACHE STRING "The resulting package name" FORCE
)
# which is useful in case of packing only selected components instead of the whole thing
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${DEB_PACKAGE_DESCRIPTION_SUMMARY}
    CACHE STRING "Package description for the package metadata" FORCE
)
set(CPACK_PACKAGE_VENDOR "MCC Development Company (08102)")
set(CPACK_PACKAGE_HOMEPAGE_URL ${DEB_PACKAGE_HOMEPAGE_URL})
set(CPACK_VERBATIM_VARIABLES YES)
set(CPACK_GENERATOR DEB)
set(CPACK_PACKAGE_INSTALL_DIRECTORY ${CPACK_PACKAGE_NAME})
set(CPACK_OUTPUT_FILE_PREFIX "${CMAKE_BINARY_DIR}/deb_packages")

set(CPACK_PACKAGING_INSTALL_PREFIX ${DEB_PACKAGING_INSTALL_PREFIX})

set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})

set(CPACK_PACKAGE_DESCRIPTION ${DEB_PACKAGE_DESCRIPTION})
set(CPACK_PACKAGE_DESCRIPTION_FILE ${DEB_PACKAGE_DESCRIPTION_FILE})

set(CPACK_PACKAGE_CONTACT ${DEB_PACKAGE_CONTACT})
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "MCC Development Company (08102)")

if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
    message(STATUS "[Package.cmake] LICENSE file exist!")
    set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
endif()
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
    message(STATUS "[Package.cmake] README.md file exist!")
    set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
endif()

# Использование имени пакета в формате Debian. Если установлено, то вместо some-application-0.9.2-Linux.deb
# будет использовано some-application_0.9.2_amd64.deb
set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
# that is if you want every group to have its own package,
# although the same will happen if this is not set (so it defaults to ONE_PER_GROUP)
# and CPACK_DEB_COMPONENT_INSTALL is set to YES
set(CPACK_COMPONENTS_GROUPING ALL_COMPONENTS_IN_ONE)#ONE_PER_GROUP)
# Без этого вы не сможете упаковать только указанный компонент
set(CPACK_DEB_COMPONENT_INSTALL YES)

include(CPack)

add_custom_target(createDEB COMMAND cpack -V --config "${CMAKE_BINARY_DIR}/CPackConfig.cmake")
