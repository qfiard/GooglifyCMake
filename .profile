# If the DEV_ROOT environment variable is set, use it for DEV_ROOT instead of
# guessing DEV_ROOT based on the location of this file.
# Useful if several projects include the same GooglifyCMake repository.
if [ -z $DEV_ROOT ]; then
  export DEV_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

# build-all recursively builds all the module in the current build directory.
# It must be called from within a build folder.
# Depends on list-all-targets.
alias build-all='list-all-targets | while read target; do echo "Building $target..."; make $target 2>&1 || echo $target 1>&2; done'
# buildify-all recursively prettifies all the CMakeLists.txt in the current
# source directory to make them conform to the syntax of GooglifyCMake.
alias buildify-all='find . -name "CMakeLists.txt" -exec sh -c "buildifier -f {}" \;'
# clang-format-all recursively applies clang-format to all the source code files
# in the current source directory. clang-format must be install on the machine
# for this to work.
alias clang-format-all='find . \( -name "*.h" -o -name "*.c" -o -name "*.cc" -o -name "*.m" -o -name "*.mm" -o -name "*.cpp" -o -name "*.hpp" \) -exec sh -c "clang-format -style=Google {} > {}.new && mv {}.new {}" \;'
# dev changes the current directory to DEV_ROOT.
alias dev="cd $DEV_ROOT"
# list-all-targets lists all the non third-party targets in the current build
# folder.
alias list-all-targets='make help|grep "\.\.\. "|sed "s/\.\.\. //g"|grep "\."|grep -v "third_party"'
# Return from build.
# When in a subdirectory $DEV_ROOT/build_*/src/some/module, rfb changes the
# current directory to $DEV_ROOT/src/some/module, the source directory
# of the module some.module.
alias rfb='dir=`echo \`pwd\`|sed "s@\($DEV_ROOT\)/build\(.*\)@\1\2@"`; cd $dir'
# To build.
# When in a subdirectory $DEV_ROOT/src/some/module, tb changes the
# current directory to $DEV_ROOT/build/src/some/module, the default build
# directory of the module some.module.
alias tb='dir=`echo \`pwd\`|sed "s@\($DEV_ROOT\)\(.*\)@\1/build\2@"`; cd $dir'

# A few PATH addition to some third-party binaries and tools.
# Feel free to add your own!
export PATH=$DEV_ROOT/build/src/tools/buildifier:$PATH
export PATH=$DEV_ROOT/build/third_party/bsdiff/bin:$PATH
export PATH=$DEV_ROOT/build/third_party/gcc/bin:$PATH
export PATH=$DEV_ROOT/build/third_party/maven/bin:$PATH
export PATH=$DEV_ROOT/build/third_party/mpich/bin:$PATH
export PATH=$DEV_ROOT/build/third_party/virtualenv/lib/python:$PATH
export PATH=/usr/local/ntp/bin:$PATH
export PYTHONPATH=$DEV_ROOT/build/third_party/virtualenv/lib/python:$PYTHONPATH

export VIRTUAL_ENV_DISABLE_PROMPT=1
VIRTUALENV_ACTIVATION_SCRIPT=\
$DEV_ROOT/build/third_party/virtualenv/env/bin/activate
if [ -f $VIRTUALENV_ACTIVATION_SCRIPT ]; then
  source $DEV_ROOT/build/third_party/virtualenv/env/bin/activate
fi
