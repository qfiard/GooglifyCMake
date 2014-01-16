# Include guard.
if (DEFINED THIRD_PARTY_PIP_LIBRARIES_CMAKE_)
  return()
endif ()
set(THIRD_PARTY_PIP_LIBRARIES_CMAKE_ TRUE)

function(pip_library NAME)
  set("third_party.${LIB}" "dummy")
  set(TARGET "third_party.${NAME}_target")
  add_custom_target(${TARGET})
  add_dependencies(${TARGET} ${VIRTUALENV_TARGET})
  add_custom_command(
    TARGET ${TARGET} POST_BUILD
    COMMAND /usr/bin/env pip install "${NAME}" >/dev/null
    DEPENDS ${VIRTUALENV_TARGET})
endfunction(pip_library)

pip_library(django)
pip_library(python-gflags)
pip_library(requests)
