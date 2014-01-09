# Include guard.
if (DEFINED THIRD_PARTY_PIP_LIBRARIES_CMAKE_)
  return()
endif ()
set(THIRD_PARTY_PIP_LIBRARIES_CMAKE_ TRUE)

pip_library(python-gflags)
pip_library(requests)
