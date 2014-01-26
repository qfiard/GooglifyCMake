#!/usr/bin/env bash
## @file A script to convert install name tools to absolute paths in dynamic
## libraries.
## @param[in] $1 install_name_tool path.
## @param[in] $2 Dynamic library extension.

## Returns a space separated list of the basenames of the libraries linked
## to a dynamic library given as input.
## @param[in] $1 Absolute path of the library to analyze.
## @param[in] $2 Dynamic library extension.
function get_linked_libraries() {
  otool -L $1 | grep -oh ".*$2"
}

libs=$(find * -type f -name "*$2")
symbolic_libs=$(find * -type f -o -type l -name "*$2")
for lib in $libs; do
  $1 -id `pwd`/$lib $lib
  linked_libraries=`get_linked_libraries $lib $2`
  for linked_lib in $linked_libraries; do
    linked_lib_name=`basename $linked_lib`
    echo $symbolic_libs | grep -c $linked_lib_name >/dev/null
    is_local_lib=$?
    if [ $is_local_lib -eq 0 -a "$lib" != "$linked_lib_name" ]; then
      $1 -change $linked_lib `pwd`/$linked_lib_name $lib
    fi
  done
done
