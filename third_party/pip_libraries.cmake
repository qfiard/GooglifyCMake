# Include guard.
if (DEFINED THIRD_PARTY_PIP_LIBRARIES_CMAKE_)
  return()
endif ()
set(THIRD_PARTY_PIP_LIBRARIES_CMAKE_ TRUE)

function(pip_library LIB)
  if (NOT PYTHON_SUPPORTED)
    return()
  endif ()
  set(FULL_NAME third_party.${LIB})
  set(${FULL_NAME} "dummy" PARENT_SCOPE)  # No link occurs in python case.
  set(TARGET ${FULL_NAME}_target)
  set(${TARGET} ${TARGET} PARENT_SCOPE)
  add_custom_target(${TARGET})
  add_dependencies(${TARGET} ${VIRTUALENV_TARGET})
  add_custom_command(
    TARGET ${TARGET} POST_BUILD
    COMMAND /usr/bin/env pip install "${LIB}" >/dev/null
    DEPENDS ${VIRTUALENV_TARGET})
endfunction(pip_library)

pip_library(django)
pip_library(python-gflags)
pip_library(requests)
