cmake_minimum_required(VERSION 2.8.12)
project(codebase)

set(CXX11_FLAGS "-std=c++11 -stdlib=libc++")
set(CXX11_LINKER_FLAGS "-stdlib=libc++")

# C++11 is required for the `base` and `util` modules provided. You can safely
# remove the following lines if you do not intend to use these modules.
set(CMAKE_CXX_FLAGS "${CXX11_FLAGS} ${CMAKE_CXX_FLAGS}")
set(LINKER_FLAGS "${CXX11_LINKER_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS}")
set(CMAKE_SHARED_LINKER_FLAGS "${LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS}")

# To fully benefit from the module scheme, it is best to use shared libraries.
option(BUILD_SHARED_LIBS "Build shared libraries" ON)

# To enable unit-testing.
enable_testing()

include(ExternalProject)
include(Googlify.cmake)
include(ThirdPartyLibraries.cmake)

add_subdirectory(doc)
add_subdirectory(src)
