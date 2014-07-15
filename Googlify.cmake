#! @file

# Include guard.
if (DEFINED GOOGLIFY_CMAKE_)
  return()
endif ()
set(GOOGLIFY_CMAKE_ TRUE)

option(IOS_BUILD "Build for iOS" OFF)
option(IOS_SIMULATOR_BUILD "Build for iOS simulator" OFF)
option(ENFORCE_CUSTOM_LIBCXX "Enforce link with custom libcxx" OFF)

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
  message(
      WARNING "xctest not found, Objective-C unit testing will be disabled.")
endif ()

set(JAVA_SUPPORTED TRUE)
if (${IOS_BUILD} OR ${IOS_SIMULATOR_BUILD})
  set(JAVA_SUPPORTED FALSE)
endif ()

set (PYTHON_SUPPORTED TRUE)
if (${IOS_BUILD} OR ${IOS_SIMULATOR_BUILD})
  set(PYTHON_SUPPORTED FALSE)
endif ()

include_directories(${PROJECT_SOURCE_DIR}/src)
include_directories(${PROJECT_BINARY_DIR}/src)

set(PYTHON_PATH)
list(APPEND PYTHON_PATH "${PROJECT_BINARY_DIR}/src")

#! @brief Adds compile definitions to the given target.
#! @param TARGET Name of the target (relative to the current package). It is
#!     assumed to be a C/C++/Objective-C target.
#! @param ARGN List of definitions to add.
function(add_compile_defs TARGET)
  get_full_target(${TARGET} FULL_TARGET)
  get_target_property(DEFS "${FULL_TARGET}" COMPILE_DEFINITIONS)
  if (NOT DEFS)
    set(DEFS)
  endif ()
  set_target_properties(
      "${FULL_TARGET}" PROPERTIES COMPILE_DEFINITIONS "${DEFS} ${ARGN}")
endfunction(add_compile_defs)

#! @brief Adds compile flags to the given target.
#! @param TARGET Name of the target (relative to the current package). It is
#!     assumed to be a C/C++/Objective-C target.
#! @param ARGN List of flags to add.
function(add_cxxflags TARGET)
  get_full_target(${TARGET} FULL_TARGET)
  get_target_property(FLAGS "${FULL_TARGET}" COMPILE_FLAGS)
  if (NOT FLAGS)
    set(FLAGS)
  endif ()
  set_target_properties(
      "${FULL_TARGET}" PROPERTIES COMPILE_FLAGS "${FLAGS} ${ARGN}")
endfunction(add_cxxflags)

#! @brief Adds link flags to the given target.
#! @param TARGET Name of the target (relative to the current package). It is
#!     assumed to be a C/C++/Objective-C target.
#! @param ARGN List of flags to add.
function(add_linkflags TARGET)
  get_full_target(${TARGET} FULL_TARGET)
  get_target_property(FLAGS "${FULL_TARGET}" LINK_FLAGS)
  if (NOT FLAGS)
    set(FLAGS)
  endif ()
  set_target_properties(
      "${FULL_TARGET}" PROPERTIES LINK_FLAGS "${FLAGS} ${ARGN}")
endfunction(add_linkflags)

#! @brief Makes a data file (either static of generated) accessible to the
#!     given target by creating a symlink of the file in the build directory of
#!     the target.
#! @param TARGET Name of the target (relative to the current package).
#! @param ARGN List of data files to add. A data file can be either an absolute
#!     path to an existing file or the full name of a target. A file name is
#!     assumed to be a target name if it does not yet exists and it is not mark
#!     as generated.
function(add_data TARGET)
  get_current_prefix(PREFIX)
  get_full_target(${TARGET} FULL_TARGET)
  foreach (DATA ${ARGN})
    get_filename_component(DIRNAME ${DATA} PATH)
    get_filename_component(NAME ${DATA} NAME)
    get_source_file_property(GENERATED ${DATA} GENERATED)
    if (EXISTS "${DATA}" OR GENERATED OR "${DATA}" MATCHES "/")
      if (GENERATED)
        set(GENERATE_TARGET ${FULL_TARGET}._${NAME})
        add_custom_target(${GENERATE_TARGET} DEPENDS ${DATA})
        add_dependencies(${FULL_TARGET} ${GENERATE_TARGET})
      endif ()
      add_custom_command(
        TARGET ${FULL_TARGET} POST_BUILD
        COMMAND ln -sf ${DATA} ${CMAKE_CURRENT_BINARY_DIR})
    else ()
      if (DATA MATCHES "^third_party\\.")
        set(DATA ${DATA}_target)
      endif ()
      get_output_file(${DATA} OUTPUT_FILE)
      add_custom_command(
        TARGET ${FULL_TARGET} POST_BUILD
        COMMAND ln -sf ${OUTPUT_FILE} ${CMAKE_CURRENT_BINARY_DIR}
        VERBATIM)
      add_dependencies(${FULL_TARGET} ${DATA})
    endif ()
  endforeach ()
endfunction(add_data)

#! @brief Makes a data file, whose path is given relatively to the current
#!     source directory, accessible to the given target by creating a symlink of
#!     the file in the build directory of the target.
#! @param TARGET Name of the target (relative to the current package).
#! @param ARGN List of data files to add, relative to the current source
#!     directory.
function(add_local_data TARGET)
  foreach (DATA ${ARGN})
    add_data(${TARGET} "${CMAKE_CURRENT_SOURCE_DIR}/${DATA}")
  endforeach ()
endfunction(add_local_data)

#! @brief Adds a file specified by its absolute path to a J2E archive or an iOS
#!     app. It can also be the absolute name of a target, in which case we
#!     include the output file of the given target.
#! @param TARGET Name of the target (relative to the current package).
#! @param SRC Absolute path to a file (static or generated) or full name of a
#!     target.
#! @param DEST Destination path, relative to the root of the J2E archive/iOS
#!     app.
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

#! @brief Implements the add_file(TARGET SRC DEST) logic for an iOS app.
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
  if ("${SRC}" MATCHES "^/")
    set(FULL_SRC "${SRC}")
  else ()
    set(FULL_SRC "${PROJECT_SOURCE_DIR}/${SRC}")
  endif ()
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
  if ("${SRC}" MATCHES "^/" OR EXISTS "${FULL_SRC}" OR GENERATED)
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

#! @brief Implements the add_file(TARGET SRC DEST) logic for an J2E archive.
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

#! @brief Adds a file specified by its absolute path to a J2E archive or an iOS
#!     app. It can also be the absolute name of a target, in which case we
#!     include the output file of the given target.
#! @param TARGET Name of the target (relative to the current package).
#! @param SRC Path to a file (static or generated) relative to the current
#!     directory or name of a target relative to the current package.
#! @param DEST Destination path, relative to the root of the J2E archive/iOS
#!     app.
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

#! @brief Adds a subdirectory to the build system conditionally on the value of
#!    COND. Useful to ignore a subdirectory specific to a different platform,
#!    most notably to bypass compilation of iOS apps when not targeting an iOS
#!    platform: you only need to use add_subdirectory_if(som_dir, IS_IOS)
#!    instead of add_subdirectory.
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
  prepare_sources_for_c(SRCS ${ARGN})
  add_executable(${FULL_TARGET} ${SRCS})
  set_target_properties(${FULL_TARGET} PROPERTIES OUTPUT_NAME ${TARGET})
  if (ENFORCE_CUSTOM_LIBCXX)
    link(${TARGET} third_party.libcxx)
  endif ()
endfunction()

#! @brief Creates a new target for a C++ executable in the current package.
#! @param TARGET Name of the target (relative to the current package).
#! @param ARGN List of C++ sources.
function(cc_library TARGET)
  get_full_target(${TARGET} FULL_TARGET)
  prepare_sources_for_c(SRCS ${ARGN})
  string(REGEX MATCHALL "[^;]+\\.(c|cc|m|mm)($|;)" HAS_CC_FILE "${SRCS}")
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
    add_library(${FULL_TARGET} ${SRCS} ${EMPTY_CC_FILE})
    add_dependencies(${FULL_TARGET} _empty_cc_file)
    set_target_properties(${FULL_TARGET} PROPERTIES LINKER_LANGUAGE CXX)
  else ()
    add_library(${FULL_TARGET} ${SRCS})
  endif ()
  set_target_properties(${FULL_TARGET} PROPERTIES OUTPUT_NAME ${TARGET})
  if (ENFORCE_CUSTOM_LIBCXX)
    link(${TARGET} third_party.libcxx)
  endif ()
endfunction(cc_library)

#! @brief Creates a new C++ test target in the current package.
#! @param TARGET Name of the target (relative to the current package).
#! @param ARGN List of C++ sources.
function(cc_test TARGET)
  cc_binary(${TARGET} ${ARGN})
  add_test(NAME ${TARGET} COMMAND ${TARGET})
endfunction(cc_test)

#! @brief Create a target to generate a file using a script. The script can be
#!     either an existing executable script, or the name of an executable
#!     target.
#! @param TARGET Name of the target (relative to the current package).
#! @param FILE Path to the generated file (absolute or relative to the current
#!     package).
#! @param SCRIPT Path to an executable file or name of an executable target. The
#!     target is considered relative to the current package if prefixed by a
#!     colon.
function(generated_file TARGET FILE SCRIPT)
  get_current_prefix(PREFIX)
  get_full_target(${TARGET} FULL_TARGET)
  if (SCRIPT MATCHES "^:")
    string(REGEX REPLACE "^:" "" SCRIPT ${SCRIPT})
    set(SCRIPT ${PREFIX}${SCRIPT})
  endif ()
  if (EXISTS SCRIPT)
    set(GENERATE_COMMAND ${SCRIPT} ${FILE} ${ARGN})
  else ()
    get_output_file(${SCRIPT} OUTPUT_FILE)
    set(GENERATE_COMMAND ${OUTPUT_FILE} ${FILE} ${ARGN})
  endif ()
  add_custom_command(
      OUTPUT ${FILE}
      COMMAND ${GENERATE_COMMAND}
      VERBATIM)
  add_custom_target(${FULL_TARGET} ALL SOURCES ${FILE})
  add_custom_target(${FULL_TARGET}_force COMMAND ${GENERATE_COMMAND} VERBATIM)
  set_target_properties(${FULL_TARGET} PROPERTIES TARGET_FILE ${FILE})
  set_target_properties(${FULL_TARGET}_force PROPERTIES TARGET_FILE ${FILE})
  if (NOT EXISTS SCRIPT)
    add_dependencies(${FULL_TARGET} ${SCRIPT})
    add_dependencies(${FULL_TARGET}_force ${SCRIPT})
  endif ()
endfunction()

#! @brief Returns the prefix of the current package.
#! @param RESULT Name of the parent scope variable where the prefix should be
#!     stored.
function(get_current_prefix RESULT)
  string(
      REGEX REPLACE "${PROJECT_SOURCE_DIR}(/src)?" "" TARGET_PATH
      ${CMAKE_CURRENT_SOURCE_DIR})
  if ("${TARGET_PATH}" STREQUAL "")
    set(${RESULT} "" PARENT_SCOPE)
  else ()
    string(REGEX REPLACE "^/" "" TARGET_PATH ${TARGET_PATH})
    string(REGEX REPLACE "/" "." TARGET_PATH ${TARGET_PATH})
    set(${RESULT} "${TARGET_PATH}." PARENT_SCOPE)
  endif ()
endfunction()

#! @brief Returns the absolute path to the classpath file of a Java target.
#! @param TARGET Absolute name of a Java target.
#! @param OUT Name of a variable to save the result in.
function(get_classpath_file_for_target TARGET OUT)
  get_directory_for_target("${TARGET}" TARGET_DIR)
  get_target_name("${TARGET}" TARGET_NAME)
  set(${OUT} "${TARGET_DIR}${CMAKE_FILES_DIRECTORY}/${TARGET_NAME}.classpath_"
      PARENT_SCOPE)
endfunction(get_classpath_file_for_target)

#! @brief Returns the absolute name to the classpath target of a Java target.
#! @param TARGET Absolute name of a Java target.
#! @param OUT Name of a variable to save the result in.
function(get_classpath_target_for_target TARGET OUT)
  set(${OUT} "${TARGET}.classpath_" PARENT_SCOPE)
endfunction(get_classpath_target_for_target)

#! @brief Returns the CMakeFiles subdirectory for the given target.
function(get_cmake_files_subdir TARGET OUT)
  get_full_target(${TARGET} FULL_TARGET)
  set(${OUT} ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${FULL_TARGET}.dir PARENT_SCOPE)
endfunction()

#! @brief Returns the absolute path to the build directory of a package.
function(get_directory_for_prefix PREFIX OUT)
  if ("${PREFIX}" STREQUAL "")
    set(${OUT} "${PROJECT_BINARY_DIR}/src" PARENT_SCOPE)
    return()
  endif ()
  get_package_path("${PREFIX}" PACKAGE_PATH)
  set(${OUT} "${PROJECT_BINARY_DIR}/src/${PACKAGE_PATH}" PARENT_SCOPE)
endfunction(get_directory_for_prefix)

#! @brief Returns the absolute path to the build directory of a target.
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

#! @brief Returns the path to the source directory of a package relative to the
#!     root source directory.
function(get_package_path PREFIX OUT)
  string(REGEX MATCHALL "[^\\.]+" PARTS "${PREFIX}")
  string(REPLACE ";" "/" PACKAGE_PATH "${PARTS}")
  set(${OUT} "${PACKAGE_PATH}" PARENT_SCOPE)
endfunction(get_package_path)

#! @brief Returns the name of the parent package.
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

#! @brief Returns the absolute path to the output file of a target.
#!     For executable targets this is the path to the executable binary.
#!     For library targets this is the path to the library file.
#!     For other targets, returns the value of the TARGET_FILE target property.
#! @warning This issues CMake generator expressions as it is in general not
#!     possible to get the name of the output file of a target if it has not
#!     already been processed by CMake. Generator expressions postpones the
#!     evaluation of the output file path.
#! @param TARGET Absolute name of a target.
#! @param OUT Name of a variable to save the result in.
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

#! @brief Returns the name of the target (last component of its full name).
function(get_target_name TARGET OUT)
  string(REGEX MATCHALL "[^\\.]+" PARTS "${TARGET}")
  list(GET PARTS -1 TARGET_NAME)
  set(${OUT} "${TARGET_NAME}" PARENT_SCOPE)
endfunction(get_target_name)

#! @brief Creates an iOS app target.
#! @param TARGET Name of the target to create, relative to the current package.
#! @param NAME Name of the app (example MyApp -> MyApp.app).
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

#! @brief Creates a J2E binary.
#! @param TARGET Name of the target to create, relative to the current package.
#!     The output binary will be name ${TARGET}.war
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

#! @brief Compiles Java source files into a jar library.
#! @param TARGET Name of the target to create, relative to the current package.
#! @param ARGN List of Java sources, relative to the current source directory.
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

#! @brief Creates an executable from an executable Java class.
#! @param TARGET Name of the target to create, relative to the current package.
#! @param SRC Java source file containing an executable Java class.
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

#! @brief Links a list of targets into the given target.
#! @param TARGET Name of the target into which the other targets should be
#!     linked, relative to the current package.
#! @param ARGN List of targets, referred either by their absolute name or by a
#!     colon followed by their name relative to the current package.
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

#! @brief Save as link but for frameworks (for both Mac and iOS platforms).
function(link_framework TARGET)
  get_full_target(${TARGET} FULL_TARGET)
  foreach (FRAMEWORK ${ARGN})
    target_link_libraries(${FULL_TARGET} "-framework ${FRAMEWORK}")
  endforeach ()
endfunction()

#! @deprecated Use link instead.
function(link_local TARGET)
  get_current_prefix(PREFIX)
  foreach (LIB ${ARGN})
    link(${TARGET} ${PREFIX}${LIB})
  endforeach ()
endfunction()

#! @deprecated Use link instead.
function(link_third_party TARGET LIB)
  get_full_target(${TARGET} FULL_TARGET)
  link_third_party_with_full_targets("${FULL_TARGET}" ${LIB})
endfunction(link_third_party)

#! @brief Auxiliary function used by link for third-party targets.
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

#! @brief Auxiliary function used by link for C/C++/Objective-C targets.
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
  get_target_property(
      COMPILE_DEFINITIONS ${LIB_TARGET} INTERFACE_COMPILE_DEFINITIONS)
  if (COMPILE_DEFINITIONS)
    set_target_properties(
        ${TARGET} PROPERTIES COMPILE_DEFINITIONS ${COMPILE_DEFINITIONS})
  endif ()
endfunction()

#! @brief Auxiliary function used by link for Java targets.
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

#! @brief Auxiliary function used by link for Python targets.
function(link_third_party_with_full_targets_python TARGET LIB)
  get_target(${LIB} LIB_TARGET)
  if (NOT LIB_TARGET)
    message(FATAL_ERROR "No such library: ${LIB}")
  endif ()
  add_dependencies(${TARGET} ${LIB_TARGET})
endfunction()

#! @brief Auxiliary function used by link for non third-party targets.
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

#! @brief Auxiliary function used by link for C/C++/Objective-C targets.
function(link_with_full_cmake_target_c FULL_TARGET LIB)
  get_target_property(IS_OBJC ${FULL_TARGET} IS_OBJC)
  get_target_property(IS_TEST ${FULL_TARGET} IS_TEST)
  if (IS_OBJC AND IS_TEST AND NOT OBJC_TEST_SUPPORTED)
    return()
  endif ()
  get_target_property(TYPE ${FULL_TARGET} TYPE)
  target_link_libraries(${FULL_TARGET} ${LIB})
endfunction()

#! @brief Auxiliary function used by link for Java targets.
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

#! @brief Auxiliary function used by link for Python targets.
function(link_with_full_cmake_target_python FULL_TARGET LIB)
  add_dependencies(${FULL_TARGET} ${LIB})
endfunction()

#! @brief Creates a new target for an Objective-C executable in the current
#!     package.
#! @param TARGET Name of the target (relative to the current package).
#! @param ARGN List of C/C++/Objective-C sources.
#! @warning ARC is enforced by default, and the Foundation framework linked into
#!     the executable.
function(objc_binary TARGET)
  prepare_sources_for_objc(${ARGN})
  cc_binary(${TARGET} ${ARGN})
  link_framework(${TARGET} Foundation)
  add_cxxflags(${TARGET} "-fobjc-arc")
  add_linkflags(${TARGET} "-all_load")
endfunction()

#! @brief Creates a new target for an Objective-C library in the current
#!     package.
#! @param TARGET Name of the target (relative to the current package).
#! @param ARGN List of C/C++/Objective-C sources.
#! @warning ARC is enforced by default, and the Foundation framework linked into
#!     the library.
function(objc_library TARGET)
  prepare_sources_for_objc(${ARGN})
  cc_library(${TARGET} ${ARGN})
  link_framework(${TARGET} Foundation)
  add_cxxflags(${TARGET} "-fobjc-arc")
  add_linkflags(${TARGET} "-all_load")
endfunction()


#! @brief If xctest was found on the machine, creates a new Objective-C test
#!     target in the current package.
#! @param TARGET Name of the target (relative to the current package).
#! @param ARGN List of C/C++/Objective-C sources.
#! @warning ARC is enforced by default, and the Foundation framework linked into
#!     the executable.
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

#! @brief Prepare the given package to be used as a Python package, by creating
#!     __init__.py files in all the parent directories.
function(prepare_python_package PREFIX OUT)
  if (NOT "${PREFIX}" STREQUAL "" AND NOT "${PREFIX}" STREQUAL ".")
    get_parent_prefix(${PREFIX} PARENT_PREFIX)
    get_directory_for_prefix(${PREFIX} PREFIX_DIRECTORY)
    prepare_python_package("${PARENT_PREFIX}" PARENT_INIT_PY)
    set(DEPENDS MAIN_DEPENDENCY ${PARENT_INIT_PY})
    set(INIT_PY "${PREFIX_DIRECTORY}/__init__.py")
  else ()
    set(DEPENDS)
    set(INIT_PY "${PROJECT_BINARY_DIR}/src/__init__.py")
  endif ()
  add_custom_command(
      OUTPUT ${INIT_PY}
      COMMAND echo "\
from pkgutil import extend_path\\n\
__path__ = extend_path(__path__, __name__)" > ${INIT_PY}
      ${DEPENDS}
      COMMENT "Creating empty package file ${INIT_PY}"
      VERBATIM)
  set(${OUT} ${INIT_PY} PARENT_SCOPE)
endfunction()

#! @brief CMake does not need to know about header files to compile a
#!     C/C++ target (it uses the compiler dependency graph for this purpose).
#!     We therefore filter the list of source files to remove the header files
#!     from it.
function(prepare_sources_for_c OUT)
  set(SRCS)
  foreach (SRC ${ARGN})
    get_source_file_property(GENERATED ${SRC} GENERATED)
    if (NOT SRC MATCHES "\\.h$" OR GENERATED)
      list(APPEND SRCS ${SRC})
    endif ()
  endforeach ()
  set(${OUT} ${SRCS} PARENT_SCOPE)
endfunction()

#! @brief Prepares Objective-C source files by defining their language based on
#!     their extension.
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

#! @brief Creates a new target for a Python executable in the current package.
#! @param TARGET Name of the target (relative to the current package).
#! @param SRC Name of the executable Python source file to use.
#! @warning A Shebang is added to use the python executable found
#!     in the environment.
function(py_binary TARGET SRC)
  get_current_prefix(PREFIX)
  get_full_target(${TARGET} FULL_TARGET)
  prepare_python_package(${PREFIX} INIT_PY)
  set(EXE ${CMAKE_CURRENT_BINARY_DIR}/${TARGET})
  set(FULL_SRC ${CMAKE_CURRENT_SOURCE_DIR}/${SRC})
  set(COMMANDS
      COMMAND echo "#!/usr/bin/env python" > ${EXE}
      COMMAND echo "import sys" >> ${EXE})
  foreach (python_path ${PYTHON_PATH})
    set(COMMANDS ${COMMANDS}
        COMMAND echo "sys.path.append('${python_path}')" >> ${EXE})
  endforeach ()
  set(COMMANDS ${COMMANDS}
      COMMAND echo "execfile('${FULL_SRC}')" >> ${EXE}
      COMMAND chmod +x ${EXE})
  add_custom_command(
    OUTPUT ${EXE}
    ${COMMANDS}
    VERBATIM)
  add_custom_target(${FULL_TARGET} ALL SOURCES ${FULL_SRC};${INIT_PY};${EXE})
  set_target_properties(
      ${FULL_TARGET} PROPERTIES IS_PYTHON TRUE TARGET_FILE ${EXE})
  link(${TARGET} third_party.virtualenv)
endfunction(py_binary)

#! @brief Creates a new Python library target in the current package.
#! @param TARGET Name of the target (relative to the current package).
#! @param ARGN List of Python source files.
function(py_library TARGET)
  get_current_prefix(PREFIX)
  get_full_target(${TARGET} FULL_TARGET)
  prepare_python_package(${PREFIX} INIT_PY)
  add_custom_target("${FULL_TARGET}" ALL SOURCES ${ARGN};${INIT_PY})
  set_target_properties(${FULL_TARGET} PROPERTIES IS_PYTHON TRUE)
  foreach (SRC ${ARGN})
    if (NOT SRC MATCHES "^${PROJECT_BINARY_DIR}")
      set(FULL_SRC ${CMAKE_CURRENT_SOURCE_DIR}/${SRC})
      set(link ${CMAKE_CURRENT_BINARY_DIR}/${SRC})
      add_custom_command(
        TARGET ${FULL_TARGET} POST_BUILD
        COMMAND ln -sf ${FULL_SRC} ${link}
        DEPENDS ${link}
        VERBATIM)
    endif ()
  endforeach ()
  link(${TARGET} third_party.virtualenv)
endfunction(py_library)

#! @brief Creates a new R executable target in the current package.
#! @param TARGET Name of the target (relative to the current package).
#! @param SRC Executable R source file to use.
function(r_binary TARGET SRC)
  get_full_target(${TARGET} FULL_TARGET)
  add_custom_target("${FULL_TARGET}" ALL SOURCES ${SRC})
  set_target_properties("${FULL_TARGET}" PROPERTIES IS_R TRUE)
  set(EXE ${CMAKE_CURRENT_BINARY_DIR}/${TARGET})
  set(FULL_SRC ${CMAKE_CURRENT_SOURCE_DIR}/${SRC})
  add_custom_command(
    TARGET "${FULL_TARGET}" POST_BUILD
    COMMAND echo "#!/usr/bin/env Rscript" > ${EXE}
    COMMAND echo "source(\"${FULL_SRC}\")" >> ${EXE}
    COMMAND chmod +x ${EXE}
    DEPENDS ${EXE}
    VERBATIM)
endfunction(r_binary)

#! @brief Marks a target as test only.
#! @todo Implement the logic to prevent linking a test target into a regular
#!     target.
function(test_only TARGET)

endfunction()

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
