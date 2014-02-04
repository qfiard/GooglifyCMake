if [ -z $DEV_ROOT ]; then
  export DEV_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

alias build-all='list-all-targets | while read target; do echo "Building $target..."; make $target 2>&1 || echo $target 1>&2; done'
alias buildify-all='find . -name "CMakeLists.txt" -exec sh -c "buildifier -f {}" \;'
alias clang-format-all='find . \( -name "*.h" -o -name "*.cc" -o -name "*.m" -o -name "*.mm" \) -exec sh -c "clang-format -style=Google {} > {}.new && mv {}.new {}" \;'
alias dev="cd $DEV_ROOT"
alias list-all-targets='make help|grep "\.\.\. "|sed "s/\.\.\. //g"|grep "\."|grep -v "third_party"'
alias rfb='dir=`echo \`pwd\`|sed "s@\($DEV_ROOT\)/build\(.*\)@\1\2@"`; cd $dir'
alias sconf_edit="$DEV_ROOT/build/src/crypto/config/editor/editor_main "
alias tb='dir=`echo \`pwd\`|sed "s@\($DEV_ROOT\)\(.*\)@\1/build\2@"`; cd $dir'

export PATH=$DEV_ROOT/build/third_party/gcc/bin:$PATH
export PATH=$DEV_ROOT/build/third_party/maven/bin:$PATH
export PATH=$DEV_ROOT/build/third_party/virtualenv/lib/python:$PATH
export PATH=$DEV_ROOT/build/src/tools/buildifier:$PATH
export PATH=/usr/local/ntp/bin:$PATH
export PYTHONPATH=$DEV_ROOT/build/third_party/virtualenv/lib/python:$PYTHONPATH
export VIRTUAL_ENV_DISABLE_PROMPT=1

VIRTUALENV_ACTIVATION_SCRIPT=\
$DEV_ROOT/build/third_party/virtualenv/env/bin/activate
if [ -f $VIRTUALENV_ACTIVATION_SCRIPT ]; then
  source $DEV_ROOT/build/third_party/virtualenv/env/bin/activate
fi
LD_LIBRARY_PATHS=$DEV_ROOT/build/ld_library_paths
if [ -f "$LD_LIBRARY_PATHS" ]; then
  source $LD_LIBRARY_PATHS
fi
