cmake_minimum_required(VERSION 4.4)
project(spawn LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Shell implementation
add_library(spawn_lib)

file(GLOB_RECURSE MODULE_FILES CONFIGURE_DEPENDS
        "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cppm"
)

target_sources(spawn_lib
        PUBLIC
        FILE_SET CXX_MODULES
        FILES
        ${MODULE_FILES}
)

add_executable(spawn
        src/main.cpp
)

target_link_libraries(spawn
        PRIVATE
        spawn_lib
)

# Tests
option(SPAWN_BUILD_TESTS "Build tests" ON)

if (SPAWN_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif ()

# Benchmarks
option(SPAWN_BUILD_BENCHMARKS "Build benchmarks" ON)

if (SPAWN_BUILD_BENCHMARKS)
    add_subdirectory(benchmarks)
endif ()
