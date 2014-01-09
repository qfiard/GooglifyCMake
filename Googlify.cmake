#! @file

# Include guard.
if (DEFINED GOOGLIFY_CMAKE_)
  return()
endif ()
set(GOOGLIFY_CMAKE_ TRUE)

include_directories(${PROJECT_SOURCE_DIR}/src)
include_directories(${PROJECT_BINARY_DIR}/src)

function(add_data TARGET DATA)
  get_current_prefix(PREFIX)
  add_custom_command(
    TARGET "${PREFIX}${TARGET}" POST_BUILD
    COMMAND ln -sf ${DATA} ${CMAKE_CURRENT_BINARY_DIR})
endfunction(add_data)

function(add_local_data TARGET DATA)
  add_data(${TARGET} "${CMAKE_CURRENT_SOURCE_DIR}/${DATA}")
endfunction(add_local_data)

#! @brief Creates a new target for a C++ executable in the current package.
#! @param TARGET Name of the target (relative to the current package).
#! @param ARGN List of C++ sources.
function(cc_binary TARGET)
  get_full_target(${TARGET} FULL_TARGET)
  add_executable(${FULL_TARGET} ${ARGN})
  set_target_properties(${FULL_TARGET} PROPERTIES OUTPUT_NAME ${TARGET})
endfunction()

#! @brief Creates a new target for a C++ executable in the current package.
#! @param TARGET Name of the target (relative to the current package).
#! @param ARGN List of C++ sources.
function(cc_library TARGET)
  get_full_target(${TARGET} FULL_TARGET)
  string(REGEX MATCHALL "[^;]+\\.cc($|;)" HAS_CC_FILE "${ARGN}")
  if ("${HAS_CC_FILE}" STREQUAL "")
    # An empty cc file is required to link a header only library (which
    # although unnecessary is more simple to handle - e.g. if the library was to
    # acquire a cc file in the future, or to generalize the dependency graph
    # to header-only libraries).
    set(EMPTY_CC_FILE ${PROJECT_BINARY_DIR}/_empty.cc)

    # The following must be done in each new directory, let's do it every time
    # for simplicity.
    add_custom_command(
      OUTPUT ${EMPTY_CC_FILE}
      COMMAND > ${EMPTY_CC_FILE}
      COMMENT "Generating empty c++ file required for header only library")
    set_source_files_properties(${EMPTY_CC_FILE} PROPERTIES GENERATED TRUE)
    add_library(${FULL_TARGET} ${ARGN} ${EMPTY_CC_FILE})
    add_dependencies(${FULL_TARGET} _empty_cc_file)
    set_target_properties(${FULL_TARGET} PROPERTIES LINKER_LANGUAGE CXX)
  else ()
    add_library(${FULL_TARGET} ${ARGN})
  endif ()
  set_target_properties(${FULL_TARGET} PROPERTIES OUTPUT_NAME ${TARGET})
endfunction(cc_library)

function(cc_test TARGET)
  cc_binary(${TARGET} ${ARGN})
  add_test(NAME ${TARGET} COMMAND ${TARGET})
endfunction(cc_test)

#! @brief Returns the prefix of the current package.
#! @param RESULT Name of the parent scope variable where the prefix should be
#!     stored.
function(get_current_prefix RESULT)
  string(
      REGEX REPLACE ${PROJECT_SOURCE_DIR}/src "" TARGET_PATH
      ${CMAKE_CURRENT_SOURCE_DIR})
  if ("${TARGET_PATH}" STREQUAL "")
    set(${RESULT} "" PARENT_SCOPE)
  else ()
    string(REGEX REPLACE "^/" "" TARGET_PATH ${TARGET_PATH})
    string(REGEX REPLACE "/" "." TARGET_PATH ${TARGET_PATH})
    set(${RESULT} "${TARGET_PATH}." PARENT_SCOPE)
  endif ()
endfunction()

function(get_classpath_file_for_target TARGET OUT)
  get_directory_for_target("${TARGET}" TARGET_DIR)
  get_target_name("${TARGET}" TARGET_NAME)
  set(${OUT} "${TARGET_DIR}/${TARGET_NAME}.classpath_" PARENT_SCOPE)
endfunction(get_classpath_file_for_target)

function(get_classpath_target_for_target TARGET OUT)
  set(${OUT} "${TARGET}.classpath_" PARENT_SCOPE)
endfunction(get_classpath_target_for_target)

function(get_directory_for_target TARGET OUT)
  string(REGEX MATCHALL "[^\\.]+" PARTS ${TARGET})
  list(REMOVE_AT PARTS -1)
  string(REPLACE ";" "/" PACKAGE_PATH "${PARTS}")
  set(${OUT} "${PROJECT_BINARY_DIR}/src/${PACKAGE_PATH}" PARENT_SCOPE)
endfunction(get_directory_for_target)

#! @brief Returns the full name of a target in the current package.
function(get_full_target TARGET RESULT)
  get_current_prefix(PREFIX)
  set(${RESULT} ${PREFIX}${TARGET} PARENT_SCOPE)
endfunction()

function(get_package_path PREFIX OUT)
  string(REGEX MATCHALL "[^\\.]+" PARTS "${PREFIX}")
  string(REPLACE ";" "/" PACKAGE_PATH "${PARTS}")
  set(${OUT} "${PACKAGE_PATH}" PARENT_SCOPE)
endfunction(get_package_path)

function(get_target_name TARGET OUT)
  string(REGEX MATCHALL "[^\\.]+" PARTS "${TARGET}")
  list(GET PARTS -1 TARGET_NAME)
  set(${OUT} "${TARGET_NAME}" PARENT_SCOPE)
endfunction(get_target_name)

function(java_library TARGET)
  get_current_prefix(PREFIX)
  set(FULL_TARGET "${PREFIX}${TARGET}")
  set(LIB ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.jar)
  get_classpath_file_for_target(${FULL_TARGET} CLASSPATH_FILE)
  get_classpath_target_for_target(${FULL_TARGET} CLASSPATH_TARGET)
  add_custom_command(
    OUTPUT ${CLASSPATH_FILE}
    COMMAND > ${CLASSPATH_FILE}
    VERBATIM)
  add_custom_target(${CLASSPATH_TARGET} SOURCES ${CLASSPATH_FILE})
  add_custom_target(${FULL_TARGET} ALL SOURCES ${LIB})
  add_dependencies(${FULL_TARGET} ${CLASSPATH_TARGET})
  set_target_properties(${FULL_TARGET} PROPERTIES IS_JAVA TRUE)
  set_target_properties(${FULL_TARGET} PROPERTIES TARGET_FILE "${LIB}")
  set_target_properties(
      ${FULL_TARGET} PROPERTIES CLASSPATH_FILE "${CLASSPATH_FILE}")
  get_package_path("${PREFIX}" PACKAGE_PATH)
  set(CLASS_FILES)
  set(CLASS_FILES_AND_NESTED)
  foreach(SRC ${ARGN})
    get_filename_component(ABS_SRC ${SRC} ABSOLUTE)
    get_filename_component(SRC_WE ${SRC} NAME_WE)
    set(CLASS_FILE "${PACKAGE_PATH}/${SRC_WE}.class")
    set(NESTED_CLASSES "${PACKAGE_PATH}/${SRC_WE}\\$*.class")
    add_custom_command(
      OUTPUT ${CLASS_FILE}
      COMMAND eval "\
          classpath=(`cat ${CLASSPATH_FILE}`)$<SEMICOLON>\
          OIFS=$IFS$<SEMICOLON>\
          IFS=':'$<SEMICOLON>\
          if [ \${#classpath[@]} -ne 0 ]$<SEMICOLON> then\
            javac -cp \"\${classpath[*]}\" -d ${CMAKE_CURRENT_BINARY_DIR}\
                ${ABS_SRC}$<SEMICOLON>\
          else\
            javac -d ${CMAKE_CURRENT_BINARY_DIR} ${ABS_SRC}$<SEMICOLON>\
          fi$<SEMICOLON>\
          IFS=$OIFS"
      MAIN_DEPENDENCY ${ABS_SRC}
      VERBATIM)
    list(APPEND CLASS_FILES ${CLASS_FILE})
    list(APPEND CLASS_FILES_AND_NESTED ${CLASS_FILE})
    list(APPEND CLASS_FILES_AND_NESTED ${NESTED_CLASSES})
  endforeach()
  add_custom_command(
    OUTPUT ${LIB}
    COMMAND eval "\
        classes=\"${CLASS_FILES_AND_NESTED}\"$<SEMICOLON>\
        filtered_classes=()$<SEMICOLON>\
        for f in \${classes//$<SEMICOLON>/ }$<SEMICOLON> do\
          if [ -f \"$f\" ]$<SEMICOLON> then\
            filtered_classes+=(\"$f\")$<SEMICOLON>\
          fi$<SEMICOLON>\
        done$<SEMICOLON>\
        jar cf ${LIB} \${filtered_classes[*]}"
    DEPENDS ${CLASS_FILES}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    VERBATIM)
endfunction(java_library)

function(java_binary TARGET SRC)
  get_current_prefix(PREFIX)
  set(FULL_TARGET "${PREFIX}${TARGET}")
  set(JAR_FILE "${TARGET}.jar")
  get_classpath_file_for_target(${FULL_TARGET} CLASSPATH_FILE)
  get_classpath_target_for_target(${FULL_TARGET} CLASSPATH_TARGET)
  add_custom_command(
    OUTPUT ${CLASSPATH_FILE}
    COMMAND touch ${CLASSPATH_FILE}
    VERBATIM)
  add_custom_target(${CLASSPATH_TARGET} SOURCES ${CLASSPATH_FILE})
  add_custom_command(
    TARGET ${CLASSPATH_TARGET} PRE_LINK
    COMMAND > ${CLASSPATH_FILE}
    VERBATIM)
  add_custom_target(${FULL_TARGET} ALL SOURCES ${JAR_FILE})
  add_dependencies(${FULL_TARGET} ${CLASSPATH_TARGET})
  set_target_properties(${FULL_TARGET} PROPERTIES IS_JAVA TRUE)
  set_target_properties(${FULL_TARGET} PROPERTIES TARGET_FILE "${JAR_FILE}")
  set_target_properties(
      ${FULL_TARGET} PROPERTIES CLASSPATH_FILE "${CLASSPATH_FILE}")
  set(PACKAGE ${PREFIX})
  get_package_path("${PREFIX}" PACKAGE_PATH)
  set(EXE ${CMAKE_CURRENT_BINARY_DIR}/${TARGET})
  get_filename_component(ABS_SRC ${SRC} ABSOLUTE)
  get_filename_component(SRC_WE ${SRC} NAME_WE)
  set(CLASS_FILE "${PACKAGE_PATH}/${SRC_WE}.class")
  set(MANIFEST_FILE "${TARGET}_manifest.txt")
  add_custom_command(
    OUTPUT ${CLASS_FILE}
    COMMAND eval "\
        classpath=(`cat ${CLASSPATH_FILE}`)$<SEMICOLON>\
        OIFS=$IFS$<SEMICOLON>\
        IFS=':'$<SEMICOLON>\
        if [ \${#classpath[@]} -ne 0 ]$<SEMICOLON> then\
          javac -cp \"\${classpath[*]}\" -d ${CMAKE_CURRENT_BINARY_DIR}\
              ${ABS_SRC}$<SEMICOLON>\
        else\
          javac -d ${CMAKE_CURRENT_BINARY_DIR} ${ABS_SRC}$<SEMICOLON>\
        fi$<SEMICOLON>\
        IFS=$OIFS"
    MAIN_DEPENDENCY ${ABS_SRC}
    VERBATIM)
  add_custom_command(
    OUTPUT ${MANIFEST_FILE}
    COMMAND echo "Main-Class: ${PACKAGE}${SRC_WE}" > ${MANIFEST_FILE}
    COMMAND eval "\
        classpath=(`cat ${CLASSPATH_FILE}`)$<SEMICOLON>\
        OIFS=$IFS$<SEMICOLON>\
        IFS=' '$<SEMICOLON>\
        if [ \${#classpath[@]} -ne 0 ]$<SEMICOLON> then\
          echo \"Class-Path: \${classpath[*]}\" >> ${MANIFEST_FILE}$<SEMICOLON>\
        fi"
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    VERBATIM)
  add_custom_command(
    OUTPUT ${JAR_FILE}
    COMMAND jar cfm ${JAR_FILE} ${MANIFEST_FILE} ${CLASS_FILE}
    DEPENDS ${CLASS_FILE} ${MANIFEST_FILE}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    VERBATIM)
  add_custom_command(
    TARGET "${PREFIX}${TARGET}" POST_BUILD
    COMMAND echo "#!/bin/bash" > ${EXE}
    COMMAND echo "java -jar ${JAR_FILE}" >> ${EXE}
    COMMAND chmod +x ${EXE}
    DEPENDS ${JAR_FILE}
    VERBATIM)
endfunction(java_binary)

function(link TARGET LIB)
  message(STATUS "Linking >${LIB}<")
  # One level of indirection is needed for MATCHES.
  set(LIB_NAME ${LIB})
  if (LIB_NAME MATCHES "^third_party\\.")
    if (DEFINED "${LIB_NAME}")
      link_third_party(${TARGET} ${LIB})
    else ()
      link_with_cmake_target(${TARGET} ${LIB})
    endif ()
  else ()
    link_with_cmake_target(${TARGET} ${LIB})
  endif ()
endfunction(link)

function(link_local TARGET LIB)
  get_current_prefix(PREFIX)
  link(${TARGET} ${PREFIX}${LIB})
endfunction()

# Note: LIBS are in ARGN.
function(link_third_party TARGET LIB)
  get_full_target(${TARGET} FULL_TARGET)
  link_third_party_with_full_targets("${FULL_TARGET}" ${LIB})
endfunction(link_third_party)

function(link_third_party_with_full_targets_java TARGET LIB)
  string(TOUPPER ${LIB} ULIB)
  if (NOT DEFINED "${ULIB}")
    message(FATAL_ERROR "No such third-party library: ${LIB}")
  endif ()
  get_classpath_target_for_target(${TARGET} CLASSPATH_TARGET)
  add_custom_command(
    TARGET ${CLASSPATH_TARGET} POST_BUILD
    COMMAND echo "${${ULIB}}" >> $<TARGET_PROPERTY:${TARGET},CLASSPATH_FILE>
    COMMAND cat "${${ULIB}}.classpath_" >>
        $<TARGET_PROPERTY:${TARGET},CLASSPATH_FILE>
    # Remove duplicate lines.
    COMMAND cat $<TARGET_PROPERTY:${TARGET},CLASSPATH_FILE> | sort | uniq | tee
        $<TARGET_PROPERTY:${TARGET},CLASSPATH_FILE> > /dev/null
    VERBATIM)
  add_dependencies(${CLASSPATH_TARGET} ${MAVEN_LIBS_TARGET})
endfunction(link_third_party_with_full_targets_java)

function(link_third_party_with_full_targets_python TARGET LIB)
  if (NOT DEFINED "${ULIB}_TARGET" AND NOT DEFINED "${ULIB}")
    message(FATAL_ERROR "No such library: ${LIB}")
  endif ()
  if ("${LIB}" MATCHES "boost_.*")
    set(LIB_TARGET ${BOOST_TARGET})
  elseif ("${LIB}" MATCHES "opencv_.*")
    set(LIB_TARGET ${OPENCV_TARGET})
  else ()
    set(LIB_TARGET ${${ULIB}_TARGET})
  endif ()
  add_dependencies(${TARGET} ${LIB_TARGET})
endfunction(link_third_party_with_full_targets_python)

function(link_third_party_with_full_targets TARGET LIB)
  message(STATUS ${LIB} -> ${${LIB}})
  get_target_property(IS_JAVA "${TARGET}" IS_JAVA)
  if (${IS_JAVA} STREQUAL TRUE)
    link_third_party_with_full_targets_java(${TARGET} ${LIB})
    return()
  endif ()
  get_target_property(IS_PYTHON "${TARGET}" IS_PYTHON)
  if (${IS_PYTHON} STREQUAL TRUE)
    link_third_party_with_full_targets_python(${TARGET} ${LIB})
    return()
  endif ()
  if (NOT DEFINED "${LIB}")
    message(FATAL_ERROR "No such library: ${LIB}")
  endif ()
  # One level of indirection is needed for MATCHES.
  set(LIB_NAME ${LIB})
  if (LIB_NAME MATCHES "third_party\\.boost_.*")
    set(LIB_TARGET ${BOOST_TARGET})
  elseif (LIB_NAME MATCHES "third_party\\.opencv_.*")
    set(LIB_TARGET ${OPENCV_TARGET})
  else ()
    set(LIB_TARGET ${LIB}_target)
  endif ()
  add_dependencies(${TARGET} ${LIB_TARGET})
  target_link_libraries(${TARGET} ${${LIB}})
endfunction(link_third_party_with_full_targets)

function(link_with_cmake_target TARGET LIB)
  get_full_target(${TARGET} FULL_TARGET)
  get_target_property(IS_JAVA ${FULL_TARGET} IS_JAVA)
  if (${IS_JAVA} STREQUAL TRUE)
    link_with_cmake_target_java(${FULL_TARGET} ${LIB})
    return()
  endif ()
  get_target_property(IS_PYTHON ${FULL_TARGET} IS_PYTHON)
  if (${IS_PYTHON} STREQUAL TRUE)
    link_with_cmake_target_python(${FULL_TARGET} ${LIB})
    return()
  endif ()
  target_link_libraries(${FULL_TARGET} ${LIB})
endfunction()

function(link_with_cmake_target_java TARGET LIB)
  get_classpath_target_for_target(${TARGET} CLASSPATH_TARGET)
  get_classpath_target_for_target(${LIB} LIB_CLASSPATH_TARGET)
  add_custom_command(
    TARGET "${CLASSPATH_TARGET}" POST_BUILD
    COMMAND cat "$<TARGET_PROPERTY:${LIB},CLASSPATH_FILE>" >>
        "$<TARGET_PROPERTY:${TARGET},CLASSPATH_FILE>"
    COMMAND echo "$<TARGET_PROPERTY:${LIB},TARGET_FILE>" >>
        "$<TARGET_PROPERTY:${TARGET},CLASSPATH_FILE>"
    # Remove duplicate lines.
    COMMAND cat "$<TARGET_PROPERTY:${TARGET},CLASSPATH_FILE>" | sort | uniq |
        tee "$<TARGET_PROPERTY:${TARGET},CLASSPATH_FILE>" > /dev/null
    VERBATIM)
  add_dependencies(${TARGET} ${LIB})
  add_dependencies(${CLASSPATH_TARGET} ${LIB_CLASSPATH_TARGET})
endfunction(link_with_cmake_target_java)
