#!/usr/bin/env bash
## @file A script to merge libraries from different architectures into fat
##     library files.
## @param[in] $1 Static library extension.
## @param[in] $2 Dynamic library extension.
## @param[in] $3 Output folder.
## @param[in] $4-$$# Input folders.

## Returns a list of all the libraries with the given extension in the given
## folder.
## @param[in] $1 Library extension.
## @param[in] $2 Folder.
function list_libraries() {
  cd "$2"
  find . -name "*$1"
  cd - >/dev/null
}

## Merges all libraries with the given extension by name and saves the fat
## files in the given output folder.
## @param[in] $1 Library extension.
## @param[in] $2 Output folder.
## @param[in] $3-$$# Input folders.
function merge_libs() {
  libs=(`list_libraries $1 "$3"`)
  args=("$@")
  OIFS=$IFS
  IFS="
"
  for ((i = 3; i < $#; i++)); do
    libs2=(`list_libraries $1 "${args[$i]}"`)
    libs=(`comm -12 <(echo "${libs[*]}") <(echo "${libs2[*]}")`)
  done
  IFS=$OIFS
  for lib in ${libs[@]}; do
    inputs=()
    for ((i = 2; i < $#; i++)); do
      inputs+=("${args[$i]}/$lib")
    done
    lipo -create ${inputs[@]} -o "$2/$lib"
  done
}

args=("$@")
unset args[1]
merge_libs ${args[@]}
args=("$@")
unset args[0]
merge_libs ${args[@]}
