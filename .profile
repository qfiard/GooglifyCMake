export DEV_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

alias dev="cd $DEV_ROOT"
alias rfb='dir=`echo \`pwd\`|sed "s@\($DEV_ROOT\)/build\(.*\)@\1\2@"`; cd $dir'
alias tb='dir=`echo \`pwd\`|sed "s@\($DEV_ROOT\)\(.*\)@\1/build\2@"`; cd $dir'

export PATH=$DEV_ROOT/build/tools/buildifier
export PYTHONPATH=$DEV_ROOT/build/third_party/virtualenv/lib/python:$PYTHONPATH
export VIRTUAL_ENV_DISABLE_PROMPT=1

VIRTUALENV_ACTIVATION_SCRIPT=\
$DEV_ROOT/build/third_party/virtualenv/env/bin/activate
if [ -f $VIRTUALENV_ACTIVATION_SCRIPT ]; then
  source $DEV_ROOT/build/third_party/virtualenv/env/bin/activate
fi
