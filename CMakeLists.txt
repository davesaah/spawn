cmake_minimum_required(VERSION 4.4)
project(spawn LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(spawn
  src/main.cpp
)


file(GLOB_RECURSE MODULE_FILES CONFIGURE_DEPENDS
  "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cppm"
)

target_sources(spawn
  PRIVATE
  FILE_SET CXX_MODULES
  FILES
  ${MODULE_FILES}
)
