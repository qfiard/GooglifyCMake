include(ExternalProject)

set(THIRD_PARTY_BINARY_DIR ${PROJECT_BINARY_DIR}/third_party)
set(THIRD_PARTY_SOURCE_DIR ${PROJECT_SOURCE_DIR}/third_party)

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

set(SET_INSTALL_NAMES "${PROJECT_SOURCE_DIR}/support/set_install_names.sh")

# A few convenient functions to define third-party libraries.
function(set_prefix OUT PREFIX)
  set(${OUT} ${THIRD_PARTY_BINARY_DIR}/${PREFIX} PARENT_SCOPE)
endfunction()

function(add_target OUT NAME)
  set(${OUT}_PREFIX ${THIRD_PARTY_BINARY_DIR}/${NAME} PARENT_SCOPE)
  set(${OUT}_TARGET third_party.${NAME}_target PARENT_SCOPE)
endfunction()

macro(set_library NAME)
  set(third_party.${NAME} ${ARGN})
endmacro()

macro(append_library NAME)
  list(APPEND third_party.${NAME} ${ARGN})
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

# Forward declaration.
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
add_target(RAPIDXML rapidxml)
add_target(READLINE readline)
add_target(SHARK shark)
add_target(TBB tbb)
add_target(VIRTUALENV virtualenv)
add_target(XZ xz)
add_target(ZLIB zlib)

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
      <SOURCE_DIR>/configure --prefix=${APR_PREFIX} --enable-threads
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
      <SOURCE_DIR>/configure --prefix=${APR_PREFIX}
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
  CONFIGURE_COMMAND
      BOOST_ROOT=${BOOST_PREFIX} cmake <SOURCE_DIR>
          -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
          -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
          -DCMAKE_BUILD_TYPE=RELEASE
          -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
          -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
          -DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}
          -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
          -DCMAKE_INSTALL_PREFIX=${ARABICA_PREFIX}
          -DBUILD_ARABICA_EXAMPLES=OFF)
add_external_project_step(${ARABICA_TARGET} set_install_names
  COMMAND
      ${SET_INSTALL_NAMES} ${CMAKE_INSTALL_NAME_TOOL}
          ${CMAKE_SHARED_LIBRARY_SUFFIX}
  DEPENDEES install
  DEPENDS ${SET_INSTALL_NAMES}
  WORKING_DIRECTORY ${ARABICA_PREFIX}/lib)
set(ARABICA arabica)
add_dependencies(${ARABICA_TARGET} ${LIBXML_TARGET})
add_include_directory(${ARABICA_PREFIX}/include)
add_include_directory(${ARABICA_PREFIX}/include/arabica)
add_link_directory(${ARABICA_PREFIX}/lib)

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
      <SOURCE_DIR>/dist/configure --prefix=${BERKELEY_DB_PREFIX}
      --enable-compat185
      --enable-cxx
      --enable-dbm)

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
  CONFIGURE_COMMAND ./configure --prefix=${BISON_PREFIX}
  BUILD_COMMAND make
  INSTALL_COMMAND make install
  BUILD_IN_SOURCE 1)
set(BISON_EXECUTABLE ${BISON_PREFIX}/bin/bison)

################################################################################
# Boost.
set(BOOST_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ftemplate-depth-1024")
set(BUILD_COMMAND
    b2 release toolset=clang-darwin cxxflags=${BOOST_CXX_FLAGS}
        linkflags=${CMAKE_SHARED_LINKER_FLAGS}
        define=BOOST_NO_CXX11_NUMERIC_LIMITS
        define=BOOST_SYSTEM_NO_DEPRECATED install)
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
  CONFIGURE_COMMAND
      ./bootstrap.sh --prefix=${BOOST_PREFIX}
  BUILD_COMMAND ${BUILD_COMMAND}
  PATCH_COMMAND
      patch -Np0 < ${THIRD_PARTY_SOURCE_DIR}/boost.patch
  BUILD_IN_SOURCE 1)
add_include_directory(${BOOST_PREFIX}/include)
add_link_directory(${BOOST_PREFIX}/lib)
set_library(boost_atomic boost_atomic)
set_library(boost_chrono boost_chrono)
set_library(boost_context boost_context)
set_library(boost_coroutine boost_coroutine)
set_library(boost_date_time boost_date_time)
set_library(boost_exception boost_exception)
set_library(boost_filesystem boost_filesystem)
set_library(boost_graph boost_graph)
set_library(boost_graph_parallel boost_graph_parallel)
set_library(boost_headers "")
set_library(boost_iostreams boost_iostreams)
set_library(boost_locale boost_locale)
set_library(boost_log boost_log)
set_library(boost_math boost_math)
set_library(boost_mpi boost_mpi)
set_library(boost_program_options boost_program_options)
set_library(boost_python boost_python)
set_library(boost_random boost_random)
set_library(boost_regex boost_regex)
set_library(boost_serialization boost_serialization)
set_library(boost_signals boost_signals)
set_library(boost_system boost_system)
set_library(boost_test boost_test)
set_library(boost_thread boost_thread)
set_library(boost_timer boost_timer)
set_library(boost_wave boost_wave)
set(BOOST_TIME_ZONE_CSV
    "${BOOST_PREFIX}/src/${BOOST_TARGET}/libs/date_time/data/date_time_zonespec.csv")

# Dependencies.
append_library(boost_filesystem boost_system)

# Aliases.
set_library(boost_asio boost_system)

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
  INSTALL_COMMAND
      mkdir -p ${BSDIFF_PREFIX}/bin &&
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
      ${SVN} export --force http://llvm.org/svn/llvm-project/llvm/trunk ${CLANG_TARGET} &&
      ${SVN} export --force http://llvm.org/svn/llvm-project/compiler-rt/trunk ${CLANG_TARGET}/projects/compiler-rt &&
      ${SVN} export --force http://llvm.org/svn/llvm-project/cfe/trunk ${CLANG_TARGET}/tools/clang
  CMAKE_ARGS
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DCMAKE_C_FLAGS=${RELEASE_FLAGS}
      -DCMAKE_CXX_FLAGS=${RELEASE_FLAGS}
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_INSTALL_PREFIX=${CLANG_PREFIX})

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
  INSTALL_COMMAND
      echo "This will replace your clang compiler with Clang/OpenMP." &&
      sudo make install)

################################################################################
# curl-asio, an asynchronous CURL wrapper based on Boost Asio.
# See https://github.com/mologie/curl-asio.
set(CURL_ASIO_C_FLAGS "-I${LIBCURL_PREFIX}/include ${CMAKE_C_FLAGS}")
set(CURL_ASIO_CXX_FLAGS "-I${LIBCURL_PREFIX}/include ${CMAKE_CXX_FLAGS}")
set(CURL_ASIO_LINKER_FLAGS "-L${LIBCURL_PREFIX}/lib ${LINKER_FLAGS}")
add_external_project(
  ${CURL_ASIO_TARGET}
  PREFIX ${CURL_ASIO_PREFIX}
  DOWNLOAD_COMMAND
      ${GIT} clone --depth 1 https://github.com/QuentinFiard/curl-asio.git
  CONFIGURE_COMMAND
      BOOST_ROOT=${BOOST_PREFIX} cmake <SOURCE_DIR>
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DCMAKE_C_FLAGS=${CURL_ASIO_C_FLAGS}
      -DCMAKE_CXX_FLAGS=${CURL_ASIO_CXX_FLAGS}
      -DCMAKE_SHARED_LINKER_FLAGS=${CURL_ASIO_LINKER_FLAGS}
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
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
add_link_directory(${CURL_ASIO_PREFIX}/lib)
set_library(curl_asio libcurlasio boost_system libcurl)
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
      -DCMAKE_INSTALL_PREFIX=${DLIB_PREFIX}
  INSTALL_COMMAND
      mkdir -p ${DLIB_PREFIX}/lib &&
      cp -f libdlib.a ${DLIB_PREFIX}/lib &&
      mkdir -p ${DLIB_PREFIX}/include/dlib &&
      cd <SOURCE_DIR> &&
      find . -name "*.h" |
      cpio -dp <INSTALL_DIR>/include/dlib)
add_include_directory(${DLIB_PREFIX}/include)
add_link_directory(${DLIB_PREFIX}/lib)
set_library(dlib dlib)

################################################################################
# Eigen.
add_external_project(
  ${EIGEN_TARGET}
  PREFIX ${EIGEN_PREFIX}
  DOWNLOAD_COMMAND
      ${HG} clone https://bitbucket.org/eigen/eigen eigen_target
  CMAKE_ARGS
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
      -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
      -DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DCMAKE_INSTALL_PREFIX=${EIGEN_PREFIX}
      # Do not add register for pkg-config as it would require root permissions.
      -DEIGEN_BUILD_PKGCONFIG=OFF
      -DGMP_INCLUDES=${GMP_PREFIX}/include
      -DGMP_LIBRARIES=${GMP_PREFIX}/lib
      -DMPFR_INCLUDES=${MPFR_PREFIX}/include
      -DMPFR_LIBRARIES=${MPFR_PREFIX}/lib)
set_library(eigen "")  # Eigen is header only.
set(EIGEN_INCLUDE_PATH ${EIGEN_PREFIX}/include/eigen3)
add_include_directory(${EIGEN_INCLUDE_PATH})
add_link_directory(${EIGEN_PREFIX}/lib)
add_dependencies(${EIGEN_TARGET} ${GMP_TARGET})
add_dependencies(${EIGEN_TARGET} ${MPFR_TARGET})

################################################################################
# Flex.
add_external_project(
  flex
  PREFIX ${FLEX_PREFIX}
  DOWNLOAD_DIR ${FLEX_PREFIX}/download
  DOWNLOAD_COMMAND
      wget -O flex-2.5.37.tar.bz2 http://downloads.sourceforge.net/project/flex/flex-2.5.37.tar.bz2?r=http%3A%2F%2Fflex.sourceforge.net%2F&ts=1382395008&use_mirror=kent &&
      gpg --verify ${THIRD_PARTY_SOURCE_DIR}/flex-2.5.37.tar.bz2.sig
          flex-2.5.37.tar.bz2 &&
      cd <SOURCE_DIR> &&
      tar --strip-components 1 -xvf
          ${FLEX_PREFIX}/download/flex-2.5.37.tar.bz2
  CONFIGURE_COMMAND ./configure --prefix=${FLEX_PREFIX}
  BUILD_COMMAND make
  INSTALL_COMMAND make install
  BUILD_IN_SOURCE 1)
add_include_directory(${FLEX_PREFIX}/include)
add_link_directory(${FLEX_PREFIX}/lib)
set_library(flex fl)
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
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${FREETYPE_PREFIX}
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
      -DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DLIBRARY_OUTPUT_PATH=<INSTALL_DIR>/lib
  INSTALL_COMMAND
      mkdir -p <INSTALL_DIR>/include/g2log &&
      cd <SOURCE_DIR>/src &&
      find . -name "*.h" |
      cpio -dp <INSTALL_DIR>/include/g2log)
add_include_directory(${G2LOG_PREFIX}/include)
add_link_directory(${G2LOG_PREFIX}/lib)
set_library(g2log lib_g2logger)

################################################################################
# GNU GCC compiler.
message(
    WARNING
    "If you indend to build GCC please replace SYSROOT with the correct value"
    " for your system. You can otherwise safely ignore this warning.")
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
      ./configure --prefix=${GCC_PREFIX} --with-gmp=${GMP_PREFIX}
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
      <SOURCE_DIR>/configure --prefix=${GFLAGS_PREFIX} CC=${CMAKE_C_COMPILER}
          CXX=${CMAKE_CXX_COMPILER} CFLAGS=${CMAKE_C_FLAGS}
          CXXFLAGS=${CMAKE_CXX_FLAGS} LDFLAGS=${CMAKE_SHARED_LINKER_FLAGS})
add_include_directory(${GFLAGS_PREFIX}/include)
add_link_directory(${GFLAGS_PREFIX}/lib)
set_library(gflags gflags)

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
  INSTALL_COMMAND
      mkdir -p <INSTALL_DIR>/include <INSTALL_DIR>/lib &&
      cd <BINARY_DIR> &&
      find . -name "*.dylib" | cpio -dp <INSTALL_DIR>/lib &&
      cd <SOURCE_DIR>/include &&
      find . -name "*.h" | cpio -dp <INSTALL_DIR>/include)
add_include_directory(${GMOCK_PREFIX}/include)
add_link_directory(${GMOCK_PREFIX}/lib)
set_library(gmock gmock gmock_main)

################################################################################
# GMP.
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
  CONFIGURE_COMMAND
      ./configure --prefix=${GMP_PREFIX} --enable-cxx CC=${CMAKE_C_COMPILER}
          CXX=${CMAKE_CXX_COMPILER} CFLAGS=${CMAKE_C_FLAGS}
          CXXFLAGS=${CMAKE_CXX_FLAGS} LDFLAGS=${CMAKE_SHARED_LINKER_FLAGS}
  BUILD_COMMAND make -j${PROCESSOR_COUNT}
  INSTALL_COMMAND make install
  BUILD_IN_SOURCE 1)
add_dependencies(${GMP_TARGET} ${GNUTAR_TARGET})
set_library(gmp gmp)
add_include_directory(${GMP_PREFIX}/include)
add_link_directory(${GMP_PREFIX}/lib)

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
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${GNUGREP_PREFIX}
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
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${GNUTAR_PREFIX}
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
  INSTALL_COMMAND
    mkdir -p <INSTALL_DIR>/include <INSTALL_DIR>/lib &&
    cd <BINARY_DIR> &&
    find . -name "*.dylib" | cpio -dp <INSTALL_DIR>/lib &&
    cd <SOURCE_DIR>/include &&
    find . -name "*.h" | cpio -dp <INSTALL_DIR>/include)
add_include_directory(${GTEST_PREFIX}/include)
add_link_directory(${GTEST_PREFIX}/lib)
set_library(gtest gtest gtest_main)

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
      sudo mkdir -p /usr/local/haproxy &&
      sudo mv ${HAPROXY_PREFIX}/usr/local/doc /usr/local/haproxy &&
      sudo mv ${HAPROXY_PREFIX}/usr/local/sbin /usr/local/haproxy &&
      sudo mv ${HAPROXY_PREFIX}/usr/local/share /usr/local/haproxy &&
      sudo rm -rf ${HAPROXY_PREFIX}/usr &&
      sudo mkdir -p /usr/local/haproxy/logs
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
      mkdir -p ${IMAP_2007F_PREFIX}/lib ${IMAP_2007F_PREFIX}/include &&
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
  PATCH_COMMAND
      patch -Np0 < ${THIRD_PARTY_SOURCE_DIR}/jsoncpp.patch
  CMAKE_ARGS
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_BUILD_TYPE=RELEASE
      -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
      -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
      -DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
      -DCMAKE_INSTALL_PREFIX=${JSONCPP_PREFIX})
add_include_directory(${JSONCPP_PREFIX}/include)
add_link_directory(${JSONCPP_PREFIX}/lib)
set_library(jsoncpp jsoncpp)

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
      <SOURCE_DIR>/configure --prefix=${LDAP_PREFIX}
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
      <SOURCE_DIR>/configure --prefix=${LDAP_SASL_PREFIX}
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
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${LIBCURL_PREFIX}
      --with-darwinssl --with-zlib=${ZLIB_PREFIX})
add_include_directory(${LIBCURL_PREFIX}/include)
add_link_directory(${LIBCURL_PREFIX}/lib)
set_library(libcurl curl)
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
add_link_directory(${LIBCXX_PREFIX}/lib)
set_library(libcxx c++)
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
set_library(libcxxabi c++abi)
add_link_directory(${LIBCXXABI_PREFIX}/lib)
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
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${LIBICONV_PREFIX})

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
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${LIBJPG_PREFIX})

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
      <SOURCE_DIR>/configure --prefix=${LIBMCRYPT_PREFIX}
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
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${LIBMHASH_PREFIX}
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
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${LIBPNG_PREFIX})

################################################################################
# libxml.
add_external_project(
  ${LIBXML_TARGET}
  PREFIX ${LIBXML_PREFIX}
  DOWNLOAD_COMMAND
      ${GIT} clone --depth 1 git://git.gnome.org/libxml2 ${LIBXML_TARGET}
  CONFIGURE_COMMAND
      <SOURCE_DIR>/autogen.sh --prefix=${LIBXML_PREFIX}
          --with-lzma=${XZ_PREFIX}
          --with-zlib=${ZLIB_PREFIX}
          CC=${CMAKE_C_COMPILER}
          CXX=${CMAKE_CXX_COMPILER} CFLAGS=${CMAKE_C_FLAGS}
          CXXFLAGS=${CMAKE_CXX_FLAGS} LDFLAGS=${CMAKE_SHARED_LINKER_FLAGS})
add_include_directory(${LIBXML_PREFIX}/include)
add_include_directory(${LIBXML_PREFIX}/include/libxml2)
add_link_directory(${LIBXML_PREFIX}/lib)
set_library(libxml xml2)
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
      <SOURCE_DIR>/configure --prefix=${MARISA_TRIE_PREFIX} CC=${CMAKE_C_COMPILER}
          CXX=${CMAKE_CXX_COMPILER} CFLAGS=${CMAKE_C_FLAGS}
          CXXFLAGS=${CMAKE_CXX_FLAGS} LDFLAGS=${CMAKE_SHARED_LINKER_FLAGS})
add_include_directory(${MARISA_TRIE_PREFIX}/include)
add_link_directory(${MARISA_TRIE_PREFIX}/lib)
set_library(marisa_trie marisa)

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
  CONFIGURE_COMMAND ""
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
  COMMAND ${MVN} -f ${PROJECT_SOURCE_DIR}/third_party/pom.xml
      -q dependency:copy-dependencies
  COMMAND date > ${MAVEN_LAST_DOWNLOAD}
  MAIN_DEPENDENCY ${PROJECT_SOURCE_DIR}/third_party/pom.xml)
set(GENERATE_CLASSPATH_FOR_MAVEN_LIBS
    ${PROJECT_SOURCE_DIR}/cmake/generate_classpath_for_maven_libs.py)
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
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${MCRYPT_PREFIX}
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
      <SOURCE_DIR>/configure --prefix=${MPC_PREFIX} --with-gmp=${GMP_PREFIX}
          --with-mpfr=${MPFR_PREFIX}
          CC=${CMAKE_C_COMPILER}
          CXX=${CMAKE_CXX_COMPILER} CFLAGS=${CMAKE_C_FLAGS}
          CXXFLAGS=${CMAKE_CXX_FLAGS} LDFLAGS=${CMAKE_SHARED_LINKER_FLAGS})
add_include_directory(${MPC_PREFIX}/include)
add_link_directory(${MPC_PREFIX}/lib)
set_library(mpc mpc)
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
      <SOURCE_DIR>/configure --prefix=${MPFR_PREFIX} --with-gmp=${GMP_PREFIX}
          CC=${CMAKE_C_COMPILER}
          CXX=${CMAKE_CXX_COMPILER} CFLAGS=${CMAKE_C_FLAGS}
          CXXFLAGS=${CMAKE_CXX_FLAGS} LDFLAGS=${CMAKE_SHARED_LINKER_FLAGS})
add_include_directory(${MPFR_PREFIX}/include)
add_link_directory(${MPFR_PREFIX}/lib)
set_library(mpfr mpfr)
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
      -DCMAKE_INSTALL_PREFIX=${MYSQL_PREFIX}
      -DWITH_ZLIB=test
      -DZLIB_ROOT=${ZLIB_PREFIX}
      -DWITH_SSL_PATH=${OPENSSL_PREFIX})
add_include_directory(${MYSQL_PREFIX}/include)
add_link_directory(${MYSQL_PREFIX}/lib)
add_dependencies(${MYSQL_TARGET} ${OPENSSL_TARGET})
add_dependencies(${MYSQL_TARGET} ${ZLIB_TARGET})

################################################################################
# Mysql C++/Connector.
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
add_link_directory(${MYSQLCPPCONN_PREFIX}/lib)
set_library(mysqlcppconn mysqlcppconn)

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
      sudo mkdir -p /usr/local/nginx/logs
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
      sudo mkdir -p /usr/local/ntp/logs)

################################################################################
# OpenCV.
set(OPENCV_SHARED_LINKER_FLAGS
    "-L${OPENCV_PREFIX}/src/${OPENCV_TARGET}-build/lib\
     ${CMAKE_SHARED_LINKER_FLAGS}")
set_library(opencv_exe_linker_flags "${OPENCV_SHARED_LINKER_FLAGS}")
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
  CONFIGURE_COMMAND
      cmake <SOURCE_DIR>
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
      -DCMAKE_INSTALL_PREFIX=${OPENCV_PREFIX})
add_external_project_step(${OPENCV_TARGET} set_install_names
  COMMAND
      ${SET_INSTALL_NAMES} ${CMAKE_INSTALL_NAME_TOOL}
          ${CMAKE_SHARED_LIBRARY_SUFFIX}
  DEPENDEES install
  DEPENDS ${SET_INSTALL_NAMES}
  WORKING_DIRECTORY ${OPENCV_PREFIX}/lib)
add_include_directory(${OPENCV_PREFIX}/include)
add_link_directory(${OPENCV_PREFIX}/lib)
set_library(opencv_bioinspired opencv_bioinspired)
set_library(opencv_calib3d opencv_calib3d)
set_library(opencv_contrib opencv_contrib)
set_library(opencv_core opencv_core)
set_library(opencv_cuda opencv_cuda)
set_library(opencv_cudaarithm opencv_cudaarithm)
set_library(opencv_cudabgsegm opencv_cudabgsegm)
set_library(opencv_cudafeatures2d opencv_cudafeatures2d)
set_library(opencv_cudafilters opencv_cudafilters)
set_library(opencv_cudaimgproc opencv_cudaimgproc)
set_library(opencv_cudaoptflow opencv_cudaoptflow)
set_library(opencv_cudastereo opencv_cudastereo)
set_library(opencv_cudawarping opencv_cudawarping)
set_library(opencv_features2d opencv_features2d)
set_library(opencv_flann opencv_flann)
set_library(opencv_highgui opencv_highgui)
set_library(opencv_imgproc opencv_imgproc)
set_library(opencv_legacy opencv_legacy)
set_library(opencv_ml opencv_ml)
set_library(opencv_nonfree opencv_nonfree)
set_library(opencv_objdetect opencv_objdetect)
set_library(opencv_ocl opencv_ocl)
set_library(opencv_optim opencv_optim)
set_library(opencv_photo opencv_photo)
set_library(opencv_shape opencv_shape)
set_library(opencv_softcascade opencv_softcascade)
set_library(opencv_stitching opencv_stitching)
set_library(opencv_superres opencv_superres)
set_library(opencv_ts opencv_ts)
set_library(opencv_video opencv_video)
set_library(opencv_videostab opencv_videostab)
add_dependencies(${OPENCV_TARGET} ${EIGEN_TARGET})
add_dependencies(${OPENCV_TARGET} ${GCC_TARGET})
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
  CONFIGURE_COMMAND ""
  BUILD_COMMAND
      PATH=${GCC_PREFIX}/bin:$ENV{PATH}
          LIB_GCC=${GCC_PREFIX}/lib/libgcc_s.1${CMAKE_SHARED_LIBRARY_SUFFIX}
          make compiler=gcc
  INSTALL_COMMAND
      mkdir -p ${OPENMP_PREFIX}/lib &&
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
add_link_directory(${OPENMP_PREFIX}/lib)
add_include_directory(${OPENMP_PREFIX}/include)
set_library(openmp iomp5)
set(OPENMP_COMPILE_FLAG "-fopenmp")
add_dependencies(${OPENMP_TARGET} ${GCC_TARGET})
add_dependencies(${OPENMP_TARGET} ${CLANG_OMP_TARGET})

################################################################################
# OpenSSL.
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
  CONFIGURE_COMMAND
      ./Configure darwin64-x86_64-cc --prefix=${OPENSSL_PREFIX} shared
          zlib-dynamic
  BUILD_IN_SOURCE 1)
add_include_directory(${OPENSSL_PREFIX}/include)
add_link_directory(${OPENSSL_PREFIX}/lib)
set_library(openssl crypto ssl)

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
# protobuf - Google's Protocol Buffers.
add_external_project(
  ${PROTOBUF_TARGET}
  PREFIX ${PROTOBUF_PREFIX}
  DOWNLOAD_COMMAND
      ${SVN} export --force http://protobuf.googlecode.com/svn/trunk/ ${PROTOBUF_TARGET}
  CONFIGURE_COMMAND
      ./autogen.sh &&
      ./configure --prefix=${PROTOBUF_PREFIX} CC=${CMAKE_C_COMPILER}
          CXX=${CMAKE_CXX_COMPILER} CFLAGS=${CMAKE_C_FLAGS}
          CXXFLAGS=${CMAKE_CXX_FLAGS} LDFLAGS=-Wc,${CMAKE_SHARED_LINKER_FLAGS}
  BUILD_IN_SOURCE 1)
add_external_project_step(${PROTOBUF_TARGET} build_python_runtime
  COMMAND /usr/bin/env python setup.py build
  DEPENDER install
  DEPENDEES build
  WORKING_DIRECTORY <SOURCE_DIR>/python)
add_external_project_step(${PROTOBUF_TARGET} install_python_runtime
  COMMAND /usr/bin/env python setup.py install
  DEPENDEES install
  WORKING_DIRECTORY <SOURCE_DIR>/python)
add_include_directory(${PROTOBUF_PREFIX}/include)
add_link_directory(${PROTOBUF_PREFIX}/lib)
add_dependencies(${PROTOBUF_TARGET} ${VIRTUALENV_TARGET})
set_library(protobuf protobuf)
# This is required for protobuf_generate_* rules.
set(PROTOBUF_PROTOC_EXECUTABLE ${PROTOBUF_PREFIX}/bin/protoc)

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
      --enable-shared
      CC=${CMAKE_C_COMPILER}
      CXX=${CMAKE_CXX_COMPILER}
      CFLAGS=${CMAKE_C_FLAGS}
      CXXFLAGS=${CMAKE_CXX_FLAGS}
  BUILD_COMMAND make shared
  INSTALL_COMMAND make install)
add_include_directory(${READLINE_PREFIX}/include)
add_link_directory(${READLINE_PREFIX}/lib)
set_library(readline readline)

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
      BOOST_ROOT=${BOOST_PREFIX} cmake <SOURCE_DIR>
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
add_link_directory(${SHARK_PREFIX}/lib)
set_library(shark shark)
add_definitions(-DSHARK_USE_OPENMP)

# Adds dependencies.
add_dependencies(${SHARK_TARGET} ${BOOST_TARGET})
add_dependencies(${SHARK_TARGET} ${OPENMP_TARGET})
append_library(shark boost_serialization)

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
      mkdir -p ${TBB_PREFIX}/lib &&
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
add_link_directory(${TBB_PREFIX}/lib)
set_library(tbb tbb)

################################################################################
# virtualenv.
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
  CONFIGURE_COMMAND mkdir -p ${VIRTUALENV_PREFIX}/lib/python/
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
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=${ZLIB_PREFIX}
  BUILD_COMMAND make
  INSTALL_COMMAND make install
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
      DEPENDS ${PROTOBUF_TARGET} ${ABS_FIL}
      COMMENT "Running C++ protocol buffer compiler on ${FIL}"
      VERBATIM)
  endforeach()

  set_source_files_properties(${${SRCS}} ${${HDRS}} PROPERTIES GENERATED TRUE)
  set(${SRCS} ${${SRCS}} PARENT_SCOPE)
  set(${HDRS} ${${HDRS}} PARENT_SCOPE)
endfunction()

function(protobuf_generate_java SRCS)
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
      DEPENDS ${PROTOBUF_TARGET} ${ABS_FIL}
      COMMENT "Running java protocol buffer compiler on ${FIL}"
      VERBATIM)
  endforeach()

  set_source_files_properties(${${SRCS}} PROPERTIES GENERATED TRUE)
  set(${SRCS} ${${SRCS}} PARENT_SCOPE)
endfunction()

function(protobuf_generate_py SRCS)
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
      DEPENDS ${PROTOBUF_TARGET} ${ABS_FIL}
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
      COMMENT "Running Bison on ${LEX}"
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
