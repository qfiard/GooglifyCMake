include(ExternalProject)

# Options and paths to external libraries.
option(SKIP_PORTABILITY_WARNINGS "Skip portability warnings" OFF)
# Set the following two values to use external Boost libraries.
set(BOOST_ROOT "" CACHE STRING "Boost install directory")
set(BOOST_TIME_ZONE_CSV "" CACHE STRING "Boost time zone csv datafile")


set(SUPPORT_DIR ${CMAKE_CURRENT_LIST_DIR}/support)
set(THIRD_PARTY_BINARY_DIR ${PROJECT_BINARY_DIR}/third_party)
set(THIRD_PARTY_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/third_party)


# Escaping architectures.
string(REPLACE ";" "$<SEMICOLON>" ARCHS "${CMAKE_OSX_ARCHITECTURES}")
string(REPLACE ";" " -arch " ARCHS_AS_FLAGS "${CMAKE_OSX_ARCHITECTURES}")
if (NOT "${ARCHS_AS_FLAGS}" STREQUAL "")
  set(ARCHS_AS_FLAGS "-arch ${ARCHS_AS_FLAGS}")
endif ()
set(CMAKE_C_FLAGS_WITH_ARCHS "${ARCHS_AS_FLAGS} ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS_WITH_ARCHS "${ARCHS_AS_FLAGS} ${CMAKE_CXX_FLAGS}")
set(LDFLAGS_WITH_ARCHS "${ARCHS_AS_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS}")

# Sets the --host flag to the appropriate value if necessary.
if (IOS_BUILD)
  set(HOST "--host=arm")
endif ()

# Generic configure flags to select static or shared library compilation.
if (${BUILD_SHARED_LIBS})
  set(CONFIGURE_LIB_TYPE --enable-shared --disable-static)
else ()
  set(CONFIGURE_LIB_TYPE --disable-shared --enable-static)
endif ()

# The build systems used by some libraries do not allow the use of linker flags.
# In this case, we pass the linker flags directly to the compiler, with the
# "-Wl," prefix.
set(LINKER_AS_COMPILER_FLAGS)
set(FIRST TRUE)
foreach (FLAG ${CMAKE_SHARED_LINKER_FLAGS})
  if (FIRST)
    set(LINKER_AS_COMPILER_FLAGS "-Wl,${FLAG}")
  else ()
    set(LINKER_AS_COMPILER_FLAGS "${LINKER_AS_COMPILER_FLAGS} -Wl,${FLAG}")
  endif ()
endforeach ()

# Required executables.
find_program(ANT ant)
if (${ANT} STREQUAL ANT-NOTFOUND)
  message(FATAL_ERROR "Please install Ant available at http://ant.apache.org/.")
endif ()
find_program(GIT git)
if (${GIT} STREQUAL GIT-NOTFOUND)
  message(FATAL_ERROR "Please install Git available at http://git-scm.com/.")
endif ()
find_program(HG hg)
if (${HG} STREQUAL HG-NOTFOUND)
  message(FATAL_ERROR "Please install Mercurial available at http://mercurial.selenic.com.")
endif ()
find_program(SVN svn)
if (${SVN} STREQUAL SVN-NOTFOUND)
  message(FATAL_ERROR "Please install SVN available at http://subversion.apache.org/.")
endif ()

set(SET_INSTALL_NAMES "${SUPPORT_DIR}/set_install_names.sh")
set(CREATE_FAT_LIBS "${SUPPORT_DIR}/create_fat_libs.sh")

# A few convenient functions to define third-party libraries.
function(set_prefix OUT PREFIX)
  set(${OUT} ${THIRD_PARTY_BINARY_DIR}/${PREFIX} PARENT_SCOPE)
endfunction()

function(add_target OUT NAME)
  set(${OUT}_PREFIX ${THIRD_PARTY_BINARY_DIR}/${NAME} PARENT_SCOPE)
  set(${OUT}_TARGET third_party.${NAME}_target PARENT_SCOPE)
endfunction()

macro(set_header_only NAME)
  set(third_party.${NAME} ";")
endmacro()

macro(set_library NAME DIR)
  set(FULL_NAME third_party.${NAME})
  # Defines the target of the library, by default it is equal to the name of
  # library suffixed with _target.
  set(${FULL_NAME}_target ${FULL_NAME}_target)
  # Without the next line CMake would complain with header-only libraries.
  set(third_party.${NAME} ";")
  if (BUILD_SHARED_LIBS AND NOT "${DIR}" STREQUAL "")
    list(APPEND third_party.${NAME} -L${DIR})
  endif ()
  foreach (LIB ${ARGN})
    if (BUILD_SHARED_LIBS)
      list(APPEND third_party.${NAME} -l${LIB})
    else ()
      list(APPEND third_party.${NAME} ${DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${LIB}${CMAKE_STATIC_LIBRARY_SUFFIX})
    endif ()
  endforeach ()
endmacro()

macro(set_target_for_libraries TARGET)
  foreach (LIB ${ARGN})
    set(third_party.${LIB}_target ${TARGET})
  endforeach ()
endmacro()

macro(add_library_dependency NAME)
  foreach (LIB ${ARGN})
    if (NOT DEFINED ${LIB})
      # We assume that LIB is a system library.
      list(APPEND third_party.${NAME} -l${LIB})
    else ()
      list(APPEND third_party.${NAME} ${${LIB}})
    endif ()
  endforeach ()
endmacro()

function(add_external_project NAME)
  ExternalProject_Add(${NAME} ${ARGN})
  set_target_properties(${NAME} PROPERTIES EXCLUDE_FROM_ALL TRUE)
endfunction()

function(add_external_project_step)
  ExternalProject_Add_Step(${ARGN})
endfunction()

function(add_include_directory DIR)
  file(MAKE_DIRECTORY ${DIR})
  include_directories(${DIR})
endfunction()

function(add_link_directory DIR)
  file(MAKE_DIRECTORY ${DIR})
  link_directories(${DIR})
endfunction()

# Forward declarations.
add_target(APR apr)
add_target(APR_UTIL apr-util)
add_target(ARABICA arabica)
add_target(BERKELEY_DB berkeley-db)
add_target(BISON bison)
add_target(BOOST boost)
add_target(BZIP2 bzip2)
add_target(CLANG clang)
add_target(CLANG_OMP clang_omp)
add_target(CURL_ASIO curl-asio)
add_target(DLIB dlib)
add_target(EIGEN eigen)
add_target(FLEX flex)
add_target(FREETYPE freetype)
add_target(G2LOG g2log)
add_target(GCC gcc)
add_target(GFLAGS gflags)
add_target(GMOCK gmock)
add_target(GMP gmp)
add_target(GNUBASH gnubash)
add_target(GNUGREP gnugrep)
add_target(GNUTAR gnutar)
add_target(GTEST gtest)
add_target(HAPROXY haproxy)
add_target(ICU icu)
add_target(IMAP_2007F imap-2007f)
add_target(IWYU iwyu)
add_target(JSONCPP jsoncpp)
add_target(LDAP ldap)
add_target(LDAP_SASL ldap_sasl)
add_target(LIBCURL libcurl)
add_target(LIBCXX libcxx)
add_target(LIBCXX_HEADERS libcxx_headers)
add_target(LIBCXXABI libcxxabi)
add_target(LIBICONV libiconv)
add_target(LIBJPG libjpg)
add_target(LIBMCRYPT libmcrypt)
add_target(LIBMHASH libmhash)
add_target(LIBPNG libpng)
add_target(LIBXML libxml)
add_target(MARISA_TRIE marisa_trie)
add_target(MAVEN maven)
add_target(MAVEN_LIBS maven_libs)
add_target(MCRYPT mcrypt)
add_target(MILI mili)
add_target(MPC mpc)
add_target(MPFR mpfr)
add_target(MYSQL mysql)
add_target(MYSQLCPPCONN mysqlcppconn)
add_target(NGINX nginx)
add_target(NTP ntp)
add_target(OPENCV opencv)
add_target(OPENMP openmp)
add_target(OPENSSL openssl)
add_target(PCRE pcre)
add_target(PHP php)
add_target(PROTOBUF protobuf)
add_target(PROTOC protoc)
add_target(RAPIDXML rapidxml)
add_target(READLINE readline)
add_target(SHARK shark)
add_target(TBB tbb)
add_target(VIRTUALENV virtualenv)
add_target(XZ xz)
add_target(ZLIB zlib)

# Library directories.
if ("${BOOST_ROOT}" STREQUAL "")
  set(BOOST_LIB_DIR ${BOOST_PREFIX}/lib)
else ()
  set(BOOST_LIB_DIR ${BOOST_ROOT}/lib)
endif ()
set(CLANG_LIB_DIR ${CLANG_PREFIX}/lib)
set(LLVM_LIB_DIR ${CLANG_LIB_DIR})
set(OPENCV_LIB_DIR ${OPENCV_PREFIX}/lib)

# Third-party libraries definitions.
set_library(arabica ${ARABICA_PREFIX}/lib arabica)
set_library(boost_atomic ${BOOST_LIB_DIR} boost_atomic)
set_library(boost_chrono ${BOOST_LIB_DIR} boost_chrono)
set_library(boost_context ${BOOST_LIB_DIR} boost_context)
set_library(boost_coroutine ${BOOST_LIB_DIR} boost_coroutine)
set_library(boost_date_time ${BOOST_LIB_DIR} boost_date_time)
set_library(boost_exception ${BOOST_LIB_DIR} boost_exception)
set_library(boost_filesystem ${BOOST_LIB_DIR} boost_filesystem)
set_library(boost_graph ${BOOST_LIB_DIR} boost_graph)
set_library(boost_graph_parallel ${BOOST_LIB_DIR} boost_graph_parallel)
set_header_only(boost_headers)
set_library(boost_iostreams ${BOOST_LIB_DIR} boost_iostreams)
set_library(boost_locale ${BOOST_LIB_DIR} boost_locale)
set_library(boost_log ${BOOST_LIB_DIR} boost_log)
set_library(boost_math ${BOOST_LIB_DIR} boost_math)
set_library(boost_mpi ${BOOST_LIB_DIR} boost_mpi)
set_library(boost_program_options ${BOOST_LIB_DIR} boost_program_options)
set_library(boost_python ${BOOST_LIB_DIR} boost_python)
set_library(boost_random ${BOOST_LIB_DIR} boost_random)
set_library(boost_regex ${BOOST_LIB_DIR} boost_regex)
set_library(boost_serialization ${BOOST_LIB_DIR} boost_serialization)
set_library(boost_signals ${BOOST_LIB_DIR} boost_signals)
set_library(boost_system ${BOOST_LIB_DIR} boost_system)
set_library(boost_test ${BOOST_LIB_DIR} boost_test)
set_library(boost_thread ${BOOST_LIB_DIR} boost_thread)
set_library(boost_timer ${BOOST_LIB_DIR} boost_timer)
set_library(boost_wave ${BOOST_LIB_DIR} boost_wave)
set_library(clang ${CLANG_LIB_DIR} clang)
set_library(clang_analysis ${CLANG_LIB_DIR} clangAnalysis)
set_library(clang_arcmigrate ${CLANG_LIB_DIR} clangARCMigrate)
set_library(clang_ast ${CLANG_LIB_DIR} clangAST)
set_library(clang_ast_matchers ${CLANG_LIB_DIR} clangASTMatchers)
set_library(clang_basic ${CLANG_LIB_DIR} clangBasic)
set_library(clang_code_gen ${CLANG_LIB_DIR} clangCodeGen)
set_library(clang_driver ${CLANG_LIB_DIR} clangDriver)
set_library(clang_dynamic_ast_matchers ${CLANG_LIB_DIR} clangDynamicASTMatchers)
set_library(clang_edit ${CLANG_LIB_DIR} clangEdit)
set_library(clang_format ${CLANG_LIB_DIR} clangFormat)
set_library(clang_frontend ${CLANG_LIB_DIR} clangFrontend)
set_library(clang_frontend_tool ${CLANG_LIB_DIR} clangFrontendTool)
set_library(clang_index ${CLANG_LIB_DIR} clangIndex)
set_library(clang_lex ${CLANG_LIB_DIR} clangLex)
set_library(clang_parse ${CLANG_LIB_DIR} clangParse)
set_library(clang_rewrite_core ${CLANG_LIB_DIR} clangRewriteCore)
set_library(clang_rewrite_frontend ${CLANG_LIB_DIR} clangRewriteFrontend)
set_library(clang_sema ${CLANG_LIB_DIR} clangSema)
set_library(clang_serialization ${CLANG_LIB_DIR} clangSerialization)
set_library(
    clang_static_analyzer_checkers ${CLANG_LIB_DIR} clangStaticAnalyzerCheckers)
set_library(
    clang_static_analyzer_core ${CLANG_LIB_DIR} clangStaticAnalyzerCore)
set_library(
    clang_static_analyzer_frontend ${CLANG_LIB_DIR} clangStaticAnalyzerFrontend)
set_library(clang_tooling ${CLANG_LIB_DIR} clangTooling)
set_library(curl-asio ${CURL_ASIO_PREFIX}/lib curlasio)
set_library(dlib ${DLIB_PREFIX}/lib dlib)
set_library(eigen "")  # Eigen is header only.
set_library(flex ${FLEX_PREFIX}/lib fl)
set_library(g2log ${G2LOG_PREFIX}/lib lib_activeobject lib_g2logger)
set_library(gflags ${GFLAGS_PREFIX}/lib gflags)
set_library(gmock ${GMOCK_PREFIX}/lib gmock gmock_main)
set_library(gmp ${GMP_PREFIX}/lib gmp)
set_library(gtest ${GTEST_PREFIX}/lib gtest gtest_main)
set_library(jsoncpp ${JSONCPP_PREFIX}/lib jsoncpp)
set_library(libcurl ${LIBCURL_PREFIX}/lib curl)
set_library(libcxx ${LIBCXX_PREFIX}/lib c++)
set_library(libcxxabi ${LIBCXXABI_PREFIX}/lib c++abi)
set_library(libxml ${LIBXML_PREFIX}/lib xml2)
set_library(llvm_aarch64_asm_parser ${LLVM_LIB_DIR} LLVMAArch64AsmParser)
set_library(llvm_aarch64_asm_printer ${LLVM_LIB_DIR} LLVMAArch64AsmPrinter)
set_library(llvm_aarch64_code_gen ${LLVM_LIB_DIR} LLVMAArch64CodeGen)
set_library(llvm_aarch64_desc ${LLVM_LIB_DIR} LLVMAArch64Desc)
set_library(llvm_aarch64_disassembler ${LLVM_LIB_DIR} LLVMAArch64Disassembler)
set_library(llvm_aarch64_info ${LLVM_LIB_DIR} LLVMAArch64Info)
set_library(llvm_aarch64_utils ${LLVM_LIB_DIR} LLVMAArch64Utils)
set_library(llvm_analysis ${LLVM_LIB_DIR} LLVMAnalysis)
set_library(llvm_arm_asm_parser ${LLVM_LIB_DIR} LLVMARMAsmParser)
set_library(llvm_arm_asm_printer ${LLVM_LIB_DIR} LLVMARMAsmPrinter)
set_library(llvm_arm_code_gen ${LLVM_LIB_DIR} LLVMARMCodeGen)
set_library(llvm_arm_desc ${LLVM_LIB_DIR} LLVMARMDesc)
set_library(llvm_arm_disassembler ${LLVM_LIB_DIR} LLVMARMDisassembler)
set_library(llvm_arm_info ${LLVM_LIB_DIR} LLVMARMInfo)
set_library(llvm_asm_parser ${LLVM_LIB_DIR} LLVMAsmParser)
set_library(llvm_asm_printer ${LLVM_LIB_DIR} LLVMAsmPrinter)
set_library(llvm_bit_reader ${LLVM_LIB_DIR} LLVMBitReader)
set_library(llvm_bit_writer ${LLVM_LIB_DIR} LLVMBitWriter)
set_library(llvm_code_gen ${LLVM_LIB_DIR} LLVMCodeGen)
set_library(llvm_core ${LLVM_LIB_DIR} LLVMCore)
set_library(llvm_cpp_backend_code_gen ${LLVM_LIB_DIR} LLVMCppBackendCodeGen)
set_library(llvm_cpp_backend_info ${LLVM_LIB_DIR} LLVMCppBackendInfo)
set_library(llvm_debug_info ${LLVM_LIB_DIR} LLVMDebugInfo)
set_library(llvm_execution_engine ${LLVM_LIB_DIR} LLVMExecutionEngine)
set_library(llvm_hexagon_asm_printer ${LLVM_LIB_DIR} LLVMHexagonAsmPrinter)
set_library(llvm_hexagon_code_gen ${LLVM_LIB_DIR} LLVMHexagonCodeGen)
set_library(llvm_hexagon_desc ${LLVM_LIB_DIR} LLVMHexagonDesc)
set_library(llvm_hexagon_info ${LLVM_LIB_DIR} LLVMHexagonInfo)
set_library(llvm_inst_combine ${LLVM_LIB_DIR} LLVMInstCombine)
set_library(llvm_instrumentation ${LLVM_LIB_DIR} LLVMInstrumentation)
set_library(llvm_interpreter ${LLVM_LIB_DIR} LLVMInterpreter)
set_library(llvm_ipa ${LLVM_LIB_DIR} LLVMipa)
set_library(llvm_ipo ${LLVM_LIB_DIR} LLVMipo)
set_library(llvm_ir_reader ${LLVM_LIB_DIR} LLVMIRReader)
set_library(llvm_jit ${LLVM_LIB_DIR} LLVMJIT)
set_library(llvm_linker ${LLVM_LIB_DIR} LLVMLinker)
set_library(llvm_lto ${LLVM_LIB_DIR} LLVMLTO)
set_library(llvm_mc ${LLVM_LIB_DIR} LLVMMC)
set_library(llvm_mc_disassembler ${LLVM_LIB_DIR} LLVMMCDisassembler)
set_library(llvm_mc_jit ${LLVM_LIB_DIR} LLVMMCJIT)
set_library(llvm_mc_parser ${LLVM_LIB_DIR} LLVMMCParser)
set_library(llvm_mips_asm_parser ${LLVM_LIB_DIR} LLVMMipsAsmParser)
set_library(llvm_mips_asm_printer ${LLVM_LIB_DIR} LLVMMipsAsmPrinter)
set_library(llvm_mips_code_gen ${LLVM_LIB_DIR} LLVMMipsCodeGen)
set_library(llvm_mips_desc ${LLVM_LIB_DIR} LLVMMipsDesc)
set_library(llvm_mips_disassembler ${LLVM_LIB_DIR} LLVMMipsDisassembler)
set_library(llvm_mips_info ${LLVM_LIB_DIR} LLVMMipsInfo)
set_library(llvm_msp430_asm_printer ${LLVM_LIB_DIR} LLVMMSP430AsmPrinter)
set_library(llvm_msp430_code_gen ${LLVM_LIB_DIR} LLVMMSP430CodeGen)
set_library(llvm_msp430_desc ${LLVM_LIB_DIR} LLVMMSP430Desc)
set_library(llvm_msp430_info ${LLVM_LIB_DIR} LLVMMSP430Info)
set_library(llvm_nvptx_asm_printer ${LLVM_LIB_DIR} LLVMNVPTXAsmPrinter)
set_library(llvm_nvptx_code_gen ${LLVM_LIB_DIR} LLVMNVPTXCodeGen)
set_library(llvm_nvptx_desc ${LLVM_LIB_DIR} LLVMNVPTXDesc)
set_library(llvm_nvptx_info ${LLVM_LIB_DIR} LLVMNVPTXInfo)
set_library(llvm_obj_carcopts ${LLVM_LIB_DIR} LLVMObjCARCOpts)
set_library(llvm_object ${LLVM_LIB_DIR} LLVMObject)
set_library(llvm_option ${LLVM_LIB_DIR} LLVMOption)
set_library(llvm_power_pcasm_parser ${LLVM_LIB_DIR} LLVMPowerPCAsmParser)
set_library(llvm_power_pcasm_printer ${LLVM_LIB_DIR} LLVMPowerPCAsmPrinter)
set_library(llvm_power_pccode_gen ${LLVM_LIB_DIR} LLVMPowerPCCodeGen)
set_library(llvm_power_pcdesc ${LLVM_LIB_DIR} LLVMPowerPCDesc)
set_library(llvm_power_pcdisassembler ${LLVM_LIB_DIR} LLVMPowerPCDisassembler)
set_library(llvm_power_pcinfo ${LLVM_LIB_DIR} LLVMPowerPCInfo)
set_library(llvm_r600_asm_printer ${LLVM_LIB_DIR} LLVMR600AsmPrinter)
set_library(llvm_r600_code_gen ${LLVM_LIB_DIR} LLVMR600CodeGen)
set_library(llvm_r600_desc ${LLVM_LIB_DIR} LLVMR600Desc)
set_library(llvm_r600_info ${LLVM_LIB_DIR} LLVMR600Info)
set_library(llvm_runtime_dyld ${LLVM_LIB_DIR} LLVMRuntimeDyld)
set_library(llvm_scalar_opts ${LLVM_LIB_DIR} LLVMScalarOpts)
set_library(llvm_selection_dag ${LLVM_LIB_DIR} LLVMSelectionDAG)
set_library(llvm_sparc_asm_parser ${LLVM_LIB_DIR} LLVMSparcAsmParser)
set_library(llvm_sparc_asm_printer ${LLVM_LIB_DIR} LLVMSparcAsmPrinter)
set_library(llvm_sparc_code_gen ${LLVM_LIB_DIR} LLVMSparcCodeGen)
set_library(llvm_sparc_desc ${LLVM_LIB_DIR} LLVMSparcDesc)
set_library(llvm_sparc_disassembler ${LLVM_LIB_DIR} LLVMSparcDisassembler)
set_library(llvm_sparc_info ${LLVM_LIB_DIR} LLVMSparcInfo)
set_library(llvm_support ${LLVM_LIB_DIR} LLVMSupport)
set_library(llvm_system_zasm_parser ${LLVM_LIB_DIR} LLVMSystemZAsmParser)
set_library(llvm_system_zasm_printer ${LLVM_LIB_DIR} LLVMSystemZAsmPrinter)
set_library(llvm_system_zcode_gen ${LLVM_LIB_DIR} LLVMSystemZCodeGen)
set_library(llvm_system_zdesc ${LLVM_LIB_DIR} LLVMSystemZDesc)
set_library(llvm_system_zdisassembler ${LLVM_LIB_DIR} LLVMSystemZDisassembler)
set_library(llvm_system_zinfo ${LLVM_LIB_DIR} LLVMSystemZInfo)
set_library(llvm_table_gen ${LLVM_LIB_DIR} LLVMTableGen)
set_library(llvm_target ${LLVM_LIB_DIR} LLVMTarget)
set_library(llvm_transform_utils ${LLVM_LIB_DIR} LLVMTransformUtils)
set_library(llvm_vectorize ${LLVM_LIB_DIR} LLVMVectorize)
set_library(llvm_x86_asm_parser ${LLVM_LIB_DIR} LLVMX86AsmParser)
set_library(llvm_x86_asm_printer ${LLVM_LIB_DIR} LLVMX86AsmPrinter)
set_library(llvm_x86_code_gen ${LLVM_LIB_DIR} LLVMX86CodeGen)
set_library(llvm_x86_desc ${LLVM_LIB_DIR} LLVMX86Desc)
set_library(llvm_x86_disassembler ${LLVM_LIB_DIR} LLVMX86Disassembler)
set_library(llvm_x86_info ${LLVM_LIB_DIR} LLVMX86Info)
set_library(llvm_x86_utils ${LLVM_LIB_DIR} LLVMX86Utils)
set_library(llvm_xcore_asm_printer ${LLVM_LIB_DIR} LLVMXCoreAsmPrinter)
set_library(llvm_xcore_code_gen ${LLVM_LIB_DIR} LLVMXCoreCodeGen)
set_library(llvm_xcore_desc ${LLVM_LIB_DIR} LLVMXCoreDesc)
set_library(llvm_xcore_disassembler ${LLVM_LIB_DIR} LLVMXCoreDisassembler)
set_library(llvm_xcore_info ${LLVM_LIB_DIR} LLVMXCoreInfo)
set_library(marisa_trie ${MARISA_TRIE_PREFIX}/lib marisa)
set_library(mili "")  # Mili is header only.
set_library(mpc ${MPC_PREFIX}/lib mpc)
set_library(mpfr ${MPFR_PREFIX}/lib mpfr)
set_library(mysqlcppconn ${MYSQLCPPCONN_PREFIX}/lib mysqlcppconn)
set_library(opencv_bioinspired ${OPENCV_LIB_DIR} opencv_bioinspired)
set_library(opencv_calib3d ${OPENCV_LIB_DIR} opencv_calib3d)
set_library(opencv_contrib ${OPENCV_LIB_DIR} opencv_contrib)
set_library(opencv_core ${OPENCV_LIB_DIR} opencv_core)
set_library(opencv_cuda ${OPENCV_LIB_DIR} opencv_cuda)
set_library(opencv_cudaarithm ${OPENCV_LIB_DIR} opencv_cudaarithm)
set_library(opencv_cudabgsegm ${OPENCV_LIB_DIR} opencv_cudabgsegm)
set_library(opencv_cudafeatures2d ${OPENCV_LIB_DIR} opencv_cudafeatures2d)
set_library(opencv_cudafilters ${OPENCV_LIB_DIR} opencv_cudafilters)
set_library(opencv_cudaimgproc ${OPENCV_LIB_DIR} opencv_cudaimgproc)
set_library(opencv_cudaoptflow ${OPENCV_LIB_DIR} opencv_cudaoptflow)
set_library(opencv_cudastereo ${OPENCV_LIB_DIR} opencv_cudastereo)
set_library(opencv_cudawarping ${OPENCV_LIB_DIR} opencv_cudawarping)
set_library(opencv_features2d ${OPENCV_LIB_DIR} opencv_features2d)
set_library(opencv_flann ${OPENCV_LIB_DIR} opencv_flann)
set_library(opencv_highgui ${OPENCV_LIB_DIR} opencv_highgui)
set_library(opencv_imgproc ${OPENCV_LIB_DIR} opencv_imgproc)
set_library(opencv_legacy ${OPENCV_LIB_DIR} opencv_legacy)
set_library(opencv_ml ${OPENCV_LIB_DIR} opencv_ml)
set_library(opencv_nonfree ${OPENCV_LIB_DIR} opencv_nonfree)
set_library(opencv_objdetect ${OPENCV_LIB_DIR} opencv_objdetect)
set_library(opencv_ocl ${OPENCV_LIB_DIR} opencv_ocl)
set_library(opencv_optim ${OPENCV_LIB_DIR} opencv_optim)
set_library(opencv_photo ${OPENCV_LIB_DIR} opencv_photo)
set_library(opencv_shape ${OPENCV_LIB_DIR} opencv_shape)
set_library(opencv_softcascade ${OPENCV_LIB_DIR} opencv_softcascade)
set_library(opencv_stitching ${OPENCV_LIB_DIR} opencv_stitching)
set_library(opencv_superres ${OPENCV_LIB_DIR} opencv_superres)
set_library(opencv_ts ${OPENCV_LIB_DIR} opencv_ts)
set_library(opencv_video ${OPENCV_LIB_DIR} opencv_video)
set_library(opencv_videostab ${OPENCV_LIB_DIR} opencv_videostab)
set_library(openmp ${OPENMP_PREFIX}/lib iomp5)
set_library(openssl ${OPENSSL_PREFIX}/lib crypto ssl)
set_library(protobuf ${PROTOBUF_PREFIX}/lib protobuf)
set_library(readline ${READLINE_PREFIX}/lib readline history)
set_library(shark ${SHARK_PREFIX}/lib shark)
set_library(tbb ${TBB_PREFIX}/lib tbb)
set_library(zlib ${ZLIB_PREFIX}/lib z)

# Dependencies. We must be careful to define a DAG.
add_library_dependency(boost_filesystem third_party.boost_system)
add_library_dependency(openssl third_party.gmp)
add_library_dependency(libcurl third_party.openssl third_party.zlib)
add_library_dependency(curl-asio third_party.boost_system third_party.libcurl)
add_library_dependency(readline ncurses)
add_library_dependency(shark third_party.boost_serialization)

# Aliases.
add_library_dependency(boost_asio third_party.boost_system)

# Corrects library targets for modular libraries.
set_target_for_libraries(
    ${BOOST_TARGET} boost_asio boost_atomic boost_chrono boost_context
    boost_coroutine boost_date_time boost_exception boost_filesystem boost_graph
    boost_graph_parallel boost_headers boost_iostreams boost_locale boost_log
    boost_math boost_mpi boost_program_options boost_python boost_random
    boost_regex boost_serialization boost_signals boost_system boost_test
    boost_thread boost_timer boost_wave)
set_target_for_libraries(
    ${CLANG_TARGET} clang clang_analysis clang_arc_migrate clang_ast
    clang_ast_matchers clang_basic clang_code_gen clang_driver
    clang_dynamic_ast_matchers clang_edit clang_format clang_frontend
    clang_frontend_tool clang_index clang_lex clang_parse clang_rewrite_core
    clang_rewrite_frontend clang_sema clang_serialization
    clang_static_analyzer_checkers clang_static_analyzer_core
    clang_static_analyzer_frontend clang_tooling)
set_target_for_libraries(
    ${CLANG_TARGET} llvm_aarch64_asm_parser llvm_aarch64_asm_printer
    llvm_aarch64_code_gen llvm_aarch64_desc llvm_aarch64_disassembler
    llvm_aarch64_info llvm_aarch64_utils llvm_analysis llvm_arm_asm_parser
    llvm_arm_asm_printer llvm_arm_code_gen llvm_arm_desc llvm_arm_disassembler
    llvm_arm_info llvm_asm_parser llvm_asm_printer llvm_bit_reader
    llvm_bit_writer llvm_code_gen llvm_core llvm_cpp_backend_code_gen
    llvm_cpp_backend_info llvm_debug_info llvm_execution_engine
    llvm_hexagon_asm_printer llvm_hexagon_code_gen llvm_hexagon_desc
    llvm_hexagon_info llvm_inst_combine llvm_instrumentation llvm_interpreter
    llvm_ipa llvm_ipo llvm_ir_reader llvm_jit llvm_linker llvm_lto llvm_mc
    llvm_mc_disassembler llvm_mc_jit llvm_mc_parser llvm_mips_asm_parser
    llvm_mips_asm_printer llvm_mips_code_gen llvm_mips_desc
    llvm_mips_disassembler llvm_mips_info llvm_msp430_asm_printer
    llvm_msp430_code_gen llvm_msp430_desc llvm_msp430_info
    llvm_nvptx_asm_printer llvm_nvptx_code_gen llvm_nvptx_desc llvm_nvptx_info
    llvm_obj_carcopts llvm_object llvm_option llvm_power_pcasm_parser
    llvm_power_pcasm_printer llvm_power_pccode_gen llvm_power_pcdesc
    llvm_power_pcdisassembler llvm_power_pcinfo llvm_r600_asm_printer
    llvm_r600_code_gen llvm_r600_desc llvm_r600_info llvm_runtime_dyld
    llvm_scalar_opts llvm_selection_dag llvm_sparc_asm_parser
    llvm_sparc_asm_printer llvm_sparc_code_gen llvm_sparc_desc
    llvm_sparc_disassembler llvm_sparc_info llvm_support llvm_system_zasm_parser
    llvm_system_zasm_printer llvm_system_zcode_gen llvm_system_zdesc
    llvm_system_zdisassembler llvm_system_zinfo llvm_table_gen llvm_target
    llvm_transform_utils llvm_vectorize llvm_x86_asm_parser llvm_x86_asm_printer
    llvm_x86_code_gen llvm_x86_desc llvm_x86_disassembler llvm_x86_info
    llvm_x86_utils llvm_xcore_asm_printer llvm_xcore_code_gen llvm_xcore_desc
    llvm_xcore_disassembler llvm_xcore_info)
set_target_for_libraries(
    ${OPENCV_TARGET} opencv_bioinspired opencv_calib3d opencv_contrib
    opencv_core opencv_cuda opencv_cudaarithm opencv_cudabgsegm
    opencv_cudafeatures2d opencv_cudafilters opencv_cudaimgproc
    opencv_cudaoptflow opencv_cudastereo opencv_cudawarping opencv_features2d
    opencv_flann opencv_highgui opencv_imgproc opencv_legacy opencv_ml
    opencv_nonfree opencv_objdetect opencv_ocl opencv_optim opencv_photo
    opencv_shape opencv_softcascade opencv_stitching opencv_superres
    opencv_ts opencv_video opencv_videostab)


set(EIGEN_INCLUDE_PATH ${EIGEN_PREFIX}/include/eigen3)


set(GNUGREP ${GNUGREP_PREFIX}/bin/grep)
set(GNUTAR ${GNUTAR_PREFIX}/bin/tar)
set(MVN ${MAVEN_PREFIX}/bin/mvn)
set(PCREGREP ${PCRE_PREFIX}/bin/pcregrep)
set(XZ ${XZ_PREFIX}/bin/xz)

################################################################################
# External project inclusions.
################################################################################

################################################################################
# APR.
add_external_project(
  ${APR_TARGET}
  PREFIX ${APR_PREFIX}
  DOWNLOAD_DIR ${APR_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O apr-1.5.0.tar.bz2 http://www.mirrorservice.org/sites/ftp.apache.org//apr/apr-1.5.0.tar.bz2 &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/apr-1.5.0.tar.bz2.asc
          apr-1.5.0.tar.bz2 &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${APR_PREFIX}/download/apr-1.5.0.tar.bz2
  CONFIGURE_COMMAND
      <SOURCE_DIR>/configure --prefix=${APR_PREFIX} ${HOST} --enable-threads
  BUILD_IN_SOURCE 1)

################################################################################
# APR-util.
add_external_project(
  ${APR_UTIL_TARGET}
  PREFIX ${APR_UTIL_PREFIX}
  DOWNLOAD_DIR ${APR_UTIL_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O apr-util-1.5.3.tar.bz2 http://www.mirrorservice.org/sites/ftp.apache.org//apr/apr-util-1.5.3.tar.bz2 &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/apr-util-1.5.3.tar.bz2.asc
          apr-util-1.5.3.tar.bz2 &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${APR_UTIL_PREFIX}/download/apr-util-1.5.3.tar.bz2
  CONFIGURE_COMMAND
      <SOURCE_DIR>/configure --prefix=${APR_PREFIX} ${HOST}
      --with-apr=${APR_PREFIX}
      --with-berkeley-db=${BERKELEY_DB_PREFIX}
  BUILD_IN_SOURCE 1)
add_dependencies(${APR_UTIL_TARGET} ${APR_TARGET})
add_dependencies(${APR_UTIL_TARGET} ${BERKELEY_DB_TARGET})

################################################################################
# Arabica, an XML and HTML processing toolkit, providing SAX2, DOM, XPath, and
# XSLT implementations, written in Standard C++.
# See https://github.com/jezhiggins/arabica.
add_external_project(
  ${ARABICA_TARGET}
  PREFIX ${ARABICA_PREFIX}
  DOWNLOAD_COMMAND
      ${GIT} clone --depth 1 https://github.com/QuentinFiard/arabica.git
          ${ARABICA_TARGET}
  CMAKE_ARGS
      -DBOOST_ROOT=${BOOST_PREFIX}
      -DCMAKE_INCLUDE_PATH=${LIBXML_PREFIX}/include
      -DCMAKE_LIBRARY_PATH=${LIBXML_PREFIX}/lib

      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
      -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
      -DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DCMAKE_OSX_ARCHITECTURES=${ARCHS}
      -DCMAKE_INSTALL_PREFIX=${ARABICA_PREFIX}
      -DBUILD_ARABICA_EXAMPLES=OFF)
add_external_project_step(${ARABICA_TARGET} set_install_names
  COMMAND
      ${SET_INSTALL_NAMES} ${CMAKE_INSTALL_NAME_TOOL}
          ${CMAKE_SHARED_LIBRARY_SUFFIX}
  DEPENDEES install
  DEPENDS ${SET_INSTALL_NAMES}
  WORKING_DIRECTORY ${ARABICA_PREFIX}/lib)
add_include_directory(${ARABICA_PREFIX}/include)
add_include_directory(${ARABICA_PREFIX}/include/arabica)
add_dependencies(${ARABICA_TARGET} ${BOOST_TARGET})
add_dependencies(${ARABICA_TARGET} ${LIBXML_TARGET})

################################################################################
# BerkeleyDB.
add_external_project(
  ${BERKELEY_DB_TARGET}
  PREFIX ${BERKELEY_DB_PREFIX}
  DOWNLOAD_DIR ${BERKELEY_DB_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O db-6.0.20.tar.gz http://download.oracle.com/berkeley-db/db-6.0.20.tar.gz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/db-6.0.20.tar.gz.sig
          db-6.0.20.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${BERKELEY_DB_PREFIX}/download/db-6.0.20.tar.gz
  CONFIGURE_COMMAND
      <SOURCE_DIR>/dist/configure --prefix=${BERKELEY_DB_PREFIX} ${HOST}
      --enable-compat185
      --enable-cxx
      --enable-dbm
      ${CONFIGURE_LIB_TYPE})

################################################################################
# Bison.
add_external_project(
  ${BISON_TARGET}
  PREFIX ${BISON_PREFIX}
  DOWNLOAD_DIR ${BISON_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O bison-3.0.tar.gz http://ftp.gnu.org/gnu/bison/bison-3.0.tar.gz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/bison-3.0.tar.gz.sig
          bison-3.0.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${BISON_PREFIX}/download/bison-3.0.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=${BISON_PREFIX} ${HOST}
  BUILD_IN_SOURCE 1)
set(BISON_EXECUTABLE ${BISON_PREFIX}/bin/bison)

################################################################################
# Boost.
if ("${BOOST_ROOT}" STREQUAL "")
  set(BOOST_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ftemplate-depth-1024")
  if (IOS_BUILD)
    set(BOOST_CXX_FLAGS "${ARCHS_AS_FLAGS} ${BOOST_CXX_FLAGS}")
    set(BUILD_COMMAND
        b2 release toolset=clang-darwin
            architecture=arm
            target-os=iphone
            cxxflags=${BOOST_CXX_FLAGS}
            linkflags=${CMAKE_SHARED_LINKER_FLAGS}
            define=BOOST_NO_CXX11_NUMERIC_LIMITS
            define=BOOST_SYSTEM_NO_DEPRECATED
            --without-context
            --without-coroutine
            link=static install)
  elseif (IOS_SIMULATOR_BUILD)
    set(BOOST_CXX_FLAGS "${ARCHS_AS_FLAGS} ${BOOST_CXX_FLAGS}")
    set(BUILD_COMMAND
        b2 release toolset=clang-darwin
            architecture=x86
            target-os=iphone
            cxxflags=${BOOST_CXX_FLAGS}
            linkflags=${CMAKE_SHARED_LINKER_FLAGS}
            define=BOOST_NO_CXX11_NUMERIC_LIMITS
            define=BOOST_SYSTEM_NO_DEPRECATED
            --without-context
            --without-coroutine
            link=static install)
  else ()
    set(BUILD_COMMAND
        b2 release toolset=clang-darwin cxxflags=${BOOST_CXX_FLAGS}
            linkflags=${CMAKE_SHARED_LINKER_FLAGS}
            define=BOOST_NO_CXX11_NUMERIC_LIMITS
            define=BOOST_SYSTEM_NO_DEPRECATED install)
  endif ()
  add_external_project(
    ${BOOST_TARGET}
    PREFIX ${BOOST_PREFIX}
    DOWNLOAD_DIR ${BOOST_PREFIX}/download
    DOWNLOAD_COMMAND
        wget -O boost_1_54_0.tar.bz2 http://downloads.sourceforge.net/project/boost/boost/1.54.0/boost_1_54_0.tar.bz2?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fboost%2Ffiles%2Fboost%2F1.54.0%2F&ts=1383838140&use_mirror=optimate &&
        gpg --verify ${THIRD_PARTY_SOURCE_DIR}/boost_1_54_0.tar.bz2.sig
            boost_1_54_0.tar.bz2 &&
        cd <SOURCE_DIR> &&
        tar --strip-components 1 -xvf
            ${BOOST_PREFIX}/download/boost_1_54_0.tar.bz2
    CONFIGURE_COMMAND ./bootstrap.sh --prefix=${BOOST_PREFIX}
    BUILD_COMMAND ${BUILD_COMMAND}
    PATCH_COMMAND
        patch -Np0 < ${THIRD_PARTY_SOURCE_DIR}/boost.patch
    BUILD_IN_SOURCE 1)
  set(BOOST_TIME_ZONE_CSV
      "${BOOST_PREFIX}/src/${BOOST_TARGET}/libs/date_time/data/date_time_zonespec.csv")
else ()
  if (NOT EXISTS ${BOOST_TIME_ZONE_CSV})
    message(FATAL_ERROR
            "You must specify an existing path to BOOST_TIME_ZONE_CSV when "
            " using external Boost libraries.")
  endif ()
  set(BOOST_PREFIX ${BOOST_ROOT})
  add_custom_target(${BOOST_TARGET})
endif ()
add_include_directory(${BOOST_PREFIX}/include)

################################################################################
# bsdiff.
add_external_project(
  ${BSDIFF_TARGET}
  PREFIX ${BSDIFF_PREFIX}
  DOWNLOAD_COMMAND
      ${GIT} clone --depth 1 https://github.com/QuentinFiard/bsdiff.git
  CMAKE_ARGS
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
      -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
      -DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DCMAKE_OSX_ARCHITECTURES=${ARCHS}
  INSTALL_COMMAND
      ${CMAKE_COMMAND} -E make_directory ${BSDIFF_PREFIX}/bin &&
      cp -f bsdiff bspatch ${BSDIFF_PREFIX}/bin)

################################################################################
# bzip2.
add_external_project(
  ${BZIP2_TARGET}
  PREFIX ${BZIP2_PREFIX}
  DOWNLOAD_DIR ${BZIP2_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O bzip2-1.0.6.tar.gz http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/bzip2-1.0.6.tar.gz.sig
          bzip2-1.0.6.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${BZIP2_PREFIX}/download/bzip2-1.0.6.tar.gz
  CONFIGURE_COMMAND ""
  BUILD_COMMAND make
  INSTALL_COMMAND make install PREFIX=${BZIP2_PREFIX}
  BUILD_IN_SOURCE 1)

################################################################################
# Clang compiler.
add_external_project(
  ${CLANG_TARGET}
  PREFIX ${CLANG_PREFIX}
  DOWNLOAD_COMMAND
      # Patch file is specific to revision 199104, a missing header leads to an
      # undefined symbol without it. Might be unnecessary in the near future.
      ${SVN} export --force http://llvm.org/svn/llvm-project/llvm/trunk ${CLANG_TARGET} &&
      ${SVN} export --force http://llvm.org/svn/llvm-project/compiler-rt/trunk ${CLANG_TARGET}/projects/compiler-rt &&
      ${SVN} export --force http://llvm.org/svn/llvm-project/cfe/trunk ${CLANG_TARGET}/tools/clang
  PATCH_COMMAND
      patch -p0 < ${THIRD_PARTY_SOURCE_DIR}/clang.patch
  CMAKE_ARGS
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
      -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DCMAKE_OSX_ARCHITECTURES=${ARCHS}
      -DCMAKE_INSTALL_PREFIX=${CLANG_PREFIX})
add_external_project_step(
  ${CLANG_TARGET} set_install_names
  COMMAND ${SET_INSTALL_NAMES} ${CMAKE_INSTALL_NAME_TOOL}
      ${CMAKE_SHARED_LIBRARY_SUFFIX}
  DEPENDEES install
  DEPENDS ${SET_INSTALL_NAMES}
  WORKING_DIRECTORY ${CLANG_PREFIX}/lib)
add_include_directory(${CLANG_PREFIX}/include)

################################################################################
# Clang/OpenMP - OpenMP compatible clang compiler.
add_external_project(
  ${CLANG_OMP_TARGET}
  PREFIX ${CLANG_OMP_PREFIX}
  DOWNLOAD_COMMAND
      ${GIT} clone --depth 1 https://github.com/clang-omp/llvm clang_omp &&
      ${GIT} clone --depth 1 https://github.com/clang-omp/compiler-rt clang_omp/projects/compiler-rt &&
      ${GIT} clone --depth 1 -b clang-omp https://github.com/clang-omp/clang clang_omp/tools/clang
  PATCH_COMMAND
      patch -p0 < ${THIRD_PARTY_SOURCE_DIR}/clang_omp.patch
  CMAKE_ARGS
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DCMAKE_C_FLAGS=${RELEASE_FLAGS}
      -DCMAKE_CXX_FLAGS=${RELEASE_FLAGS}
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_OSX_ARCHITECTURES=${ARCHS}
  INSTALL_COMMAND
      echo "This will replace your clang compiler with Clang/OpenMP." &&
      sudo make install)

################################################################################
# curl-asio, an asynchronous CURL wrapper based on Boost Asio.
# See https://github.com/mologie/curl-asio.
set(CURL_ASIO_C_FLAGS "-I${LIBCURL_PREFIX}/include ${CMAKE_C_FLAGS}")
set(CURL_ASIO_CXX_FLAGS "-I${LIBCURL_PREFIX}/include ${CMAKE_CXX_FLAGS}")
set(CURL_ASIO_LINKER_FLAGS "${third_party.libcurl} ${LINKER_FLAGS}")
add_external_project(
  ${CURL_ASIO_TARGET}
  PREFIX ${CURL_ASIO_PREFIX}
  DOWNLOAD_COMMAND
      ${GIT} clone --depth 1 https://github.com/QuentinFiard/curl-asio.git
          ${CURL_ASIO_TARGET}
  CMAKE_ARGS
      -DBOOST_ROOT=${BOOST_PREFIX}
      -DBUILD_EXAMPLES=OFF

      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DCMAKE_C_FLAGS=${CURL_ASIO_C_FLAGS}
      -DCMAKE_CXX_FLAGS=${CURL_ASIO_CXX_FLAGS}
      -DCMAKE_SHARED_LINKER_FLAGS=${CURL_ASIO_LINKER_FLAGS}
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DCMAKE_OSX_ARCHITECTURES=${ARCHS}
      -DCMAKE_INSTALL_PREFIX=${CURL_ASIO_PREFIX}
      -DCURL_ROOT=${LIBCURL_PREFIX})
add_external_project_step(
  ${CURL_ASIO_TARGET} set_install_names
  COMMAND ${SET_INSTALL_NAMES} ${CMAKE_INSTALL_NAME_TOOL}
      ${CMAKE_SHARED_LIBRARY_SUFFIX}
  DEPENDEES install
  DEPENDS ${SET_INSTALL_NAMES}
  WORKING_DIRECTORY ${CURL_ASIO_PREFIX}/lib)
add_include_directory(${CURL_ASIO_PREFIX}/include)
add_dependencies(${CURL_ASIO_TARGET} ${BOOST_TARGET})
add_dependencies(${CURL_ASIO_TARGET} ${LIBCURL_TARGET})

################################################################################
# dlib.
add_external_project(
  ${DLIB_TARGET}
  PREFIX ${DLIB_PREFIX}
  DOWNLOAD_DIR ${DLIB_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O dlib-18.5.tar.bz2 http://downloads.sourceforge.net/project/dclib/dlib/v18.5/dlib-18.5.tar.bz2?r=http%3A%2F%2Fdlib.net%2Fcompile.html&ts=1383664047 &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/dlib-18.5.tar.bz2.sig
          dlib-18.5.tar.bz2 &&
      tar --strip-components 1 -xvf
          ${DLIB_PREFIX}/download/dlib-18.5.tar.bz2 dlib-18.5/dlib &&
      rm -rf <SOURCE_DIR> &&
      mv ${DLIB_PREFIX}/download/dlib/ <SOURCE_DIR>
  CMAKE_ARGS
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
      -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
      -DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DCMAKE_OSX_ARCHITECTURES=${ARCHS}
      -DCMAKE_INSTALL_PREFIX=${DLIB_PREFIX}
  INSTALL_COMMAND
      ${CMAKE_COMMAND} -E make_directory ${DLIB_PREFIX}/lib &&
      cp -f libdlib.a ${DLIB_PREFIX}/lib &&
      ${CMAKE_COMMAND} -E make_directory ${DLIB_PREFIX}/include/dlib &&
      cd <SOURCE_DIR> &&
      find . -name "*.h" |
      cpio -dp <INSTALL_DIR>/include/dlib)
add_include_directory(${DLIB_PREFIX}/include)

################################################################################
# Eigen.
add_external_project(
  ${EIGEN_TARGET}
  PREFIX ${EIGEN_PREFIX}
  DOWNLOAD_COMMAND
      ${HG} clone https://bitbucket.org/eigen/eigen ${EIGEN_TARGET}
  CMAKE_ARGS
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
      -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
      -DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DCMAKE_OSX_ARCHITECTURES=${ARCHS}
      -DCMAKE_INSTALL_PREFIX=${EIGEN_PREFIX}
      # Do not add register for pkg-config as it would require root permissions.
      -DEIGEN_BUILD_PKGCONFIG=OFF
      -DGMP_INCLUDES=${GMP_PREFIX}/include
      -DGMP_LIBRARIES=${GMP_PREFIX}/lib
      -DMPFR_INCLUDES=${MPFR_PREFIX}/include
      -DMPFR_LIBRARIES=${MPFR_PREFIX}/lib)
add_include_directory(${EIGEN_INCLUDE_PATH})
add_dependencies(${EIGEN_TARGET} ${GMP_TARGET})
add_dependencies(${EIGEN_TARGET} ${MPFR_TARGET})

################################################################################
# Flex.
add_external_project(
  ${FLEX_TARGET}
  PREFIX ${FLEX_PREFIX}
  DOWNLOAD_DIR ${FLEX_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O flex-2.5.37.tar.bz2 http://downloads.sourceforge.net/project/flex/flex-2.5.37.tar.bz2?r=http%3A%2F%2Fflex.sourceforge.net%2F&ts=1382395008&use_mirror=kent &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/flex-2.5.37.tar.bz2.sig
          flex-2.5.37.tar.bz2 &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${FLEX_PREFIX}/download/flex-2.5.37.tar.bz2
  CONFIGURE_COMMAND ./configure --prefix=${FLEX_PREFIX} ${HOST}
  BUILD_IN_SOURCE 1)
add_include_directory(${FLEX_PREFIX}/include)
set(FLEX_EXECUTABLE ${FLEX_PREFIX}/bin/flex++)

################################################################################
# Freetype.
add_external_project(
  ${FREETYPE_TARGET}
  PREFIX ${FREETYPE_PREFIX}
  DOWNLOAD_DIR ${FREETYPE_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O freetype-2.5.1.tar.bz2 http://download.savannah.gnu.org/releases/freetype/freetype-2.5.1.tar.bz2 &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/freetype-2.5.1.tar.bz2.sig
          freetype-2.5.1.tar.bz2 &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${FREETYPE_PREFIX}/download/freetype-2.5.1.tar.bz2
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${FREETYPE_PREFIX} ${HOST}
  BUILD_COMMAND make
  INSTALL_COMMAND
      make install &&
      ln -s ${FREETYPE_PREFIX}/include/freetype2
          ${FREETYPE_PREFIX}/include/freetype2/freetype)

################################################################################
# g2log.
add_external_project(
  ${G2LOG_TARGET}
  PREFIX ${G2LOG_PREFIX}
  DOWNLOAD_DIR ${G2LOG_PREFIX}/download
  DOWNLOAD_COMMAND
      rm -rf g2log &&
      ${HG} clone -r 56 https://bitbucket.org/KjellKod/g2log &&
      rm -rf <SOURCE_DIR> &&
      cp -r g2log/g2log <SOURCE_DIR>
  PATCH_COMMAND patch -Np0 < ${THIRD_PARTY_SOURCE_DIR}/g2log.patch
  CMAKE_ARGS
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
      -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
      -DCMAKE_EXE_LINKER_FLAGS=${CMAKE_EXE_LINKER_FLAGS}
      -DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DCMAKE_OSX_ARCHITECTURES=${ARCHS}
      -DLIBRARY_OUTPUT_PATH=<INSTALL_DIR>/lib
  INSTALL_COMMAND
      ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/include/g2log &&
      cd <SOURCE_DIR>/src &&
      find . -name "*.h" |
      cpio -dp <INSTALL_DIR>/include/g2log)
add_include_directory(${G2LOG_PREFIX}/include)

################################################################################
# GNU GCC compiler.
if (NOT SKIP_PORTABILITY_WARNINGS)
  message(
      WARNING
      "If you indend to build GCC please replace SYSROOT with the correct value"
      " for your system. You can otherwise safely ignore this warning.")
endif ()
set(SYSROOT /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk)
add_external_project(
  ${GCC_TARGET}
  PREFIX ${GCC_PREFIX}
  DOWNLOAD_DIR ${GCC_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O gcc-4.8.2.tar.bz2 ftp://ftp.gnu.org/gnu/gcc/gcc-4.8.2/gcc-4.8.2.tar.bz2 &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/gcc-4.8.2.tar.bz2.sig
          gcc-4.8.2.tar.bz2 &&
      cd <SOURCE_DIR> &&
      ${GNUTAR} --strip-components 1 -xvf
          ${GCC_PREFIX}/download/gcc-4.8.2.tar.bz2
  CONFIGURE_COMMAND
      ./configure --prefix=${GCC_PREFIX} ${HOST} --with-gmp=${GMP_PREFIX}
          --with-mpfr=${MPFR_PREFIX} --with-mpc=${MPC_PREFIX}
          --with-sysroot=${SYSROOT} --with-build-sysroot=${SYSROOT}
          CFLAGS=-O4 CXXFLAGS=-O4
          CPPFLAGS=-O4
  BUILD_IN_SOURCE 1)
add_dependencies(${GCC_TARGET} ${GMP_TARGET})
add_dependencies(${GCC_TARGET} ${GNUTAR_TARGET})
add_dependencies(${GCC_TARGET} ${MPFR_TARGET})
add_dependencies(${GCC_TARGET} ${MPC_TARGET})

################################################################################
# gflags.
add_external_project(
  ${GFLAGS_TARGET}
  PREFIX ${GFLAGS_PREFIX}
  DOWNLOAD_COMMAND
      ${SVN} export --force http://gflags.googlecode.com/svn/trunk/ ${GFLAGS_TARGET}
  CONFIGURE_COMMAND
      <SOURCE_DIR>/configure --prefix=${GFLAGS_PREFIX} ${HOST}
          CC=${CMAKE_C_COMPILER}
          CXX=${CMAKE_CXX_COMPILER} CFLAGS=${CMAKE_C_FLAGS_WITH_ARCHS}
          CXXFLAGS=${CMAKE_CXX_FLAGS_WITH_ARCHS}
          LDFLAGS=${CMAKE_SHARED_LINKER_FLAGS}
          ${CONFIGURE_LIB_TYPE})
add_include_directory(${GFLAGS_PREFIX}/include)

################################################################################
# gmock.
add_external_project(
  ${GMOCK_TARGET}
  PREFIX ${GMOCK_PREFIX}
  DOWNLOAD_COMMAND
      ${SVN} export --force http://googlemock.googlecode.com/svn/trunk/ ${GMOCK_TARGET}
  CMAKE_ARGS
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
      -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
      -DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DCMAKE_OSX_ARCHITECTURES=${ARCHS}
  INSTALL_COMMAND
      ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/include &&
      ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/lib &&
      cd <BINARY_DIR> &&
      find . -name "*${CMAKE_SHARED_LIBRARY_SUFFIX}" | cpio -dp <INSTALL_DIR>/lib &&
      find . -name "*${CMAKE_STATIC_LIBRARY_SUFFIX}" | cpio -dp <INSTALL_DIR>/lib &&
      cd <SOURCE_DIR>/include &&
      find . -name "*.h" | cpio -dp <INSTALL_DIR>/include)
add_include_directory(${GMOCK_PREFIX}/include)

################################################################################
# GMP.
set(GMP_C_FLAGS "${CMAKE_C_FLAGS_WITH_ARCHS} -Wl,${CMAKE_SHARED_LINKER_FLAGS}")
set(GMP_CXX_FLAGS "${CMAKE_CXX_FLAGS_WITH_ARCHS} -Wl,${CMAKE_SHARED_LINKER_FLAGS}")
set(CONFIGURE_COMMAND ./configure --prefix=${GMP_PREFIX} ${HOST} --enable-cxx
        CC=${CMAKE_C_COMPILER}
        CXX=${CMAKE_CXX_COMPILER} CFLAGS=${GMP_C_FLAGS}
        CXXFLAGS=${GMP_CXX_FLAGS}
        ${CONFIGURE_LIB_TYPE})
if (IOS_BUILD OR IOS_SIMULATOR_BUILD)
  set(CONFIGURE_COMMAND ${CONFIGURE_COMMAND} --disable-assembly)
endif ()
add_external_project(
  ${GMP_TARGET}
  PREFIX ${GMP_PREFIX}
  DOWNLOAD_DIR ${GMP_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O gmp-5.1.3.tar.bz2 https://gmplib.org/download/gmp/gmp-5.1.3.tar.bz2 &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/gmp-5.1.3.tar.bz2.sig
          gmp-5.1.3.tar.bz2 &&
      cd <SOURCE_DIR> &&
      ${GNUTAR} --strip-components 1 -xvf
          ${GMP_PREFIX}/download/gmp-5.1.3.tar.bz2
  CONFIGURE_COMMAND ${CONFIGURE_COMMAND}
  BUILD_IN_SOURCE 1)
add_include_directory(${GMP_PREFIX}/include)
add_dependencies(${GMP_TARGET} ${GNUTAR_TARGET})

################################################################################
# GNU bash.
add_external_project(
  ${GNUBASH_TARGET}
  PREFIX ${GNUBASH_PREFIX}
  DOWNLOAD_DIR ${GNUBASH_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O bash-4.2.tar.gz http://ftp.gnu.org/pub/gnu/bash/bash-4.2.tar.gz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/bash-4.2.tar.gz.sig
          bash-4.2.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${GNUBASH_PREFIX}/download/bash-4.2.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure
      --with-libiconv-prefix=${LIBICONV_PREFIX}
  BUILD_COMMAND make
  INSTALL_COMMAND
      echo "This will install bash in /usr/local." &&
      sudo make install)
add_dependencies(${GNUBASH_TARGET} ${LIBICONV_TARGET})

################################################################################
# GNU grep.
set(GNUGREP_LD_FLAGS "-L${PCRE_PREFIX}/lib -lpcre")
add_external_project(
  ${GNUGREP_TARGET}
  PREFIX ${GNUGREP_PREFIX}
  DOWNLOAD_DIR ${GNUGREP_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O grep-2.15.tar.xz http://ftp.gnu.org/pub/gnu/grep/grep-2.15.tar.xz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/grep-2.15.tar.xz.sig
          grep-2.15.tar.xz &&
      cd <SOURCE_DIR> &&
      ${GNUTAR} --strip-components 1 -xvJf
          ${GNUGREP_PREFIX}/download/grep-2.15.tar.xz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${GNUGREP_PREFIX} ${HOST}
      --with-libiconv-prefix=${LIBICONV_PREFIX}
      LDFLAGS=${GNUGREP_LD_FLAGS})
add_dependencies(${GNUGREP_TARGET} ${GNUTAR_TARGET})
add_dependencies(${GNUGREP_TARGET} ${LIBICONV_TARGET})
add_dependencies(${GNUGREP_TARGET} ${PCRE_TARGET})

################################################################################
# GNU tar.
add_external_project(
  ${GNUTAR_TARGET}
  PREFIX ${GNUTAR_PREFIX}
  DOWNLOAD_DIR ${GNUTAR_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O tar-1.27.1.tar.bz2 http://ftp.gnu.org/pub/gnu/tar/tar-1.27.1.tar.bz2 &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/tar-1.27.1.tar.bz2.sig
          tar-1.27.1.tar.bz2 &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${GNUTAR_PREFIX}/download/tar-1.27.1.tar.bz2
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${GNUTAR_PREFIX} ${HOST}
      --with-xz=${XZ})
add_dependencies(${GNUTAR_TARGET} ${XZ_TARGET})

################################################################################
# gtest.
add_external_project(
  ${GTEST_TARGET}
  PREFIX ${GTEST_PREFIX}
  DOWNLOAD_COMMAND
      ${SVN} export --force http://googletest.googlecode.com/svn/trunk/ ${GTEST_TARGET}
  CMAKE_ARGS
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
      -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
      -DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DCMAKE_OSX_ARCHITECTURES=${ARCHS}
  INSTALL_COMMAND
    ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/include &&
    ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/lib &&
    cd <BINARY_DIR> &&
    find . -name "*${CMAKE_SHARED_LIBRARY_SUFFIX}" | cpio -dp <INSTALL_DIR>/lib &&
    find . -name "*${CMAKE_STATIC_LIBRARY_SUFFIX}" | cpio -dp <INSTALL_DIR>/lib &&
    cd <SOURCE_DIR>/include &&
    find . -name "*.h" | cpio -dp <INSTALL_DIR>/include)
add_include_directory(${GTEST_PREFIX}/include)

################################################################################
# HAProxy. TODO(qfiard): Make portable.
add_external_project(
  ${HAPROXY_TARGET}
  PREFIX ${HAPROXY_PREFIX}
  DOWNLOAD_DIR ${HAPROXY_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O haproxy-1.4.24.tar.gz http://haproxy.1wt.eu/download/1.4/src/haproxy-1.4.24.tar.gz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/haproxy-1.4.24.tar.gz.sig
          haproxy-1.4.24.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${HAPROXY_PREFIX}/download/haproxy-1.4.24.tar.gz
  CONFIGURE_COMMAND ""
  BUILD_COMMAND make TARGET=osx CPU_CFLAGS=${CMAKE_C_FLAGS}
      USE_PCRE=1 USE_OPENSSL=1 USE_LIBCRYPT=
  INSTALL_COMMAND
      echo "This will install haproxy in /usr/local/haproxy." &&
      sudo make install DESTDIR=${HAPROXY_PREFIX} &&
      sudo ${CMAKE_COMMAND} -E make_directory /usr/local/haproxy &&
      sudo mv ${HAPROXY_PREFIX}/usr/local/doc /usr/local/haproxy &&
      sudo mv ${HAPROXY_PREFIX}/usr/local/sbin /usr/local/haproxy &&
      sudo mv ${HAPROXY_PREFIX}/usr/local/share /usr/local/haproxy &&
      sudo rm -rf ${HAPROXY_PREFIX}/usr &&
      sudo ${CMAKE_COMMAND} -E make_directory /usr/local/haproxy/logs
  BUILD_IN_SOURCE 1)

################################################################################
# ICU. TODO(qfiard): Make portable.
add_external_project(
  ${ICU_TARGET}
  PREFIX ${ICU_PREFIX}
  DOWNLOAD_DIR ${ICU_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O icu4c-52_1-src.tgz http://download.icu-project.org/files/icu4c/52.1/icu4c-52_1-src.tgz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/icu4c-52_1-src.tgz.sig
          icu4c-52_1-src.tgz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${ICU_PREFIX}/download/icu4c-52_1-src.tgz
  CONFIGURE_COMMAND <SOURCE_DIR>/source/runConfigureICU MacOSX --prefix=${ICU_PREFIX}
  BUILD_COMMAND make CXXFLAGS="--std=c++11"
  INSTALL_COMMAND make install)
add_external_project_step(${ICU_TARGET} set_install_names
  COMMAND
      ${SET_INSTALL_NAMES} ${CMAKE_INSTALL_NAME_TOOL}
          ${CMAKE_SHARED_LIBRARY_SUFFIX}
  DEPENDEES install
  DEPENDS ${SET_INSTALL_NAMES}
  WORKING_DIRECTORY ${ICU_PREFIX}/lib)

################################################################################
# IMAP-2007f. TODO(qfiard): Make portable.
add_external_project(
  ${IMAP_2007F_TARGET}
  PREFIX ${IMAP_2007F_PREFIX}
  DOWNLOAD_DIR ${IMAP_2007F_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O imap-2007f.tar.gz ftp://ftp.cac.washington.edu/imap/imap-2007f.tar.gz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/imap-2007f.tar.gz.sig
          imap-2007f.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${IMAP_2007F_PREFIX}/download/imap-2007f.tar.gz
  CONFIGURE_COMMAND ""
  BUILD_COMMAND make osx SSLTYPE=unix.nopwd EXTRACFLAGS=-fPIC
  INSTALL_COMMAND
      cd <SOURCE_DIR> &&
      ${CMAKE_COMMAND} -E make_directory ${IMAP_2007F_PREFIX}/lib &&
      ${CMAKE_COMMAND} -E make_directory ${IMAP_2007F_PREFIX}/include &&
      cp c-client/c-client.a ${IMAP_2007F_PREFIX}/lib &&
      cd c-client &&
      find . -name "*.h" | cpio -dp ${IMAP_2007F_PREFIX}/include/
  BUILD_IN_SOURCE 1)

################################################################################
# iwyu.
set(IWYU_LINKER_FLAGS "-L${CLANG_PREFIX}/lib")
add_external_project(
  ${IWYU_TARGET}
  PREFIX ${IWYU_PREFIX}
  DOWNLOAD_COMMAND
      ${SVN} export --force http://include-what-you-use.googlecode.com/svn/trunk ${IWYU_TARGET}
  CMAKE_ARGS
      -DLLVM_PATH=${CLANG_PREFIX}
      -DCMAKE_EXE_LINKER_FLAGS=${IWYU_LINKER_FLAGS}
      -DCMAKE_INSTALL_PREFIX=${IWYU_PREFIX})
add_dependencies(${IWYU_TARGET} ${CLANG_TARGET})

################################################################################
# jsoncpp.
add_external_project(
  ${JSONCPP_TARGET}
  PREFIX ${JSONCPP_PREFIX}
  DOWNLOAD_COMMAND
      ${SVN} export --force
          http://jsoncpp.svn.sourceforge.net/svnroot/jsoncpp/trunk/jsoncpp
          ${JSONCPP_TARGET}
  CMAKE_ARGS
      -DJSONCPP_WITH_TESTS=OFF

      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
      -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
      -DCMAKE_EXE_LINKER_FLAGS=${CMAKE_EXE_LINKER_FLAGS}
      -DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DCMAKE_OSX_ARCHITECTURES=${ARCHS}
      -DCMAKE_INSTALL_PREFIX=${JSONCPP_PREFIX})
add_include_directory(${JSONCPP_PREFIX}/include)

################################################################################
# LDAP.
set(LDAP_CPPFLAGS "-I${BERKELEY_DB_PREFIX}/include")
set(LDAP_LDFLAGS "-L${BERKELEY_DB_PREFIX}/lib")
add_external_project(
  ${LDAP_TARGET}
  PREFIX ${LDAP_PREFIX}
  DOWNLOAD_DIR ${LDAP_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O openldap-2.4.38.tgz ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-2.4.38.tgz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/openldap-2.4.38.tgz.sig
          openldap-2.4.38.tgz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${LDAP_PREFIX}/download/openldap-2.4.38.tgz
  CONFIGURE_COMMAND LDFLAGS=${LDAP_LDFLAGS} CPPFLAGS=${LDAP_CPPFLAGS}
      <SOURCE_DIR>/configure --prefix=${LDAP_PREFIX} ${HOST}
  BUILD_COMMAND make
  INSTALL_COMMAND make install)
add_dependencies(${LDAP_TARGET} ${BERKELEY_DB_TARGET})

################################################################################
# LDAP SASL. TODO(qfiard): Make portable.
add_external_project(
  ${LDAP_SASL_TARGET}
  PREFIX ${LDAP_SASL_PREFIX}
  DOWNLOAD_DIR ${LDAP_SASL_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O cyrus-sasl-2.1.25.tar.gz http://ftp.andrew.cmu.edu/pub/cyrus-mail/cyrus-sasl-2.1.25.tar.gz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/cyrus-sasl-2.1.25.tar.gz.sig
          cyrus-sasl-2.1.25.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${LDAP_SASL_PREFIX}/download/cyrus-sasl-2.1.25.tar.gz
  PATCH_COMMAND
      patch -Np0 < ${THIRD_PARTY_SOURCE_DIR}/ldap_sasl.patch
  CONFIGURE_COMMAND
      LDFLAGS=${LDAP_LDFLAGS} CPPFLAGS=${LDAP_CPPFLAGS}
      <SOURCE_DIR>/configure --prefix=${LDAP_SASL_PREFIX} ${HOST}
      --with-dblib=berkeley
      --with-bdb-incdir=${BERKELEY_DB_PREFIX}/include
      --with-bdb-libdir=${BERKELEY_DB_PREFIX}/lib
      --with-openssl=${OPENSSL_PREFIX}
      --with-ldap=${LDAP_PREFIX}
      --disable-macos-framework
  BUILD_COMMAND make
  INSTALL_COMMAND make install)
add_dependencies(${LDAP_SASL_TARGET} ${BERKELEY_DB_TARGET})
add_dependencies(${LDAP_SASL_TARGET} ${LDAP_TARGET})
add_dependencies(${LDAP_SASL_TARGET} ${OPENSSL_TARGET})

################################################################################
# libcurl. TODO(qfiard): Make portable.
set(LIBCURL_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -L${ZLIB_PREFIX}/lib")
add_external_project(
  ${LIBCURL_TARGET}
  PREFIX ${LIBCURL_PREFIX}
  DOWNLOAD_DIR ${LIBCURL_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O curl-7.33.0.tar.bz2 http://curl.haxx.se/download/curl-7.33.0.tar.bz2 &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/curl-7.33.0.tar.bz2.asc
          curl-7.33.0.tar.bz2 &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${LIBCURL_PREFIX}/download/curl-7.33.0.tar.bz2
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${LIBCURL_PREFIX} ${HOST}
      --with-zlib=${ZLIB_PREFIX} --with-ssl=${OPENSSL_PREFIX}
      CC=${CMAKE_C_COMPILER}
      CXX=${CMAKE_CXX_COMPILER} CFLAGS=${CMAKE_C_FLAGS_WITH_ARCHS}
      CXXFLAGS=${CMAKE_CXX_FLAGS_WITH_ARCHS}
      LDFLAGS=${LIBCURL_LINKER_FLAGS}
      ${CONFIGURE_LIB_TYPE})
add_include_directory(${LIBCURL_PREFIX}/include)
add_dependencies(${LIBCURL_TARGET} ${OPENSSL_TARGET})
add_dependencies(${LIBCURL_TARGET} ${ZLIB_TARGET})

################################################################################
# libcxx_download.
add_external_project(
  ${LIBCXX_HEADERS_TARGET}
  PREFIX ${LIBCXX_PREFIX}
  DOWNLOAD_COMMAND
      ${SVN} export --force http://llvm.org/svn/llvm-project/libcxx/trunk ${LIBCXX_TARGET}
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND "")

################################################################################
# libcxx.
set(LIBCXX_LINKER_FLAGS "-L${LIBCXXABI_PREFIX}/lib ${CMAKE_SHARED_LINKER_FLAGS}")
add_external_project(
  ${LIBCXX_TARGET}
  PREFIX ${LIBCXX_PREFIX}
  DOWNLOAD_COMMAND " "
  CMAKE_ARGS
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
      -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
      -DCMAKE_SHARED_LINKER_FLAGS=${LIBCXX_LINKER_FLAGS}
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DCMAKE_OSX_ARCHITECTURES=${ARCHS}
      -DCMAKE_INSTALL_PREFIX=${LIBCXX_PREFIX}
      -DLIBCXX_CXX_ABI=libcxxabi
      -DLIBCXX_LIBCXXABI_INCLUDE_PATHS=${LIBCXXABI_PREFIX}/include)
add_external_project_step(${LIBCXX_TARGET} set_install_names
  COMMAND
      ${SET_INSTALL_NAMES} ${CMAKE_INSTALL_NAME_TOOL}
          ${CMAKE_SHARED_LIBRARY_SUFFIX}
  DEPENDEES install
  DEPENDS ${SET_INSTALL_NAMES}
  WORKING_DIRECTORY ${LIBCXX_PREFIX}/lib)
add_dependencies(${LIBCXX_TARGET} ${LIBCXX_HEADERS_TARGET})
add_dependencies(${LIBCXX_TARGET} ${LIBCXXABI_TARGET})

################################################################################
# libcxxabi.
add_external_project(
  ${LIBCXXABI_TARGET}
  PREFIX ${LIBCXXABI_PREFIX}
  DOWNLOAD_COMMAND
      ${SVN} export --force http://llvm.org/svn/llvm-project/libcxxabi/trunk <INSTALL_DIR>
  PATCH_COMMAND
    cd <INSTALL_DIR>/lib && patch -p0 < ${THIRD_PARTY_SOURCE_DIR}/libcxxabi.patch
  CONFIGURE_COMMAND ""
  BUILD_COMMAND
    cd <INSTALL_DIR>/lib &&
    CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} ./buildit &&
    ln -s libc++abi.1.0.dylib libc++abi.dylib
  INSTALL_COMMAND "")
add_external_project_step(${LIBCXXABI_TARGET} set_install_names
  COMMAND
      ${SET_INSTALL_NAMES} ${CMAKE_INSTALL_NAME_TOOL}
          ${CMAKE_SHARED_LIBRARY_SUFFIX}
  DEPENDEES install
  DEPENDS ${SET_INSTALL_NAMES}
  WORKING_DIRECTORY ${LIBCXXABI_PREFIX}/lib)
add_dependencies(${LIBCXXABI_TARGET} ${LIBCXX_TARGET}_headers)

################################################################################
# libicon.
add_external_project(
  ${LIBICONV_TARGET}
  PREFIX ${LIBICONV_PREFIX}
  DOWNLOAD_DIR ${LIBICONV_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O libiconv-1.14.tar.gz http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/libiconv-1.14.tar.gz.sig
          libiconv-1.14.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${LIBICONV_PREFIX}/download/libiconv-1.14.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${LIBICONV_PREFIX} ${HOST})

################################################################################
# LibJPG.
add_external_project(
  ${LIBJPG_TARGET}
  PREFIX ${LIBJPG_PREFIX}
  DOWNLOAD_DIR ${LIBJPG_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O jpegsrc.v9.tar.gz http://www.ijg.org/files/jpegsrc.v9.tar.gz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/jpegsrc.v9.tar.gz.sig
          jpegsrc.v9.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${LIBJPG_PREFIX}/download/jpegsrc.v9.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${LIBJPG_PREFIX} ${HOST})

################################################################################
# libmcrypt.
add_external_project(
  ${LIBMCRYPT_TARGET}
  PREFIX ${LIBMCRYPT_PREFIX}
  DOWNLOAD_DIR ${LIBMCRYPT_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O libmcrypt-2.5.8.tar.bz2 http://downloads.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.bz2?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fmcrypt%2Ffiles%2FLibmcrypt%2F2.5.8%2F&ts=1386067766&use_mirror=kent &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/libmcrypt-2.5.8.tar.bz2.sig
          libmcrypt-2.5.8.tar.bz2 &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${LIBMCRYPT_PREFIX}/download/libmcrypt-2.5.8.tar.bz2
  CONFIGURE_COMMAND
      rm libltdl/configure &&
      cd libltdl &&
      autoconf &&
      cd <SOURCE_DIR> &&
      <SOURCE_DIR>/configure --prefix=${LIBMCRYPT_PREFIX} ${HOST}
          --disable-posix-threads --enable-dynamic-loading
  BUILD_IN_SOURCE 1)

################################################################################
# libmhash.
add_external_project(
  ${LIBMHASH_TARGET}
  PREFIX ${LIBMHASH_PREFIX}
  DOWNLOAD_DIR ${LIBMHASH_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O mhash-0.9.9.9.tar.bz2 http://downloads.sourceforge.net/project/mhash/mhash/0.9.9.9/mhash-0.9.9.9.tar.bz2?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fmhash%2Ffiles%2Fmhash%2F0.9.9.9%2F&ts=1386068273&use_mirror=kent &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/mhash-0.9.9.9.tar.bz2.sig
          mhash-0.9.9.9.tar.bz2 &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${LIBMHASH_PREFIX}/download/mhash-0.9.9.9.tar.bz2
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${LIBMHASH_PREFIX} ${HOST}
  BUILD_IN_SOURCE 1)

################################################################################
# LibPNG.
add_external_project(
  ${LIBPNG_TARGET}
  PREFIX ${LIBPNG_PREFIX}
  DOWNLOAD_DIR ${LIBPNG_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O libpng-1.6.7.tar.gz http://downloads.sourceforge.net/project/libpng/libpng16/1.6.7/libpng-1.6.7.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Flibpng%2Ffiles%2Flibpng16%2F1.6.7%2F&ts=1385863731&use_mirror=kent &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/libpng-1.6.7.tar.gz.sig
          libpng-1.6.7.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${LIBPNG_PREFIX}/download/libpng-1.6.7.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${LIBPNG_PREFIX} ${HOST})

################################################################################
# libxml.
if (IOS_BUILD OR IOS_SIMULATOR_BUILD)
  set(WITH_PYTHON "--with-python=no")
endif ()
add_external_project(
  ${LIBXML_TARGET}
  PREFIX ${LIBXML_PREFIX}
  DOWNLOAD_COMMAND
      ${GIT} clone --depth 1 git://git.gnome.org/libxml2 ${LIBXML_TARGET}
  CONFIGURE_COMMAND
      <SOURCE_DIR>/autogen.sh --prefix=${LIBXML_PREFIX} ${HOST}
          --with-lzma=${XZ_PREFIX}
          --with-zlib=${ZLIB_PREFIX}
          CC=${CMAKE_C_COMPILER}
          CXX=${CMAKE_CXX_COMPILER} CFLAGS=${CMAKE_C_FLAGS_WITH_ARCHS}
          CXXFLAGS=${CMAKE_CXX_FLAGS_WITH_ARCHS}
          LDFLAGS=${CMAKE_SHARED_LINKER_FLAGS}
          ${WITH_PYTHON}
          ${CONFIGURE_LIB_TYPE})
add_include_directory(${LIBXML_PREFIX}/include)
add_include_directory(${LIBXML_PREFIX}/include/libxml2)
add_dependencies(${LIBXML_TARGET} ${XZ_TARGET})
add_dependencies(${LIBXML_TARGET} ${ZLIB_TARGET})

################################################################################
# MarisaTrie.
add_external_project(
  ${MARISA_TRIE_TARGET}
  PREFIX ${MARISA_TRIE_PREFIX}
  DOWNLOAD_DIR ${MARISA_TRIE_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O marisa-0.2.4.tar.gz https://marisa-trie.googlecode.com/files/marisa-0.2.4.tar.gz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/marisa-0.2.4.tar.gz.sig
          marisa-0.2.4.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${MARISA_TRIE_PREFIX}/download/marisa-0.2.4.tar.gz
  CONFIGURE_COMMAND
      <SOURCE_DIR>/configure --prefix=${MARISA_TRIE_PREFIX} ${HOST}
          CC=${CMAKE_C_COMPILER}
          CXX=${CMAKE_CXX_COMPILER} CFLAGS=${CMAKE_C_FLAGS_WITH_ARCHS}
          CXXFLAGS=${CMAKE_CXX_FLAGS_WITH_ARCHS}
          LDFLAGS=${CMAKE_SHARED_LINKER_FLAGS}
          ${CONFIGURE_LIB_TYPE})
add_include_directory(${MARISA_TRIE_PREFIX}/include)

################################################################################
# Maven.
add_external_project(
  ${MAVEN_TARGET}
  PREFIX ${MAVEN_PREFIX}
  DOWNLOAD_DIR ${MAVEN_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O apache-maven-3.1.1-src.tar.gz ftp://mirrors.ircam.fr/pub/apache/maven/maven-3/3.1.1/source/apache-maven-3.1.1-src.tar.gz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/apache-maven-3.1.1-src.tar.gz.asc
          apache-maven-3.1.1-src.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${MAVEN_PREFIX}/download/apache-maven-3.1.1-src.tar.gz
  CONFIGURE_COMMAND echo ""
  BUILD_COMMAND
      M2_HOME=${MAVEN_PREFIX}/build ${ANT}
  INSTALL_COMMAND
      cd <INSTALL_DIR>/build &&
      find . | cpio -dp <INSTALL_DIR> &&
      cd <INSTALL_DIR> &&
      rm -rf <INSTALL_DIR>/build
  BUILD_IN_SOURCE 1)

################################################################################
# Maven libraries.
set(MAVEN_LAST_DOWNLOAD "${THIRD_PARTY_BINARY_DIR}/java/last_download")
set(MAVEN_CLASSPATH_UPDATE "${THIRD_PARTY_BINARY_DIR}/java/classpath_update")
add_custom_command(
  OUTPUT ${MAVEN_LAST_DOWNLOAD}
  COMMAND ${MVN} -f ${THIRD_PARTY_SOURCE_DIR}/pom.xml
      -q dependency:copy-dependencies
  COMMAND date > ${MAVEN_LAST_DOWNLOAD}
  MAIN_DEPENDENCY ${THIRD_PARTY_SOURCE_DIR}/pom.xml)
set(GENERATE_CLASSPATH_FOR_MAVEN_LIBS
    ${SUPPORT_DIR}/generate_classpath_for_maven_libs.py)
add_custom_command(
  OUTPUT ${MAVEN_CLASSPATH_UPDATE}
  COMMAND ${GENERATE_CLASSPATH_FOR_MAVEN_LIBS} "${MVN}"
      "${THIRD_PARTY_SOURCE_DIR}/pom.xml" "${THIRD_PARTY_BINARY_DIR}/java"
  COMMAND date > ${MAVEN_CLASSPATH_UPDATE}
  MAIN_DEPENDENCY ${MAVEN_LAST_DOWNLOAD}
  DEPENDS ${GENERATE_CLASSPATH_FOR_MAVEN_LIBS})
add_custom_target(${MAVEN_LIBS_TARGET}
                  SOURCES ${MAVEN_LAST_DOWNLOAD} ${MAVEN_CLASSPATH_UPDATE})
add_dependencies(${MAVEN_LIBS_TARGET} ${MAVEN_TARGET})

################################################################################
# Mcrypt.
set(MCRYPT_CPPFLAGS "-I${LIBMHASH_PREFIX}/include -I/usr/include/sys\
    -DSTDOUT_FILENO=1 -DSTDIN_FILENO=0")
set(MCRYPT_LDFLAGS "-L${LIBMHASH_PREFIX}/lib")
add_external_project(
  ${MCRYPT_TARGET}
  PREFIX ${MCRYPT_PREFIX}
  DOWNLOAD_DIR ${MCRYPT_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O mcrypt-2.6.8.tar.gz http://downloads.sourceforge.net/project/mcrypt/MCrypt/2.6.8/mcrypt-2.6.8.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fmcrypt%2Ffiles%2FMCrypt%2F2.6.8%2F&ts=1386067598&use_mirror=kent &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/mcrypt-2.6.8.tar.gz.sig
          mcrypt-2.6.8.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${MCRYPT_PREFIX}/download/mcrypt-2.6.8.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${MCRYPT_PREFIX} ${HOST}
      --with-libiconv-prefix=${LIBICONV_PREFIX}
      --with-libmcrypt-prefix=${LIBMCRYPT_PREFIX}
      --with-libmhash-prefix=${LIBMHASH_PREFIX}
      CPPFLAGS=${MCRYPT_CPPFLAGS}
      LDFLAGS=${MCRYPT_LDFLAGS}
  BUILD_IN_SOURCE 1)
add_dependencies(${MCRYPT_TARGET} ${LIBICONV_TARGET})
add_dependencies(${MCRYPT_TARGET} ${LIBMCRYPT_TARGET})
add_dependencies(${MCRYPT_TARGET} ${LIBMHASH_TARGET})

################################################################################
# Mili.
add_external_project(
  ${MILI_TARGET}
  PREFIX ${MILI_PREFIX}
  DOWNLOAD_COMMAND
      ${HG} clone https://code.google.com/p/mili ${MILI_TARGET}
  CONFIGURE_COMMAND echo ""
  BUILD_COMMAND echo ""
  INSTALL_COMMAND find mili | cpio -dp <INSTALL_DIR>/include
  BUILD_IN_SOURCE 1)
add_include_directory(${MILI_PREFIX}/include)

################################################################################
# MPC.
add_external_project(
  ${MPC_TARGET}
  PREFIX ${MPC_PREFIX}
  DOWNLOAD_DIR ${MPC_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O mpc-1.0.1.tar.gz http://www.multiprecision.org/mpc/download/mpc-1.0.1.tar.gz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/mpc-1.0.1.tar.gz.sig
          mpc-1.0.1.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${MPC_PREFIX}/download/mpc-1.0.1.tar.gz
  CONFIGURE_COMMAND
      <SOURCE_DIR>/configure --prefix=${MPC_PREFIX} ${HOST}
          --with-gmp=${GMP_PREFIX}
          --with-mpfr=${MPFR_PREFIX}
          CC=${CMAKE_C_COMPILER}
          CXX=${CMAKE_CXX_COMPILER} CFLAGS=${CMAKE_C_FLAGS_WITH_ARCHS}
          CXXFLAGS=${CMAKE_CXX_FLAGS_WITH_ARCHS}
          LDFLAGS=${CMAKE_SHARED_LINKER_FLAGS}
          ${CONFIGURE_LIB_TYPE})
add_include_directory(${MPC_PREFIX}/include)
add_dependencies(${MPC_TARGET} ${GMP_TARGET})
add_dependencies(${MPC_TARGET} ${MPFR_TARGET})

################################################################################
# MPFR.
add_external_project(
  ${MPFR_TARGET}
  PREFIX ${MPFR_PREFIX}
  DOWNLOAD_DIR ${MPFR_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O mpfr-3.1.2.tar.bz2 http://www.mpfr.org/mpfr-current/mpfr-3.1.2.tar.bz2 &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/mpfr-3.1.2.tar.bz2.asc
          mpfr-3.1.2.tar.bz2 &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${MPFR_PREFIX}/download/mpfr-3.1.2.tar.bz2
  CONFIGURE_COMMAND
      <SOURCE_DIR>/configure --prefix=${MPFR_PREFIX} ${HOST}
          --with-gmp=${GMP_PREFIX}
          CC=${CMAKE_C_COMPILER}
          CXX=${CMAKE_CXX_COMPILER} CFLAGS=${CMAKE_C_FLAGS_WITH_ARCHS}
          CXXFLAGS=${CMAKE_CXX_FLAGS_WITH_ARCHS}
          LDFLAGS=${CMAKE_SHARED_LINKER_FLAGS}
          ${CONFIGURE_LIB_TYPE})
add_include_directory(${MPFR_PREFIX}/include)
add_dependencies(${MPFR_TARGET} ${GMP_TARGET})

################################################################################
# MySQL.
add_external_project(
  ${MYSQL_TARGET}
  PREFIX ${MYSQL_PREFIX}
  DOWNLOAD_DIR ${MYSQL_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O mysql-5.6.15.tar.gz http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.15.tar.gz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/mysql-5.6.15.tar.gz.sig
          mysql-5.6.15.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${MYSQL_PREFIX}/download/mysql-5.6.15.tar.gz
  PATCH_COMMAND
      patch -p0 < ${THIRD_PARTY_SOURCE_DIR}/mysql.patch
  CMAKE_ARGS
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
      -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
      -DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}
      # Do not use, leads to undefined symbols errors.
      # -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DCMAKE_OSX_ARCHITECTURES=${ARCHS}
      -DCMAKE_INSTALL_PREFIX=${MYSQL_PREFIX}
      -DWITH_ZLIB=test
      -DZLIB_ROOT=${ZLIB_PREFIX}
      -DWITH_SSL_PATH=${OPENSSL_PREFIX})
add_include_directory(${MYSQL_PREFIX}/include)
add_dependencies(${MYSQL_TARGET} ${OPENSSL_TARGET})
add_dependencies(${MYSQL_TARGET} ${ZLIB_TARGET})

################################################################################
# Mysql C++/Connector.
if (IOS_BUILD OR IOS_SIMULATOR_BUILD)
  add_custom_target(${MYSQLCPPCONN_TARGET})
  set_library(mysqlcppconn "")
else ()
  add_external_project(
    ${MYSQLCPPCONN_TARGET}
    PREFIX ${MYSQLCPPCONN_PREFIX}
    DOWNLOAD_DIR ${MYSQLCPPCONN_PREFIX}/download
    DOWNLOAD_COMMAND
        wget -O mysqlcppconn.tar.gz http://dev.mysql.com/get/Downloads/Connector-C++/mysql-connector-c++-1.1.3.tar.gz/from/http://cdn.mysql.com/ &&
        cd <SOURCE_DIR> &&
        tar --strip-components 1 -xvf ${MYSQLCPPCONN_PREFIX}/download/mysqlcppconn.tar.gz
    CMAKE_ARGS
        -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
        -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
        -DCMAKE_BUILD_TYPE=RELEASE
        -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
        -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
        -DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DCMAKE_OSX_ARCHITECTURES=${ARCHS}
        -DCMAKE_INSTALL_PREFIX=${MYSQLCPPCONN_PREFIX}
    BUILD_IN_SOURCE 1  # Needed for config header file.
    )
  add_external_project_step(${MYSQLCPPCONN_TARGET} set_install_names
    COMMAND
        ${SET_INSTALL_NAMES} ${CMAKE_INSTALL_NAME_TOOL}
            ${CMAKE_SHARED_LIBRARY_SUFFIX}
    DEPENDEES install
    DEPENDS ${SET_INSTALL_NAMES}
    WORKING_DIRECTORY ${MYSQLCPPCONN_PREFIX}/lib)
  add_include_directory(${MYSQLCPPCONN_PREFIX}/include)
endif ()

################################################################################
# Nginx.
set(NGINX_C_FLAGS "-D FD_SETSIZE=2048 ${CMAKE_C_FLAGS}")
add_external_project(
  ${NGINX_TARGET}
  PREFIX ${NGINX_PREFIX}
  DOWNLOAD_DIR ${NGINX_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O nginx-1.4.3.tar.gz http://nginx.org/download/nginx-1.4.3.tar.gz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/nginx-1.4.3.tar.gz.sig
          nginx-1.4.3.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${NGINX_PREFIX}/download/nginx-1.4.3.tar.gz
  CONFIGURE_COMMAND
      ./configure --with-http_ssl_module
          --with-cc-opt=${NGINX_C_FLAGS}
  BUILD_COMMAND make -j
  INSTALL_COMMAND
      echo "This will install nginx in /usr/local/nginx." &&
      sudo make install &&
      sudo ${CMAKE_COMMAND} -E make_directory /usr/local/nginx/logs
  BUILD_IN_SOURCE 1)

################################################################################
# NTP.
add_external_project(
  ${NTP_TARGET}
  PREFIX ${NTP_PREFIX}
  DOWNLOAD_DIR ${NTP_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O ntp-4.2.6p5.tar.gz http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-4.2.6p5.tar.gz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/ntp-4.2.6p5.tar.gz.sig
          ntp-4.2.6p5.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${NTP_PREFIX}/download/ntp-4.2.6p5.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=/usr/local/ntp
  BUILD_COMMAND make
  INSTALL_COMMAND
      echo "This will install NTP in /usr/local/ntp on you server." &&
      sudo make install &&
      sudo ${CMAKE_COMMAND} -E make_directory /usr/local/ntp/logs)

################################################################################
# OpenCV.
set(OPENCV_SHARED_LINKER_FLAGS
    "-L${OPENCV_PREFIX}/src/${OPENCV_TARGET}-build/lib\
     ${CMAKE_SHARED_LINKER_FLAGS}")
set(OPENCV_EXE_LINKER_FLAGS
    "-L${OPENCV_PREFIX}/src/${OPENCV_TARGET}-build/lib\
     ${CMAKE_EXE_LINKER_FLAGS}")
set(OPENCV_CXX_FLAGS
    "-D TBB_IMPLEMENT_CPP0X=0 -I${TBB_PREFIX}/include ${CMAKE_CXX_FLAGS}")
add_external_project(
  ${OPENCV_TARGET}
  PREFIX ${OPENCV_PREFIX}
  DOWNLOAD_DIR ${OPENCV_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O opencv_2.4.7.2.tar.gz https://github.com/Itseez/opencv/archive/2.4.7.2.tar.gz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/opencv_2.4.7.2.tar.gz.sig
          opencv_2.4.7.2.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${OPENCV_PREFIX}/download/opencv_2.4.7.2.tar.gz
  CMAKE_ARGS
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DENABLE_OMIT_FRAME_POINTER=ON
      -DENABLE_FAST_MATH=ON
      -DENABLE_SSE=ON
      -DENABLE_SSE2=ON
      -DENABLE_SSE3=ON
      -DENABLE_SSSE3=ON
      -DENABLE_SSE41=ON
      -DENABLE_SSE42=ON
      -DENABLE_AVX=OFF
      -DENABLE_NEON=ON
      -DWITH_CUDA=OFF
      -DWITH_EIGEN=ON
      -DEIGEN_ROOT=${EIGEN_PREFIX}
      -DWITH_TBB=ON
      -DCMAKE_PREFIX_PATH=${TBB_PREFIX}
      -DTBB_INCLUDE_DIRS=${TBB_PREFIX}/include
      -DEIGEN_INCLUDE_PATH=${EIGEN_INCLUDE_PATH}
      -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
      -DCMAKE_CXX_FLAGS=${OPENCV_CXX_FLAGS}
      -DCMAKE_SHARED_LINKER_FLAGS=${OPENCV_SHARED_LINKER_FLAGS}
      -DCMAKE_EXE_LINKER_FLAGS=${OPENCV_EXE_LINKER_FLAGS}
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DCMAKE_OSX_ARCHITECTURES=${ARCHS}
      -DCMAKE_INSTALL_PREFIX=${OPENCV_PREFIX})
add_external_project_step(${OPENCV_TARGET} set_install_names
  COMMAND
      ${SET_INSTALL_NAMES} ${CMAKE_INSTALL_NAME_TOOL}
          ${CMAKE_SHARED_LIBRARY_SUFFIX}
  DEPENDEES install
  DEPENDS ${SET_INSTALL_NAMES}
  WORKING_DIRECTORY ${OPENCV_PREFIX}/lib)
add_include_directory(${OPENCV_PREFIX}/include)
add_dependencies(${OPENCV_TARGET} ${EIGEN_TARGET})
# add_dependencies(${OPENCV_TARGET} ${GCC_TARGET})
add_dependencies(${OPENCV_TARGET} ${TBB_PREFIX})

################################################################################
# OpenMP.
add_external_project(
  ${OPENMP_TARGET}
  PREFIX ${OPENMP_PREFIX}
  DOWNLOAD_DIR ${OPENMP_PREFIX}/download
  DOWNLOAD_COMMAND
      ${SVN} export --force http://llvm.org/svn/llvm-project/openmp/trunk openmp &&
      rm -rf <SOURCE_DIR> &&
      mv openmp/runtime <SOURCE_DIR>
  CONFIGURE_COMMAND echo ""
  BUILD_COMMAND
      PATH=${GCC_PREFIX}/bin:$ENV{PATH}
          LIB_GCC=${GCC_PREFIX}/lib/libgcc_s.1${CMAKE_SHARED_LIBRARY_SUFFIX}
          make compiler=gcc
  INSTALL_COMMAND
      ${CMAKE_COMMAND} -E make_directory ${OPENMP_PREFIX}/lib &&
      cp -rf exports/common/include ${OPENMP_PREFIX} &&
      find exports -name "*${CMAKE_SHARED_LIBRARY_SUFFIX}" |
      xargs -I{} cp "{}" ${OPENMP_PREFIX}/lib
  PATCH_COMMAND
      patch -Np0 < ${THIRD_PARTY_SOURCE_DIR}/openmp.patch
  BUILD_IN_SOURCE 1)
add_external_project_step(${OPENMP_TARGET} set_install_names
  COMMAND
      ${SET_INSTALL_NAMES} ${CMAKE_INSTALL_NAME_TOOL}
          ${CMAKE_SHARED_LIBRARY_SUFFIX}
  DEPENDEES install
  DEPENDS ${SET_INSTALL_NAMES}
  WORKING_DIRECTORY ${OPENMP_PREFIX}/lib)
add_include_directory(${OPENMP_PREFIX}/include)
set(OPENMP_COMPILE_FLAG "-fopenmp")
add_dependencies(${OPENMP_TARGET} ${GCC_TARGET})
# add_dependencies(${OPENMP_TARGET} ${CLANG_OMP_TARGET})

################################################################################
# OpenSSL.
set(OPENSSL_FLAGS enable-gmp -DOPENSSL_USE_GMP -I${GMP_PREFIX}/include)
foreach (FLAG ${third_party.gmp})
  set(OPENSSL_FLAGS "${OPENSSL_FLAGS} -Wl,${FLAG}")
endforeach ()
if (IOS_BUILD)
  set(DEFAULT_CONFIGURE_COMMAND
          <SOURCE_DIR>/Configure iphoneos-cross
          ${CMAKE_C_FLAGS} ${LINKER_AS_COMPILER_FLAGS} ${OPENSSL_FLAGS})

  list(GET CMAKE_OSX_ARCHITECTURES 0 FIRST_ARCH)
  # No build command in target, see below for build steps by architecture.
  add_external_project(
    ${OPENSSL_TARGET}
    PREFIX ${OPENSSL_PREFIX}
    DOWNLOAD_DIR ${OPENSSL_PREFIX}/download
    DOWNLOAD_COMMAND
        wget -O openssl-1.0.1e.tar.gz http://www.openssl.org/source/openssl-1.0.1e.tar.gz &&
        gpg --verify ${THIRD_PARTY_SOURCE_DIR}/openssl-1.0.1e.tar.gz.asc
            openssl-1.0.1e.tar.gz &&
        cd <SOURCE_DIR> &&
        tar --strip-components 1 -xvf
            ${OPENSSL_PREFIX}/download/openssl-1.0.1e.tar.gz
    CONFIGURE_COMMAND echo ""
    BUILD_COMMAND echo ""
    INSTALL_COMMAND
        ln -sf ${OPENSSL_PREFIX}/${FIRST_ARCH}/include
            ${OPENSSL_PREFIX}/${FIRST_ARCH}/ssl ${OPENSSL_PREFIX})

  set(LAST_STEP configure)
  foreach(ARCH ${CMAKE_OSX_ARCHITECTURES})
    set(STEP "${ARCH}_create_dirs")
    set(SOURCE_DIR ${OPENSSL_PREFIX}/${ARCH}/src)
    add_external_project_step(${OPENSSL_TARGET} ${STEP}
      COMMAND ${CMAKE_COMMAND} -E make_directory ${OPENSSL_PREFIX}/${ARCH} &&
          cp -rf <SOURCE_DIR> ${SOURCE_DIR}
      DEPENDEES ${LAST_STEP})
    set(LAST_STEP ${STEP})
    set(CONFIGURE_COMMAND ${DEFAULT_CONFIGURE_COMMAND}
            --prefix=${OPENSSL_PREFIX}/${ARCH} "-arch ${ARCH}")
    set(STEP "${ARCH}_configure")
    add_external_project_step(${OPENSSL_TARGET} ${STEP}
      COMMAND ${CONFIGURE_COMMAND}
      DEPENDEES ${LAST_STEP}
      WORKING_DIRECTORY ${SOURCE_DIR})
    set(LAST_STEP ${STEP})
    set(STEP "${ARCH}_build")
    add_external_project_step(${OPENSSL_TARGET} ${STEP}
      COMMAND make
      DEPENDEES ${LAST_STEP}
      WORKING_DIRECTORY ${SOURCE_DIR})
    set(LAST_STEP ${STEP})
    set(STEP "${ARCH}_install")
    add_external_project_step(${OPENSSL_TARGET} ${STEP}
      COMMAND make install
      DEPENDEES ${LAST_STEP}
      DEPENDERS install
      WORKING_DIRECTORY ${SOURCE_DIR})
    set(LAST_STEP ${STEP})
  endforeach ()
  set(MERGE_COMMAND ${CREATE_FAT_LIBS} ${CMAKE_SHARED_LIBRARY_SUFFIX}
          ${CMAKE_STATIC_LIBRARY_SUFFIX} ${OPENSSL_PREFIX}/lib)
  foreach(ARCH ${CMAKE_OSX_ARCHITECTURES})
    set(MERGE_COMMAND ${MERGE_COMMAND} ${OPENSSL_PREFIX}/${ARCH}/lib)
  endforeach ()
  set(STEP "create_fat_libs")
  add_external_project_step(${OPENSSL_TARGET} ${STEP}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${OPENSSL_PREFIX}/lib &&
        ${MERGE_COMMAND}
    DEPENDEES ${LAST_STEP}
    DEPENDS ${CREATE_FAT_LIBS})
else ()
  if (IOS_SIMULATOR_BUILD)
    set(CONFIGURE_COMMAND
            <SOURCE_DIR>/Configure BSD-generic32 --prefix=${OPENSSL_PREFIX}
            ${CMAKE_C_FLAGS_WITH_ARCHS} "-Wl,${CMAKE_SHARED_LINKER_FLAGS}"
            ${OPENSSL_FLAGS})
  else ()
    set(CONFIGURE_COMMAND <SOURCE_DIR>/Configure darwin64-x86_64-cc
            ${CMAKE_C_FLAGS} --prefix=${OPENSSL_PREFIX} zlib-dynamic
            ${OPENSSL_FLAGS})
  endif ()
  if (BUILD_SHARED_LIBS)
    set(CONFIGURE_COMMAND ${CONFIGURE_COMMAND} shared)
  endif ()
  add_external_project(
    ${OPENSSL_TARGET}
    PREFIX ${OPENSSL_PREFIX}
    DOWNLOAD_DIR ${OPENSSL_PREFIX}/download
    DOWNLOAD_COMMAND
        wget -O openssl-1.0.1e.tar.gz http://www.openssl.org/source/openssl-1.0.1e.tar.gz &&
        gpg --verify ${THIRD_PARTY_SOURCE_DIR}/openssl-1.0.1e.tar.gz.asc
            openssl-1.0.1e.tar.gz &&
        cd <SOURCE_DIR> &&
        tar --strip-components 1 -xvf
            ${OPENSSL_PREFIX}/download/openssl-1.0.1e.tar.gz
    CONFIGURE_COMMAND ${CONFIGURE_COMMAND}
    BUILD_IN_SOURCE 1)
endif ()
add_include_directory(${OPENSSL_PREFIX}/include)
add_dependencies(${OPENSSL_TARGET} ${GMP_TARGET})

################################################################################
# pcre.
add_external_project(
  ${PCRE_TARGET}
  PREFIX ${PCRE_PREFIX}
  DOWNLOAD_DIR ${PCRE_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O pcre-8.33.tar.bz2 ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.33.tar.bz2 &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/pcre-8.33.tar.bz2.sig
          pcre-8.33.tar.bz2 &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${PCRE_PREFIX}/download/pcre-8.33.tar.bz2
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${PCRE_PREFIX}
  BUILD_COMMAND make
  INSTALL_COMMAND make install)

################################################################################
# PHP.
set(PHP_CPPFLAGS "-I${APR_PREFIX}/include -I${APR_PREFIX}/include/apr-1")
add_external_project(
  ${PHP_TARGET}
  PREFIX ${PHP_PREFIX}
  DOWNLOAD_DIR ${PHP_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O php-5.5.6.tar.bz2 http://www.php.net/get/php-5.5.6.tar.bz2/from/this/mirror &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/php-5.5.6.tar.bz2.sig
          php-5.5.6.tar.bz2 &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${PHP_PREFIX}/download/php-5.5.6.tar.bz2
  PATCH_COMMAND
      patch -Np0 < ${THIRD_PARTY_SOURCE_DIR}/php.patch
  CONFIGURE_COMMAND <SOURCE_DIR>/configure
      --prefix=/usr/local/php/
      --enable-bcmath
      --enable-calendar
      --enable-cli
      --enable-dba
      --enable-exif
      --enable-ftp
      --enable-gd-native-ttf
      --enable-intl
      --enable-mbregex
      --enable-mbstring
      --enable-shmop
      --enable-soap
      --enable-sockets
      --enable-sysvmsg
      --enable-sysvsem
      --enable-sysvshm
      --enable-wddx
      --enable-zip
      --with-apxs2=/usr/local/apache/httpd/bin/apxs
      --with-bz2=${BZIP2_PREFIX}
      --with-config-file-path=/usr/local/php/etc/
      --with-curl=${LIBCURL_PREFIX}
      --with-freetype-dir=${FREETYPE_PREFIX}
      --with-gd
      --with-iconv=${LIBICONV_PREFIX}
      --with-iconv-dir=${LIBICONV_PREFIX}
      --with-icu-dir=${ICU_PREFIX}
      --with-imap-ssl
      --with-imap=${IMAP_2007F_PREFIX}
      --with-jpeg-dir=${LIBJPG_PREFIX}
      --with-kerberos
      --with-kerberos=/usr
      --with-ldap-sasl=${LDAP_SASL_PREFIX}
      --with-ldap=${LDAP_PREFIX}
      --with-libxml-dir=/usr
      --with-mcrypt=${LIBMCRYPT_PREFIX}
      --with-mysql-sock=/usr/local/mysql/data/mysql.sock
      --with-mysql=mysqlnd
      --with-mysqli=mysqlnd
      --with-openssl=${OPENSSL_PREFIX}
      --with-pcre-regex
      --with-pdo-mysql=mysqlnd
      --with-png-dir=${LIBPNG_PREFIX}
      --with-readline=${READLINE_PREFIX}
      --with-snmp=/usr
      # --with-tidy
      --with-xmlrpc
      --with-xsl=/usr
      --with-zlib=${ZLIB_PREFIX}
      --without-pear
      CPPFLAGS=${PHP_CPPFLAGS}
  BUILD_COMMAND make
  INSTALL_COMMAND
      echo "This will install PHP in /usr/local/php." &&
      sudo make install)
add_dependencies(${PHP_TARGET} ${APR_TARGET})
add_dependencies(${PHP_TARGET} ${APR_UTIL_TARGET})
add_dependencies(${PHP_TARGET} ${BZIP2_TARGET})
add_dependencies(${PHP_TARGET} ${FREETYPE_TARGET})
add_dependencies(${PHP_TARGET} ${ICU_TARGET})
add_dependencies(${PHP_TARGET} ${IMAP_2007F_TARGET})
add_dependencies(${PHP_TARGET} ${LDAP_TARGET})
add_dependencies(${PHP_TARGET} ${LDAP_SASL_TARGET})
add_dependencies(${PHP_TARGET} ${LIBCURL_TARGET})
add_dependencies(${PHP_TARGET} ${LIBICONV_TARGET})
add_dependencies(${PHP_TARGET} ${LIBJPG_TARGET})
add_dependencies(${PHP_TARGET} ${LIBMCRYPT_TARGET})
add_dependencies(${PHP_TARGET} ${LIBPNG_TARGET})
add_dependencies(${PHP_TARGET} ${OPENSSL_TARGET})
add_dependencies(${PHP_TARGET} ${READLINE_TARGET})
add_dependencies(${PHP_TARGET} ${ZLIB_TARGET})

################################################################################
# protobuf - Google's Protocol Buffers library.
add_external_project(
  ${PROTOBUF_TARGET}
  PREFIX ${PROTOBUF_PREFIX}
  DOWNLOAD_COMMAND
      ${SVN} export --force http://protobuf.googlecode.com/svn/trunk/ ${PROTOBUF_TARGET}
  CONFIGURE_COMMAND
      ./autogen.sh &&
      ./configure --prefix=${PROTOBUF_PREFIX} ${HOST}
          CC=${CMAKE_C_COMPILER}
          CXX=${CMAKE_CXX_COMPILER} CFLAGS=${CMAKE_C_FLAGS_WITH_ARCHS}
          CXXFLAGS=${CMAKE_CXX_FLAGS_WITH_ARCHS}
          LDFLAGS=-Wc,${CMAKE_SHARED_LINKER_FLAGS}
          --with-protoc=${PROTOBUF_PROTOC_EXECUTABLE}
          ${CONFIGURE_LIB_TYPE}
  BUILD_IN_SOURCE 1)
  add_dependencies(${PROTOBUF_TARGET} ${PROTOC_TARGET})
if (PYTHON_SUPPORTED)
  add_external_project_step(${PROTOBUF_TARGET} build_python_runtime
    COMMAND /usr/bin/env python setup.py build
    DEPENDEES build
    DEPENDERS install
    WORKING_DIRECTORY <SOURCE_DIR>/python)
  add_external_project_step(${PROTOBUF_TARGET} install_python_runtime
    COMMAND /usr/bin/env python setup.py install
    DEPENDEES install
    WORKING_DIRECTORY <SOURCE_DIR>/python)
  add_dependencies(${PROTOBUF_TARGET} ${VIRTUALENV_TARGET})
endif ()
add_include_directory(${PROTOBUF_PREFIX}/include)

################################################################################
# protoc - Google's Protocol Buffers compiler.
add_external_project(
  ${PROTOC_TARGET}
  PREFIX ${PROTOC_PREFIX}
  DOWNLOAD_COMMAND
      ${SVN} export --force http://protobuf.googlecode.com/svn/trunk/ ${PROTOC_TARGET}
  CONFIGURE_COMMAND
      ./autogen.sh &&
      ./configure --prefix=${PROTOC_PREFIX}
  BUILD_IN_SOURCE 1)
# This is required for protobuf_generate_* rules.
set(PROTOBUF_PROTOC_EXECUTABLE ${PROTOC_PREFIX}/bin/protoc)

################################################################################
# Readline.
add_external_project(
  ${READLINE_TARGET}
  PREFIX ${READLINE_PREFIX}
  DOWNLOAD_DIR ${READLINE_PREFIX}/download
  DOWNLOAD_COMMAND
      wget ftp://ftp.cwru.edu/pub/bash/readline-6.2.tar.gz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/readline-6.2.tar.gz.sig
          readline-6.2.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${READLINE_PREFIX}/download/readline-6.2.tar.gz
  PATCH_COMMAND
      patch -Np0 < ${THIRD_PARTY_SOURCE_DIR}/readline.patch
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${READLINE_PREFIX}
      CC=${CMAKE_C_COMPILER}
      CXX=${CMAKE_CXX_COMPILER}
      CFLAGS=${CMAKE_C_FLAGS_WITH_ARCHS}
      CXXFLAGS=${CMAKE_CXX_FLAGS_WITH_ARCHS}
      LDFLAGS=${LDFLAGS_WITH_ARCHS}
      ${CONFIGURE_LIB_TYPE})
add_include_directory(${READLINE_PREFIX}/include)

################################################################################
# Shark.
set(SHARK_C_FLAGS "-L${OPENMP_PREFIX}/lib -DSHARK_USE_OPENMP -fopenmp -I${OPENMP_PREFIX}/include ${BOOST_C_FLAGS}")
set(SHARK_CXX_FLAGS "-L${OPENMP_PREFIX}/lib -DSHARK_USE_OPENMP -fopenmp -I${OPENMP_PREFIX}/include ${BOOST_CXX_FLAGS}")
set(SHARK_EXE_LINKER_FLAGS "-L${OPENMP_PREFIX}/lib ${CMAKE_EXE_LINKER_FLAGS}")
set(SHARK_SHARED_LINKER_FLAGS "-L${OPENMP_PREFIX}/lib ${CMAKE_SHARED_LINKER_FLAGS}")
add_external_project(
  ${SHARK_TARGET}
  PREFIX ${SHARK_PREFIX}
  DOWNLOAD_COMMAND
      ${GIT} clone --depth 1 https://github.com/QuentinFiard/shark.git ${SHARK_TARGET}
  CONFIGURE_COMMAND
      BOOST_ROOT=${BOOST_PREFIX} ${CMAKE_COMMAND} <SOURCE_DIR>
          -DOPT_MAKE_TESTS=OFF
          -DOPT_DYNAMIC_LIBRARY=${BUILD_SHARED_LIBS}
          -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
          -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
          -DCMAKE_BUILD_TYPE=RELEASE
          -DCMAKE_C_FLAGS=${SHARK_C_FLAGS}
          -DCMAKE_CXX_FLAGS=${SHARK_CXX_FLAGS}
          -DCMAKE_EXE_LINKER_FLAGS=${SHARK_EXE_LINKER_FLAGS}
          -DCMAKE_SHARED_LINKER_FLAGS=${SHARK_SHARED_LINKER_FLAGS}
          -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
          -DCMAKE_OSX_ARCHITECTURES=${ARCHS}
          -DCMAKE_INSTALL_PREFIX=${SHARK_PREFIX})
add_external_project_step(${SHARK_TARGET} set_install_names
  COMMAND
      ${SET_INSTALL_NAMES} ${CMAKE_INSTALL_NAME_TOOL}
          ${CMAKE_SHARED_LIBRARY_SUFFIX}
  DEPENDEES install
  DEPENDS ${SET_INSTALL_NAMES}
  WORKING_DIRECTORY ${SHARK_PREFIX}/lib
)
add_include_directory(${SHARK_PREFIX}/include)
add_definitions(-DSHARK_USE_OPENMP)

# Adds dependencies.
add_dependencies(${SHARK_TARGET} ${BOOST_TARGET})
add_dependencies(${SHARK_TARGET} ${OPENMP_TARGET})

################################################################################
# TBB.
add_external_project(
  ${TBB_TARGET}
  PREFIX ${TBB_PREFIX}
  DOWNLOAD_DIR ${TBB_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O tbb42_20131003oss_src.tgz https://www.threadingbuildingblocks.org/sites/default/files/software_releases/source/tbb42_20131003oss_src.tgz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/tbb42_20131003oss_src.tgz.sig
          tbb42_20131003oss_src.tgz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 2 -xvf
          ${TBB_PREFIX}/download/tbb42_20131003oss_src.tgz
  CONFIGURE_COMMAND ""
  BUILD_COMMAND
      make -j${PROCESSOR_COUNT} compiler=clang
          CFLAGS=${CMAKE_C_FLAGS} CXXFLAGS=${CMAKE_CXX_FLAGS}
          LDFLAGS=${CMAKE_SHARED_LINKER_FLAGS}
  INSTALL_COMMAND
      find include -name "*.h" | cpio -dp <INSTALL_DIR>
  PATCH_COMMAND
      patch -Np0 < ${THIRD_PARTY_SOURCE_DIR}/tbb.patch
  BUILD_IN_SOURCE 1)
add_external_project_step(${TBB_TARGET} install_libs
  COMMAND
      ${CMAKE_COMMAND} -E make_directory ${TBB_PREFIX}/lib &&
      find build -name "*${CMAKE_SHARED_LIBRARY_SUFFIX}" |
      xargs -I{} cp "{}" ${TBB_PREFIX}/lib
  DEPENDEES install
  WORKING_DIRECTORY <SOURCE_DIR>)
add_external_project_step(${TBB_TARGET} set_install_names
  COMMAND
      ${SET_INSTALL_NAMES} ${CMAKE_INSTALL_NAME_TOOL}
          ${CMAKE_SHARED_LIBRARY_SUFFIX}
  DEPENDEES install_libs
  DEPENDS ${SET_INSTALL_NAMES}
  WORKING_DIRECTORY ${TBB_PREFIX}/lib)
add_include_directory(${TBB_PREFIX}/include)

################################################################################
# virtualenv.
if (PYTHON_SUPPORTED)
  add_external_project(
    ${VIRTUALENV_TARGET}
    PREFIX ${VIRTUALENV_PREFIX}
    DOWNLOAD_DIR ${VIRTUALENV_PREFIX}/download
    DOWNLOAD_COMMAND
        wget -O virtualenv-1.9.1.tar.gz https://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.9.1.tar.gz &&
        gpg --verify ${THIRD_PARTY_SOURCE_DIR}/virtualenv-1.9.1.tar.gz.sig
            virtualenv-1.9.1.tar.gz &&
        cd <SOURCE_DIR> &&
        tar --strip-components 1 -xvf
            ${VIRTUALENV_PREFIX}/download/virtualenv-1.9.1.tar.gz
    CONFIGURE_COMMAND
        ${CMAKE_COMMAND} -E make_directory ${VIRTUALENV_PREFIX}/lib/python
    BUILD_COMMAND python setup.py install --home=${VIRTUALENV_PREFIX}
    INSTALL_COMMAND
        cd ${VIRTUALENV_PREFIX} && ./bin/virtualenv env
    BUILD_IN_SOURCE 1)
  set(LINE "source ${PROJECT_SOURCE_DIR}/.profile")
  add_custom_command(TARGET ${VIRTUALENV_TARGET} POST_BUILD
    COMMAND
        grep -q "${LINE}" $ENV{HOME}/.profile && exit 0 ||
        echo "\\033[31;1m***********************************************************\\nPlease add the following line to your .profile file\\n\\n${LINE}\\n***********************************************************\\n\\033[0m" &&
        exit 1
    VERBATIM)
endif ()

################################################################################
# xz.
add_external_project(
  ${XZ_TARGET}
  PREFIX ${XZ_PREFIX}
  DOWNLOAD_DIR ${XZ_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O xz-5.0.5.tar.bz2 http://tukaani.org/xz/xz-5.0.5.tar.bz2 &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/xz-5.0.5.tar.bz2.sig
          xz-5.0.5.tar.bz2 &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${XZ_PREFIX}/download/xz-5.0.5.tar.bz2
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${XZ_PREFIX}
  BUILD_COMMAND make
  INSTALL_COMMAND make install)

################################################################################
# zlib.
if (NOT BUILD_SHARED_LIBS)
  set(ZLIB_CONFIGURE_LIB_TYPE "--static")
endif ()
set(ZLIB_C_FLAGS "${CMAKE_C_FLAGS_WITH_ARCHS} ${LINKER_AS_COMPILER_FLAGS}")
set(CONFIGURE_COMMAND
        export CFLAGS=${ZLIB_C_FLAGS} &&
        <SOURCE_DIR>/configure
            --prefix=${ZLIB_PREFIX}
            --archs=${ARCHS_AS_FLAGS} ${ZLIB_CONFIGURE_LIB_TYPE})
add_external_project(
  ${ZLIB_TARGET}
  PREFIX ${ZLIB_PREFIX}
  DOWNLOAD_DIR ${ZLIB_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O zlib-1.2.8.tar.gz http://zlib.net/zlib-1.2.8.tar.gz &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/zlib-1.2.8.tar.gz.sig
          zlib-1.2.8.tar.gz &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${ZLIB_PREFIX}/download/zlib-1.2.8.tar.gz
  CONFIGURE_COMMAND ${CONFIGURE_COMMAND}
  BUILD_IN_SOURCE 1)


################################################################################
# Generative rules.
################################################################################
function(protobuf_generate_cc SRCS HDRS)
  if(NOT ARGN)
    message(SEND_ERROR
            "Error: protobuf_generate_cc called without any proto files")
    return()
  endif(NOT ARGN)

  set(${SRCS})
  set(${HDRS})
  foreach(FIL ${ARGN})
    get_filename_component(ABS_FIL ${FIL} ABSOLUTE)
    get_filename_component(FIL_WE ${FIL} NAME_WE)

    list(APPEND ${SRCS} "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb.cc")
    list(APPEND ${HDRS} "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb.h")

    add_custom_command(
      OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb.cc"
             "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb.h"
      COMMAND  ${PROTOBUF_PROTOC_EXECUTABLE}
      ARGS --cpp_out ${PROJECT_BINARY_DIR}/src
          -I${PROJECT_SOURCE_DIR}/src  ${ABS_FIL}
      DEPENDS ${PROTOBUF_TARGET} ${PROTOC_TARGET} ${ABS_FIL}
      COMMENT "Running C++ protocol buffer compiler on ${FIL}"
      VERBATIM)
  endforeach()

  set_source_files_properties(${${SRCS}} ${${HDRS}} PROPERTIES GENERATED TRUE)
  set(${SRCS} ${${SRCS}} PARENT_SCOPE)
  set(${HDRS} ${${HDRS}} PARENT_SCOPE)
endfunction()

function(protobuf_generate_java SRCS)
  if (NOT JAVA_SUPPORTED)
    return()
  endif ()
  if(NOT ARGN)
    message(SEND_ERROR
            "Error: protobuf_generate_java() called without any proto files")
    return()
  endif(NOT ARGN)

  set(${SRCS})
  foreach(FIL ${ARGN})
    get_filename_component(ABS_FIL ${FIL} ABSOLUTE)
    get_filename_component(FIL_WE ${FIL} NAME_WE)
    underscores_to_camel_case(${FIL_WE} FIL_WE)

    set(SRC "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.java")
    list(APPEND ${SRCS} ${SRC})
    add_custom_command(
      OUTPUT ${SRC}
      COMMAND  ${PROTOBUF_PROTOC_EXECUTABLE}
      ARGS --java_out ${PROJECT_BINARY_DIR}/src
          -I${PROJECT_SOURCE_DIR}/src  ${ABS_FIL}
      DEPENDS ${PROTOBUF_TARGET} ${PROTOC_TARGET} ${ABS_FIL}
      COMMENT "Running java protocol buffer compiler on ${FIL}"
      VERBATIM)
  endforeach()

  set_source_files_properties(${${SRCS}} PROPERTIES GENERATED TRUE)
  set(${SRCS} ${${SRCS}} PARENT_SCOPE)
endfunction()

function(protobuf_generate_py SRCS)
  if (NOT PYTHON_SUPPORTED)
    return()
  endif ()
  if(NOT ARGN)
    message(SEND_ERROR
            "Error: protobuf_generate_py() called without any proto files")
    return()
  endif(NOT ARGN)

  set(${SRCS})
  foreach(FIL ${ARGN})
    get_filename_component(ABS_FIL ${FIL} ABSOLUTE)
    get_filename_component(FIL_WE ${FIL} NAME_WE)

    list(APPEND ${SRCS} "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}_pb2.py")

    add_custom_command(
      OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}_pb2.py"
      COMMAND  ${PROTOBUF_PROTOC_EXECUTABLE}
      ARGS --python_out ${PROJECT_BINARY_DIR}/src
          -I${PROJECT_SOURCE_DIR}/src  ${ABS_FIL}
      DEPENDS ${PROTOBUF_TARGET} ${PROTOC_TARGET} ${ABS_FIL}
      COMMENT "Running python protocol buffer compiler on ${FIL}"
      VERBATIM)
  endforeach()

  set_source_files_properties(${${SRCS}} PROPERTIES GENERATED TRUE)
  set(${SRCS} ${${SRCS}} PARENT_SCOPE)
endfunction()

function(flex_generate_scanner LEX SRC_ HDR_)
  get_filename_component(ABS_LEX ${LEX} ABSOLUTE)
  get_filename_component(LEX_WE ${LEX} NAME_WE)
  set(SRC "${CMAKE_CURRENT_BINARY_DIR}/${LEX_WE}.cc")
  set(HDR "${CMAKE_CURRENT_BINARY_DIR}/${LEX_WE}.h")
  add_custom_command(
      OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${LEX_WE}.cc"
             "${CMAKE_CURRENT_BINARY_DIR}/${LEX_WE}.h"
      COMMAND ${FLEX_EXECUTABLE}
      ARGS -v -o ${SRC} --header-file=${HDR} ${ABS_LEX}
      DEPENDS ${FLEX_TARGET} ${ABS_LEX}
      COMMENT "Running Flex++ on ${LEX}"
      VERBATIM)
  set_source_files_properties(${SRC} ${HDR} PROPERTIES GENERATED TRUE)
  set(${SRC_} ${SRC} PARENT_SCOPE)
  set(${HDR_} ${HDR} PARENT_SCOPE)
endfunction()

function(bison_generate_parser YAC SRC_ HDR_)
  get_filename_component(ABS_YAC ${YAC} ABSOLUTE)
  get_filename_component(YAC_WE ${YAC} NAME_WE)
  set(SRC "${CMAKE_CURRENT_BINARY_DIR}/${YAC_WE}.cc")
  set(HDR "${CMAKE_CURRENT_BINARY_DIR}/${YAC_WE}.h")
  add_custom_command(
      OUTPUT ${SRC}
             "${CMAKE_CURRENT_BINARY_DIR}/${YAC_WE}.hh"
      COMMAND  ${BISON_EXECUTABLE}
      ARGS -v -d -o ${SRC} ${ABS_YAC}
      DEPENDS ${BISON_TARGET} ${ABS_YAC}
      COMMENT "Running Bison on ${YAC}"
      VERBATIM)
  add_custom_command(
      OUTPUT ${HDR}
      COMMAND mv
      ARGS "${CMAKE_CURRENT_BINARY_DIR}/${YAC_WE}.hh" ${HDR}
      DEPENDS ${ABS_YAC}
      COMMENT "Moving header"
      VERBATIM)
  set_source_files_properties(${SRC} ${HDR} PROPERTIES GENERATED TRUE)
  set(${SRC_} ${SRC} PARENT_SCOPE)
  set(${HDR_} ${HDR} PARENT_SCOPE)
endfunction()

################################################################################
# Other functions.
################################################################################
function(use_openmp TARGET)
  add_cxxflags(${TARGET} ${OPENMP_COMPILE_FLAG})
  add_compile_defs(${TARGET} "USE_OPENMP")
endfunction(use_openmp)

################################################################################
# External dependency management.
################################################################################
include(${CMAKE_CURRENT_LIST_DIR}/third_party/maven_libraries.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/third_party/pip_libraries.cmake)
