# Include guard.
if (DEFINED THIRD_PARTY_PIP_LIBRARIES_CMAKE_)
  return()
endif ()
set(THIRD_PARTY_PIP_LIBRARIES_CMAKE_ TRUE)

function(pip_library LIB)
  set(FULL_NAME third_party.pip.${LIB})
  set(${FULL_NAME} "dummy" PARENT_SCOPE)  # No link occurs in python case.
  set(TARGET ${FULL_NAME}_target)
  set(${TARGET} ${TARGET} PARENT_SCOPE)
  add_custom_target(${TARGET})
  add_dependencies(${TARGET} ${VIRTUALENV_TARGET})
  add_custom_command(
    TARGET ${TARGET} POST_BUILD
    COMMAND ${ARGN} /usr/bin/env pip install "${LIB}" >/dev/null
    DEPENDS ${VIRTUALENV_TARGET})
endfunction(pip_library)

pip_library(
    Pillow CC=/usr/bin/gcc
    ARCHFLAGS=-Wno-error=unused-command-line-argument-hard-error-in-future)
pip_library(PyTrie)
pip_library(beautifulsoup4)
pip_library(cssselect)
pip_library(django)
pip_library(marisa-trie CC=/usr/bin/gcc CXX=/usr/bin/g++)
pip_library(numpy CC=/usr/bin/gcc)
pip_library(psd-tools)
pip_library(pycountry)
pip_library(python-gflags)
pip_library(requests)
pip_library(scikit-learn CC=/usr/bin/gcc CXX=/usr/bin/g++)
pip_library(scipy CC=/usr/bin/gcc CXX=/usr/bin/g++)
