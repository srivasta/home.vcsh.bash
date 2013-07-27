#! /bin/bash
# Startup file for bash login shells.
#
export default_dir=${default_dir:=$HOME}
export default_bashdir=${default_bashdir:=$default_dir/etc/shells/bash}

if [ -f $default_bashdir/bash_profile ]; then
    . $default_bashdir/bash_profile
elif test -f ~/etc/bash/bash_profile ; then
        . ~/etc/bash/bash_profile
fi
