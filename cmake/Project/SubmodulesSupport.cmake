cmake_minimum_required(VERSION 3.16)

set(submodulesInit git submodule init)
set(submodulesUpdate git submodule update)
set(submodulesCheckoutDev git submodule foreach 'git checkout dev')
set(submodulesPull git submodule foreach 'git pull')

add_custom_target(pullAllSubmodules COMMAND ${submodulesPull} WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_custom_target(initAllSubmodules COMMAND ${submodulesInit} && ${submodulesUpdate} && ${submodulesCheckoutDev} WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

unset(submodulesInit)
unset(submodulesUpdate)
unset(submodulesCheckoutDev)
unset(submodulesPull)
