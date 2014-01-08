cmake_minimum_required(VERSION 2.8)

include(Googlify.cmake)
include(ExternalProject)

set(CMAKE_DOXYGEN_FILTER_PREFIX ${CMAKE_CURRENT_BINARY_DIR}/CMakeDoxygenFilter)
ExternalProject_Add(
  CMakeDoxygenFilter
  GIT_REPOSITORY https://github.com/saschazelzer/CMakeDoxygenFilter.git
  UPDATE_COMMAND ""  # No need for updates.
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_DOXYGEN_FILTER_PREFIX})
set(CMAKE_DOXYGEN_FILTER ${CMAKE_DOXYGEN_FILTER_PREFIX}/bin/CMakeDoxygenFilter)

find_package(Doxygen)
if(DOXYGEN_FOUND)
  set(DOXYFILE ${CMAKE_CURRENT_BINARY_DIR}/doc/Doxyfile)
  configure_file(doc/Doxyfile.in ${DOXYFILE})
  add_custom_target(doc
      ${DOXYGEN_EXECUTABLE} ${DOXYFILE}
      COMMENT "Generating API documentation with Doxygen" VERBATIM)
  add_dependencies(doc CMakeDoxygenFilter)
endif()

add_subdirectory(src)
