# Include guard.
if (DEFINED THIRD_PARTY_PIP_LIBRARIES_CMAKE_)
  return()
endif ()
set(THIRD_PARTY_PIP_LIBRARIES_CMAKE_ TRUE)

function(pip_library LIB REF)
  set(FULL_NAME third_party.pip.${LIB})
  set(${FULL_NAME} "dummy" PARENT_SCOPE)  # No link occurs in python case.
  set(TARGET ${FULL_NAME}_target)
  set(${TARGET} ${TARGET} PARENT_SCOPE)
  if (NOT "$ENV{BUILD_3RD_PARTY_LIBRARIES}")
    return ()
  endif ()
  add_custom_target(${TARGET})
  add_dependencies(${TARGET} ${VIRTUALENV_TARGET})
  add_custom_command(
    TARGET ${TARGET} POST_BUILD
    COMMAND ${ARGN} /usr/bin/env pip install "${REF}" >/dev/null
    DEPENDS ${VIRTUALENV_TARGET})
endfunction(pip_library)

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
  set(BYPASS_UNUSED_ARGUMENTS -Qunused-arguments)
else ()
  set(BYPASS_UNUSED_ARGUMENTS)
endif ()

pip_library(
    Pillow Pillow CC=/usr/bin/gcc
    ARCHFLAGS=-Wno-error=unused-command-line-argument-hard-error-in-future)
pip_library(PyTrie PyTrie)
pip_library(beautifulsoup4 beautifulsoup4)
pip_library(cssselect cssselect)
pip_library(django django)
pip_library(django-nonrel git+git://github.com/django-nonrel/django)
pip_library(djangotoolbox git+git://github.com/django-nonrel/djangotoolbox)
pip_library(enum34 enum34)
pip_library(google-api-python-client google-api-python-client)
pip_library(httplib2 httplib2)
pip_library(jinja2 Jinja2)
pip_library(leveldb leveldb CC=/usr/bin/gcc CXX=/usr/bin/g++)
pip_library(lmdb lmdb CFLAGS=${BYPASS_UNUSED_ARGUMENTS}
            CPPFLAGS=${BYPASS_UNUSED_ARGUMENTS})
pip_library(lxml lxml)
pip_library(marisa-trie marisa-trie CC=/usr/bin/gcc CXX=/usr/bin/g++)
pip_library(matplotlib matplotlib CFLAGS=${BYPASS_UNUSED_ARGUMENTS}
            CPPFLAGS=${BYPASS_UNUSED_ARGUMENTS})
pip_library(mysql-python MySQL-python CFLAGS=${BYPASS_UNUSED_ARGUMENTS}
            CPPFLAGS=${BYPASS_UNUSED_ARGUMENTS})
pip_library(mongodb-engine git+git://github.com/django-nonrel/mongodb-engine)
pip_library(networkx networkx)
pip_library(numpy numpy)
pip_library(psd-tools psd-tools)
pip_library(pycountry pycountry)
pip_library(python-gflags python-gflags)
pip_library(requests requests)
pip_library(scikit-learn scikit-learn CC=/usr/bin/gcc CXX=/usr/bin/g++)
pip_library(scipy scipy CFLAGS=${BYPASS_UNUSED_ARGUMENTS}
            CPPFLAGS=${BYPASS_UNUSED_ARGUMENTS})
pip_library(watchdog watchdog CFLAGS=${BYPASS_UNUSED_ARGUMENTS})
