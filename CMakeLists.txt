cmake_minimum_required(VERSION 3.16)
project(hack)

set(CMAKE_CXX_STANDARD 14)

find_package(SFML 2.5 COMPONENTS graphics window system audio REQUIRED)

add_executable(hack main.cpp)
target_link_libraries(hack sfml-graphics sfml-window sfml-system sfml-audio)

