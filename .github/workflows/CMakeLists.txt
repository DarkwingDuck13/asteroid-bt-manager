cmake_minimum_required(VERSION 3.16)
project(asteroid-bt-manager LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick DBus)

set(SOURCES
    src/main.cpp
    src/bluetoothmanager.cpp
    src/bluetoothmanager.h
    src/resources.qrc
)

add_executable(asteroid-bt-manager ${SOURCES})

target_link_libraries(asteroid-bt-manager PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::DBus
)

install(TARGETS asteroid-bt-manager RUNTIME DESTINATION bin)
install(FILES asteroid-bt-manager.desktop DESTINATION share/applications)