#! /bin/bash
export default_dir=${default_dir:=$HOME}
export default_bashdir=${default_bashdir:=$default_dir/etc/shells/bash}

if test -f $default_bashdir/bashrc ; then
  . $default_bashdir/bashrc
elif test -f $default_dir/Bashrc ; then
  . ${default_dir}/Bashrc;
elif test -f ~/etc/bash/bashrc ; then
        . ~/etc/bash/bashrc
fi
