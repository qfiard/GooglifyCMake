#! @file

# Include guard.
if (DEFINED GOOGLIFY_CMAKE_)
  return()
endif ()
set(GOOGLIFY_CMAKE_ TRUE)

option(IOS_BUILD "Build for iOS" OFF)
option(IOS_SIMULATOR_BUILD "Build for iOS simulator" OFF)

if (IOS_BUILD OR IOS_SIMULATOR_BUILD)
  set(IS_IOS 1)
else ()
  set(IS_IOS 0)
endif ()

if (IS_IOS)
  if (${IOS_BUILD})
    set(IOS_PLATFORM "OS")
  endif ()
  if (${IOS_SIMULATOR_BUILD})
    set(IOS_PLATFORM "SIMULATOR")
  endif ()
  include(${CMAKE_CURRENT_LIST_DIR}/support/iOS.cmake)
else ()
  option(BUILD_SHARED_LIBS "Build shared libraries" ON)
endif ()

set(OBJC_TEST_SUPPORTED TRUE)
find_program(XCTEST xctest)
if (NOT XCTEST)
  set(OBJC_TEST_SUPPORTED FALSE)
  message(WARNING "xctest not found, Objective-C unit testing will be disabled.")
endif ()

set(JAVA_SUPPORTED TRUE)
if (${IOS_BUILD} OR ${IOS_SIMULATOR_BUILD})
  set(JAVA_SUPPORTED FALSE)
endif ()

include_directories(${PROJECT_SOURCE_DIR}/src)
include_directories(${PROJECT_BINARY_DIR}/src)

set(PYTHON_PATH)
list(APPEND PYTHON_PATH "${PROJECT_BINARY_DIR}/src")

function(add_compile_defs TARGET)
  get_full_target(${TARGET} FULL_TARGET)
  get_target_property(DEFS "${FULL_TARGET}" COMPILE_DEFINITIONS)
  if (NOT DEFS)
    set(DEFS)
  endif ()
  set_target_properties(
      "${FULL_TARGET}" PROPERTIES COMPILE_DEFINITIONS "${DEFS} ${ARGN}")
endfunction(add_compile_defs)

function(add_cxxflags TARGET)
  get_full_target(${TARGET} FULL_TARGET)
  get_target_property(FLAGS "${FULL_TARGET}" COMPILE_FLAGS)
  if (NOT FLAGS)
    set(FLAGS)
  endif ()
  set_target_properties(
      "${FULL_TARGET}" PROPERTIES COMPILE_FLAGS "${FLAGS} ${ARGN}")
endfunction(add_cxxflags)

function(add_linkflags TARGET)
  get_full_target(${TARGET} FULL_TARGET)
  get_target_property(FLAGS "${FULL_TARGET}" LINK_FLAGS)
  if (NOT FLAGS)
    set(FLAGS)
  endif ()
  set_target_properties(
      "${FULL_TARGET}" PROPERTIES LINK_FLAGS "${FLAGS} ${ARGN}")
endfunction(add_linkflags)

function(add_data TARGET DATA)
  get_current_prefix(PREFIX)
  add_custom_command(
    TARGET "${PREFIX}${TARGET}" POST_BUILD
    COMMAND ln -sf ${DATA} ${CMAKE_CURRENT_BINARY_DIR})
endfunction(add_data)

function(add_local_data TARGET DATA)
  add_data(${TARGET} "${CMAKE_CURRENT_SOURCE_DIR}/${DATA}")
endfunction(add_local_data)

#! @brief Adds a file specified by its absolute path to a J2E archive or an iOS
#!     app. It can also be the absolute name of a target, in which case we
#!     include the output file of the given target.
function(add_file TARGET SRC DEST)
  get_full_target(${TARGET} FULL_TARGET)
  get_target_property(IS_J2E ${FULL_TARGET} IS_J2E)
  if (IS_J2E)
    add_file_j2e(${TARGET} ${SRC} ${DEST})
    return()
  endif ()
  get_target_property(IS_IOS_APP ${FULL_TARGET} IS_IOS_APP)
  if (IS_IOS_APP)
    add_file_ios_app(${TARGET} ${SRC} ${DEST})
    return()
  endif ()
  message(FATAL_ERROR
          "Target ${FULL_TARGET} has an unsupported target type for add_file")
endfunction(add_file)

#! @brief Adds a file specified by its absolute path to an iOS app. It can also
#!     be the absolute name of a target, in which case we include the output
#!     file of the given target.
function(add_file_ios_app TARGET SRC DEST)
  if (NOT IOS_BUILD AND NOT IOS_SIMULATOR_BUILD)
    return()
  endif ()
  get_full_target(${TARGET} FULL_TARGET)
  get_target_property(IS_IOS_APP ${FULL_TARGET} IS_IOS_APP)
  if (NOT IS_IOS_APP STREQUAL TRUE)
    message(FATAL_ERROR "Target ${FULL_TARGET} is not an iOS app")
  endif ()

  get_current_prefix(PREFIX)
  if (SRC MATCHES "^:")
    string(REGEX REPLACE "^:" "" SRC ${SRC})
    set(SRC ${PREFIX}${SRC})
  endif ()

  get_target_property(DIR_PATH ${FULL_TARGET} TARGET_FILE)
  set(DEST "${DIR_PATH}/${DEST}")
  set(FULL_SRC "${PROJECT_SOURCE_DIR}/${SRC}")
  if (DEST MATCHES "/$")
    set(DEST_DIR ${DEST})
  else ()
    get_filename_component(DEST_DIR ${DEST} DIRECTORY)
  endif ()
  add_custom_command(
    TARGET ${FULL_TARGET} PRE_BUILD
    COMMAND mkdir -p ${DEST_DIR}
    VERBATIM)
  get_source_file_property(GENERATED ${FULL_SRC} GENERATED)
  if (EXISTS "${FULL_SRC}" OR GENERATED)
    add_custom_command(
      TARGET ${FULL_TARGET} POST_BUILD
      COMMAND ditto ${FULL_SRC} ${DEST}
      MAIN_DEPENDENCY ${FULL_SRC}
      VERBATIM)
  else ()
    if (SRC MATCHES "^third_party\\.")
      set(SRC ${SRC}_target)
    endif ()
    get_output_file(${SRC} OUTPUT_FILE)
    add_custom_command(
      TARGET ${FULL_TARGET} POST_BUILD
      COMMAND ditto ${OUTPUT_FILE} ${DEST}
      VERBATIM)
    add_dependencies(${FULL_TARGET} ${SRC})
  endif ()
endfunction(add_file_ios_app)

#! @brief Adds a file specified by its absolute path to a J2E archive. It can
#!     also be the absolute name of a target, in which case we include the
#!     output file of the given target.
function(add_file_j2e TARGET SRC DEST)
  if (NOT JAVA_SUPPORTED)
    return()
  endif ()
  get_full_target(${TARGET} FULL_TARGET)
  get_target_property(IS_J2E ${FULL_TARGET} IS_J2E)
  if (NOT IS_J2E STREQUAL TRUE)
    message(FATAL_ERROR "Target ${FULL_TARGET} is not a j2e target")
  endif ()
  get_target_property(TEMP_DIR_PATH ${FULL_TARGET} TEMP_DIR_PATH)
  get_target_property(TEMP_DIR_TARGET ${FULL_TARGET} TEMP_DIR_TARGET)
  set(DEST "${TEMP_DIR_PATH}/${DEST}")
  set(FULL_SRC "${PROJECT_SOURCE_DIR}/${SRC}")
  if (DEST MATCHES "/$")
    set(DEST_DIR ${DEST})
  else ()
    get_filename_component(DEST_DIR ${DEST} DIRECTORY)
  endif ()
  add_custom_command(
    TARGET ${FULL_TARGET} PRE_BUILD
    COMMAND mkdir -p ${DEST_DIR}
    VERBATIM)
  add_custom_command(
    TARGET ${TEMP_DIR_TARGET} PRE_BUILD
    COMMAND mkdir -p ${DEST_DIR}
    VERBATIM)
  if (EXISTS "${FULL_SRC}")
    add_custom_command(
      TARGET ${TEMP_DIR_TARGET} POST_BUILD
      COMMAND cp -rf ${FULL_SRC} ${DEST}
      MAIN_DEPENDENCY ${FULL_SRC}
      VERBATIM)
  else ()
    set(TARGET ${SRC})
    set(TARGET_NAME ${TARGET})  # One level of indirection for MATCHES.
    if (TARGET_NAME MATCHES "^third_party\\.")
      set(TARGET ${TARGET}_target)
    endif ()
    get_output_file(${TARGET} OUTPUT_FILE)
    add_custom_command(
      TARGET ${TEMP_DIR_TARGET} POST_BUILD
      COMMAND cp -rf ${OUTPUT_FILE} ${DEST}
      # We copy the target linked libraries.
      COMMAND eval "\
          classpath=(\
              `cat $<TARGET_PROPERTY:${TARGET},CLASSPATH_FILE>`)$<SEMICOLON>\
          for lib in \${classpath[*]}$<SEMICOLON> do\
            if [ -f $lib ]$<SEMICOLON> then\
              cp $lib ${TEMP_DIR_PATH}/WEB-INF/lib$<SEMICOLON>\
            fi$<SEMICOLON>\
          done"
      MAIN_DEPENDENCY
      DEPENDS $<TARGET_PROPERTY:${TARGET},CLASSPATH_FILE>
      VERBATIM)
    add_dependencies(${TEMP_DIR_TARGET} ${SRC})
  endif ()
endfunction(add_file_j2e)

#! @brief Adds a file specified by its relative path to the current source
#!     directory to a J2E archive. It can also be the relative name of a target,
#!     in which case we include the output file of the given target.
function(add_local_file TARGET SRC DEST)
  get_current_prefix(PREFIX)
  if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${SRC}")
    string(REPLACE "${PROJECT_SOURCE_DIR}/" "" RELATIVE_PATH
           "${CMAKE_CURRENT_SOURCE_DIR}/${SRC}")
    add_file(${TARGET} "${RELATIVE_PATH}" ${DEST})
  else ()
    add_file(${TARGET} "${PREFIX}${SRC}" ${DEST})
  endif ()
endfunction(add_local_file)

function(add_subdirectory_if DIR COND)
  if (${COND})
    add_subdirectory(${DIR})
  endif ()
endfunction(add_subdirectory_if)

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
  string(REGEX MATCHALL "[^;]+\\.(cc|m|mm)($|;)" HAS_CC_FILE "${ARGN}")
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

function(generated_file TARGET FILE SCRIPT)
  get_current_prefix(PREFIX)
  get_full_target(${TARGET} FULL_TARGET)
  if (SCRIPT MATCHES "^:")
    string(REGEX REPLACE "^:" "" SCRIPT ${SCRIPT})
    set(SCRIPT ${PREFIX}${SCRIPT})
  endif ()
  add_custom_target(${FULL_TARGET})
  set_target_properties(${FULL_TARGET} PROPERTIES TARGET_FILE ${FILE})
  if (EXISTS SCRIPT)
    add_custom_command(
        TARGET ${FULL_TARGET} POST_BUILD
        COMMAND ${SCRIPT} ${FILE} ${ARGN}
        VERBATIM)
  else ()
    get_output_file(${SCRIPT} OUTPUT_FILE)
    add_custom_command(
        TARGET ${FULL_TARGET} POST_BUILD
        COMMAND ${OUTPUT_FILE} ${FILE} ${ARGN}
        VERBATIM)
    add_dependencies(${FULL_TARGET} ${SCRIPT})
  endif ()
endfunction()

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
  set(${OUT} "${TARGET_DIR}${CMAKE_FILES_DIRECTORY}/${TARGET_NAME}.classpath_"
      PARENT_SCOPE)
endfunction(get_classpath_file_for_target)

function(get_classpath_target_for_target TARGET OUT)
  set(${OUT} "${TARGET}.classpath_" PARENT_SCOPE)
endfunction(get_classpath_target_for_target)

#! @brief Returns the CMakeFiles subdirectory for the given target.
function(get_cmake_files_subdir TARGET OUT)
  get_full_target(${TARGET} FULL_TARGET)
  set(${OUT} ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${FULL_TARGET}.dir PARENT_SCOPE)
endfunction()

function(get_directory_for_prefix PREFIX OUT)
  if ("${PREFIX}" STREQUAL "")
    set(${OUT} "${PROJECT_BINARY_DIR}/src" PARENT_SCOPE)
    return()
  endif ()
  get_package_path("${PREFIX}" PACKAGE_PATH)
  set(${OUT} "${PROJECT_BINARY_DIR}/src/${PACKAGE_PATH}" PARENT_SCOPE)
endfunction(get_directory_for_prefix)

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

function(get_parent_prefix PREFIX OUT)
  if ("${PREFIX}" STREQUAL "")
    message(FATAL_ERROR "Root prefix has no parent.")
  endif ()
  string(REGEX MATCHALL "[^\\.]+" PARTS ${PREFIX})
  list(REMOVE_AT PARTS -1)
  if ("${PARTS}" STREQUAL "")
    set(${OUT} "" PARENT_SCOPE)
    return()
  endif ()
  string(REPLACE ";" "." PARENT_PREFIX_WITHOUT_TRAILING_DOT "${PARTS}")
  set(${OUT} "${PARENT_PREFIX_WITHOUT_TRAILING_DOT}." PARENT_SCOPE)
endfunction(get_parent_prefix)

function(get_output_file TARGET OUT)
  set(TARGET_TYPE "$<TARGET_PROPERTY:${TARGET},TYPE>")
  set(IS_EXE "$<STREQUAL:${TARGET_TYPE},EXECUTABLE>")
  set(IS_STATIC_LIB "$<STREQUAL:${TARGET_TYPE},STATIC_LIBRARY>")
  set(IS_MODULE_LIB "$<STREQUAL:${TARGET_TYPE},MODULE_LIBRARY>")
  set(IS_SHARED_LIB "$<STREQUAL:${TARGET_TYPE},SHARED_LIBRARY>")
  set(IS_LIB_OR_EXE
      "$<OR:${IS_EXE},${IS_STATIC_LIB},${IS_SHARED_LIB},${IS_MODULE_LIB}>")
  set(${OUT} "$<${IS_LIB_OR_EXE}:$<TARGET_FILE:${TARGET}>>$<$<NOT:${IS_LIB_OR_EXE}>:$<TARGET_PROPERTY:${TARGET},TARGET_FILE>>" PARENT_SCOPE)
endfunction(get_output_file)

function(get_target_name TARGET OUT)
  string(REGEX MATCHALL "[^\\.]+" PARTS "${TARGET}")
  list(GET PARTS -1 TARGET_NAME)
  set(${OUT} "${TARGET_NAME}" PARENT_SCOPE)
endfunction(get_target_name)

function(ios_app TARGET NAME)
  get_full_target(${TARGET} FULL_TARGET)
  if (NOT IOS_BUILD AND NOT IOS_SIMULATOR_BUILD)
    add_custom_target(${FULL_TARGET})
    set_target_properties(${FULL_TARGET} PROPERTIES IS_IOS_APP TRUE)
    return()
  endif ()
  set(DIR_PATH "${CMAKE_CURRENT_BINARY_DIR}/${NAME}.app")
  add_custom_target(${FULL_TARGET} ALL)
  add_custom_command(
    TARGET ${FULL_TARGET} PRE_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory ${DIR_PATH}
    VERBATIM)
  set_target_properties(${FULL_TARGET} PROPERTIES IS_IOS_APP TRUE)
  set_target_properties(${FULL_TARGET} PROPERTIES TARGET_FILE ${DIR_PATH})
endfunction(ios_app)

function(j2e_binary TARGET)
  get_full_target(${TARGET} FULL_TARGET)
  if (NOT JAVA_SUPPORTED)
    add_custom_target(${FULL_TARGET})
    set_target_properties(${FULL_TARGET} PROPERTIES IS_J2E TRUE)
    return()
  endif ()
  set(ARCHIVE "${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.war")
  set(TEMP_DIR_PATH
      "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${TARGET}.war")
  set(TEMP_DIR_TARGET "${TARGET}.war.dir_")
  add_custom_target(${TEMP_DIR_TARGET})
  add_custom_command(
    TARGET ${TEMP_DIR_TARGET} PRE_BUILD
    COMMAND mkdir -p ${TEMP_DIR_PATH} ${TEMP_DIR_PATH}/WEB-INF/lib
    VERBATIM)
  add_custom_target(${FULL_TARGET} ALL)
  add_dependencies(${FULL_TARGET} ${TEMP_DIR_TARGET})
  add_custom_command(
    TARGET ${FULL_TARGET} POST_BUILD
    COMMAND jar -cf ${ARCHIVE} .
    MAIN_DEPENDENCY ${TEMP_DIR_PATH}
    WORKING_DIRECTORY ${TEMP_DIR_PATH}
    VERBATIM)
  set_target_properties(${FULL_TARGET} PROPERTIES IS_J2E TRUE)
  set_target_properties(${FULL_TARGET} PROPERTIES TARGET_FILE "${ARCHIVE}")
  set_target_properties(
      ${FULL_TARGET} PROPERTIES TEMP_DIR_PATH "${TEMP_DIR_PATH}")
  set_target_properties(
      ${FULL_TARGET} PROPERTIES TEMP_DIR_TARGET "${TEMP_DIR_TARGET}")
endfunction(j2e_binary)

function(java_library TARGET)
  get_current_prefix(PREFIX)
  get_full_target(${TARGET} FULL_TARGET)
  if (NOT JAVA_SUPPORTED)
    add_custom_target(${FULL_TARGET})
    set_target_properties(${FULL_TARGET} PROPERTIES IS_JAVA TRUE)
    return()
  endif ()
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
          ret_code=$?\
          IFS=$OIFS\
          exit $ret_code"
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
  get_full_target(${TARGET} FULL_TARGET)
  if (NOT JAVA_SUPPORTED)
    add_custom_target(${FULL_TARGET})
    set_target_properties(${FULL_TARGET} PROPERTIES IS_JAVA TRUE)
    return()
  endif ()
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
        ret_code=$?\
        IFS=$OIFS\
        exit $ret_code"
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

function(link TARGET)
  foreach (LIB ${ARGN})
    # One level of indirection is needed for MATCHES.
    set(LIB_NAME ${LIB})
    if (LIB_NAME MATCHES "^:")
      string(REGEX REPLACE "^:" "" LIB_NAME ${LIB_NAME})
      link_local(${TARGET} ${LIB_NAME})
    else ()
      if (LIB_NAME MATCHES "^third_party\\.")
        link_third_party(${TARGET} ${LIB})
      else ()
        link_with_cmake_target(${TARGET} ${LIB})
      endif ()
    endif ()
  endforeach ()
endfunction(link)

function(link_framework TARGET)
  get_full_target(${TARGET} FULL_TARGET)
  foreach (FRAMEWORK ${ARGN})
    target_link_libraries(${FULL_TARGET} "-framework ${FRAMEWORK}")
  endforeach ()
#  get_target_property(LINK_FLAGS ${FULL_TARGET} LINK_FLAGS)
#  if (NOT LINK_FLAGS)
#    set(LINK_FLAGS)
#  endif ()
#  foreach (FRAMEWORK ${ARGN})
#    set(LINK_FLAGS "${LINK_FLAGS} -framework ${FRAMEWORK}")
#  endforeach ()
#  set_target_properties(${FULL_TARGET} PROPERTIES LINK_FLAGS ${LINK_FLAGS})
endfunction()

function(link_local TARGET)
  get_current_prefix(PREFIX)
  foreach (LIB ${ARGN})
    link(${TARGET} ${PREFIX}${LIB})
  endforeach ()
endfunction()

# Note: LIBS are in ARGN.
function(link_third_party TARGET LIB)
  get_full_target(${TARGET} FULL_TARGET)
  link_third_party_with_full_targets("${FULL_TARGET}" ${LIB})
endfunction(link_third_party)

function(link_third_party_with_full_targets TARGET LIB)
  get_target_property(IS_JAVA ${TARGET} IS_JAVA)
  if (${IS_JAVA} STREQUAL TRUE)
    link_third_party_with_full_targets_java(${TARGET} ${LIB})
    return()
  endif ()
  get_target_property(IS_PYTHON ${TARGET} IS_PYTHON)
  if (${IS_PYTHON} STREQUAL TRUE)
    link_third_party_with_full_targets_python(${TARGET} ${LIB})
    return()
  endif ()
  link_third_party_with_full_targets_c(${TARGET} ${LIB})
endfunction(link_third_party_with_full_targets)

function(link_third_party_with_full_targets_c TARGET LIB)
  get_target_property(IS_OBJC ${TARGET} IS_OBJC)
  get_target_property(IS_TEST ${TARGET} IS_TEST)
  if (IS_OBJC AND IS_TEST AND NOT OBJC_TEST_SUPPORTED)
    return()
  endif ()
  get_target(${LIB} LIB_TARGET)
  if (NOT LIB_TARGET)
    message(FATAL_ERROR "No such library: ${LIB}")
  endif ()
  add_dependencies(${TARGET} ${LIB_TARGET})
  get_libraries(${LIB} LIBRARIES)
  get_include_directories(${LIB} INCLUDE_DIRECTORIES)
  if (NOT "${LIBRARIES}" STREQUAL "")
    target_link_libraries(${TARGET} ${LIBRARIES})
  endif ()
  if (NOT "${INCLUDE_DIRECTORIES}" STREQUAL "")
    target_include_directories(${TARGET} PUBLIC ${INCLUDE_DIRECTORIES})
  endif ()
endfunction()

function(link_third_party_with_full_targets_java TARGET LIB)
  if (NOT JAVA_SUPPORTED)
    return()
  endif ()
  get_target(${LIB} LIB_TARGET)
  if (NOT LIB_TARGET)
    message(FATAL_ERROR "No such library: ${LIB}")
  endif ()
  get_classpath_target_for_target(${TARGET} CLASSPATH_TARGET)
  add_custom_command(
    TARGET ${CLASSPATH_TARGET} POST_BUILD
    COMMAND echo "${${LIB}}" >> $<TARGET_PROPERTY:${TARGET},CLASSPATH_FILE>
    COMMAND cat "${${LIB}}.classpath_" >>
        $<TARGET_PROPERTY:${TARGET},CLASSPATH_FILE>
    # Remove duplicate lines.
    COMMAND cat $<TARGET_PROPERTY:${TARGET},CLASSPATH_FILE> | sort | uniq | tee
        $<TARGET_PROPERTY:${TARGET},CLASSPATH_FILE> > /dev/null
    VERBATIM)
  add_dependencies(${CLASSPATH_TARGET} ${LIB_TARGET})
endfunction()

function(link_third_party_with_full_targets_python TARGET LIB)
  get_target(${LIB} LIB_TARGET)
  if (NOT LIB_TARGET)
    message(FATAL_ERROR "No such library: ${LIB}")
  endif ()
  add_dependencies(${TARGET} ${LIB_TARGET})
endfunction()

function(link_with_cmake_target TARGET LIB)
  get_full_target(${TARGET} FULL_TARGET)
  get_target_property(IS_JAVA ${FULL_TARGET} IS_JAVA)
  if (${IS_JAVA} STREQUAL TRUE)
    link_with_full_cmake_target_java(${FULL_TARGET} ${LIB})
    return()
  endif ()
  get_target_property(IS_PYTHON ${FULL_TARGET} IS_PYTHON)
  if (${IS_PYTHON} STREQUAL TRUE)
    link_with_full_cmake_target_python(${FULL_TARGET} ${LIB})
    return()
  endif ()
  link_with_full_cmake_target_c(${FULL_TARGET} ${LIB})
endfunction()

function(link_with_full_cmake_target_c FULL_TARGET LIB)
  get_target_property(IS_OBJC ${FULL_TARGET} IS_OBJC)
  get_target_property(IS_TEST ${FULL_TARGET} IS_TEST)
  if (IS_OBJC AND IS_TEST AND NOT OBJC_TEST_SUPPORTED)
    return()
  endif ()
  target_link_libraries(${FULL_TARGET} ${LIB})
endfunction()

function(link_with_full_cmake_target_java FULL_TARGET LIB)
  if (NOT JAVA_SUPPORTED)
    return()
  endif ()
  get_classpath_target_for_target(${FULL_TARGET} CLASSPATH_TARGET)
  get_classpath_target_for_target(${LIB} LIB_CLASSPATH_TARGET)
  get_output_file(${LIB} LIB_OUTPUT_FILE)
  add_custom_command(
    TARGET "${CLASSPATH_TARGET}" POST_BUILD
    COMMAND cat "$<TARGET_PROPERTY:${LIB},CLASSPATH_FILE>" >>
        "$<TARGET_PROPERTY:${FULL_TARGET},CLASSPATH_FILE>"
    COMMAND echo "${LIB_OUTPUT_FILE}" >>
        "$<TARGET_PROPERTY:${FULL_TARGET},CLASSPATH_FILE>"
    # Remove duplicate lines.
    COMMAND cat "$<TARGET_PROPERTY:${FULL_TARGET},CLASSPATH_FILE>" | sort | uniq |
        tee "$<TARGET_PROPERTY:${FULL_TARGET},CLASSPATH_FILE>" > /dev/null
    VERBATIM)
  add_dependencies(${FULL_TARGET} ${LIB})
  add_dependencies(${CLASSPATH_TARGET} ${LIB_CLASSPATH_TARGET})
endfunction()

function(link_with_full_cmake_target_python FULL_TARGET LIB)
  add_dependencies(${FULL_TARGET} ${LIB})
endfunction()

function(objc_binary TARGET)
  prepare_sources_for_objc(${ARGN})
  cc_binary(${TARGET} ${ARGN})
  link_framework(${TARGET} Foundation)
  add_cxxflags(${TARGET} "-fobjc-arc")
  add_linkflags(${TARGET} "-all_load")
endfunction()

function(objc_library TARGET)
  prepare_sources_for_objc(${ARGN})
  cc_library(${TARGET} ${ARGN})
  link_framework(${TARGET} Foundation)
  add_cxxflags(${TARGET} "-fobjc-arc")
  add_linkflags(${TARGET} "-all_load")
endfunction()

function(objc_test TARGET)
  get_full_target(${TARGET} FULL_TARGET)
  if (NOT OBJC_TEST_SUPPORTED)
    add_custom_target(${FULL_TARGET})
    set_target_properties(${FULL_TARGET} PROPERTIES IS_OBJC TRUE IS_TEST TRUE)
    return()
  endif ()

  get_cmake_files_subdir(${TARGET} CMAKE_FILES_SUBDIR)
  set(BUNDLE ${CMAKE_FILES_SUBDIR}/${TARGET}.xctest)
  set(BUNDLE_MACOS_DIR ${BUNDLE}/Contents/MacOS)
  set(TEST_EXE ${CMAKE_CURRENT_BINARY_DIR}/${TARGET})

  add_custom_command(
      OUTPUT ${TEST_EXE}
      COMMAND echo "#!/usr/bin/env bash" > ${TEST_EXE}
      COMMAND echo "\
        if [ $# -eq 0 ]$<SEMICOLON> then\
          ${XCTEST} -XCTest All ${BUNDLE}$<SEMICOLON>\
        else\
          ${XCTEST} -XCTest $@ ${BUNDLE}$<SEMICOLON>\
        fi" >> ${TEST_EXE}
      COMMAND chmod +x ${TEST_EXE}
      VERBATIM)
  set(TEST_EXE_TARGET ${FULL_TARGET}_)
  add_custom_target(${TEST_EXE_TARGET} SOURCES ${TEST_EXE})

  prepare_sources_for_objc(${ARGN})
  cc_test(${TARGET} ${ARGN})
  link_framework(${TARGET} Foundation)
  add_cxxflags(${TARGET} "-fobjc-arc")
  add_linkflags(${TARGET} "-all_load -bundle")
  set_target_properties(
      ${FULL_TARGET} PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY ${CMAKE_FILES_SUBDIR}
      IS_OBJC TRUE
      IS_TEST TRUE)
  add_custom_command(
      TARGET ${FULL_TARGET} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E make_directory ${BUNDLE_MACOS_DIR}
      COMMAND mv $<TARGET_FILE:${FULL_TARGET}> ${BUNDLE_MACOS_DIR}
      VERBATIM)
  add_dependencies(${FULL_TARGET} ${TEST_EXE_TARGET})
endfunction()

function(prepare_python_package PREFIX OUT)
  if ("${PREFIX}" STREQUAL "" OR "${PREFIX}" STREQUAL ".")
    set(INIT_PY "${PROJECT_BINARY_DIR}/src/__init__.py")
    add_custom_command(
        OUTPUT ${INIT_PY}
        COMMAND touch ${INIT_PY}
        COMMENT "Creating empty package file ${INIT_PY}")
  else ()
    get_parent_prefix(${PREFIX} PARENT_PREFIX)
    get_directory_for_prefix(${PREFIX} PREFIX_DIRECTORY)
    set(INIT_PY "${PREFIX_DIRECTORY}/__init__.py")
    prepare_python_package("${PARENT_PREFIX}" PARENT_INIT_PY)
    add_custom_command(
        OUTPUT ${INIT_PY}
        COMMAND touch ${INIT_PY}
        MAIN_DEPENDENCY ${PARENT_INIT_PY}
        COMMENT "Creating empty package file ${INIT_PY}")
  endif ()
  set(${OUT} ${INIT_PY} PARENT_SCOPE)
endfunction()

function(prepare_sources_for_objc)
  foreach (SRC ${ARGN})
    if (SRC MATCHES "\\.m$")
      set_source_files_properties(${SRC} PROPERTIES LANGUAGE C)
    endif ()
    if (SRC MATCHES "\\.mm$")
      set_source_files_properties(${SRC} PROPERTIES LANGUAGE CXX)
    endif ()
  endforeach ()
endfunction()

function(py_binary TARGET SRC)
  get_current_prefix(PREFIX)
  get_full_target(${TARGET} FULL_TARGET)
  prepare_python_package(${PREFIX} INIT_PY)
  add_custom_target(${FULL_TARGET} ALL SOURCES ${ARGN};${INIT_PY})
  set(exe ${CMAKE_CURRENT_BINARY_DIR}/${TARGET})
  set(src ${CMAKE_CURRENT_SOURCE_DIR}/${SRC})
  set_target_properties(
      ${FULL_TARGET} PROPERTIES IS_PYTHON TRUE TARGET_FILE ${exe})
  add_custom_command(
    TARGET ${FULL_TARGET} POST_BUILD
    COMMAND echo "#!/usr/bin/env python" > ${exe}
    COMMAND echo "import sys" >> ${exe}
    DEPENDS ${exe}
    VERBATIM)
  foreach (python_path ${PYTHON_PATH})
  add_custom_command(
    TARGET ${FULL_TARGET} POST_BUILD
    COMMAND echo "sys.path.append(\"${python_path}\")" >> ${exe}
    DEPENDS ${exe}
    VERBATIM)
  endforeach ()
  add_custom_command(
    TARGET ${FULL_TARGET} POST_BUILD
    COMMAND echo "execfile(\"${src}\")" >> ${exe}
    COMMAND chmod +x ${exe}
    DEPENDS ${exe}
    VERBATIM)
  link(${TARGET} third_party.virtualenv)
endfunction(py_binary)

function(py_library TARGET)
  get_current_prefix(PREFIX)
  get_full_target(${TARGET} FULL_TARGET)
  prepare_python_package(${PREFIX} INIT_PY)
  add_custom_target("${FULL_TARGET}" ALL SOURCES ${ARGN};${INIT_PY})
  set_target_properties(${FULL_TARGET} PROPERTIES IS_PYTHON TRUE)
  foreach (SRC ${ARGN})
    if (NOT SRC MATCHES "^${PROJECT_BINARY_DIR}")
      set(src ${CMAKE_CURRENT_SOURCE_DIR}/${SRC})
      set(link ${CMAKE_CURRENT_BINARY_DIR}/${SRC})
      add_custom_command(
        TARGET ${FULL_TARGET} POST_BUILD
        COMMAND ln -sf ${src} ${link}
        DEPENDS ${link}
        VERBATIM)
    endif ()
  endforeach ()
  link(${TARGET} third_party.virtualenv)
endfunction(py_library)

function(r_binary TARGET SRC)
  get_full_target(${TARGET} FULL_TARGET)
  add_custom_target("${FULL_TARGET}" ALL SOURCES ${SRC})
  set_target_properties("${FULL_TARGET}" PROPERTIES IS_R TRUE)
  set(exe ${CMAKE_CURRENT_BINARY_DIR}/${TARGET})
  set(src ${CMAKE_CURRENT_SOURCE_DIR}/${SRC})
  add_custom_command(
    TARGET "${FULL_TARGET}" POST_BUILD
    COMMAND echo "#!/usr/bin/env Rscript" > ${exe}
    COMMAND echo "source(\"${src}\")" >> ${exe}
    COMMAND chmod +x ${exe}
    DEPENDS ${exe}
    VERBATIM)
endfunction(r_binary)

# Src: https://github.com/maidsafe/MaidSafe/blob/master/cmake_modules/utils.cmake
function(underscores_to_camel_case IN OUT)
  string(REPLACE "_" ";" PIECES ${IN})
  foreach(PART ${PIECES})
    string(SUBSTRING ${PART} 0 1 INITIAL)
    string(SUBSTRING ${PART} 1 -1 PART)
    string(TOUPPER ${INITIAL} INITIAL)
    set(CAMELCASE ${CAMELCASE}${INITIAL}${PART})
  endforeach()
  set(${OUT} ${CAMELCASE} PARENT_SCOPE)
endfunction()
