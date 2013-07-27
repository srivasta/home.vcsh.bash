# Autoloading for shell functions.
#
# Author  : Nick Holloway <alfie@dcs.warwick.ac.uk>
# Place   : Department of Computer Science, University of Warwick, UK
# Version : 2.0
# Date    : 22nd November 1991
# Usage   :
#   To use, first source this file.  This defines two shell functions,
#   "autoload()" and "ldfn()".  The function "ldfn()" is to actually do
#   the autoloading.  The function "autoload()" is what you would want
#   to use.
#
#   They use the shell variable "$FNPATH" which is a colon separated list
#   of directories that contain the function definitions (contained in a file 
#   whose name is the function name with the suffix '.fn').
#
#   To create selected functions as autoloading functions, use the function
#   "autoload()" with the functions required as arguments. If "autoload()"
#   is invoked with no arguments, then all functions whose definitions are
#   found in "$FNPATH" are created as autoloading functions.
#
#   These two functions are written using only shell built-ins for speed.
# For example, my
# setup for functions is:
# 
#         . $HOME/bin/autoload.sh
#         FNPATH=$HOME/bin/funcs
#         autoload
# 
# The function file is just the body of the definition, stored in a file
# with ".fn" appended.  This has the advantage that you can test your
# function by doing "sh function.fn [args...]", then when it is working
# as you wish, you can type "autoload function", and it will then be
# autoloaded from then on.
# 

autoload () {
    if [ $# -gt 0 ]
    then
	for ldfn_fn in ${1+"$@"}  # autoload each function given as arguments
	do
	    eval "$ldfn_fn () {
ldfn $ldfn_fn \${1+\"\$@\"}
}"
	done
	unset ldfn_fn
    else			# look for functions to autoload in FNPATH
	OIFS="$IFS"		
	IFS=:
	for ldfn_dir in $FNPATH
	do
	    for ldfn_file in $ldfn_dir/*.fn
	    do
		# this performs "basename $ldfn_file .fn"
		set -f
		IFS=/
		set - $ldfn_file
		while [ $# -gt 1 ]; do shift; done
		IFS=.
		set - $1
		set +f
		# check it is a valid function name
		[ $# -ne 2 ] && continue
		case "$1" in
		    '' | [!a-zA-Z_]* | ?*[!a-zA-Z0-9_]* ) 
			continue;;
		esac
		autoload "$1"
	    done
	done
	IFS="$OIFS"
	unset OIFS ldfn_dir ldfn_file ldfn_fn
    fi
}

# load function from definition, and then run with arguments passed
ldfn () {
    ldfn_fn="$1"; shift
    case "$ldfn_fn" in
    '' | [!a-zA-Z_]* | ?*[!a-zA-Z0-9_]* ) 
	echo "ldfn: $ldfn_fn: is not an identifier" >&2 ;;
    *)
	ldfn_body=""
	OIFS="$IFS"
	IFS=:
	for ldfn_dir in $FNPATH
	do
	    ldfn_file="$ldfn_dir/$ldfn_fn.fn"
	    if [ -r "$ldfn_file" ] && [ -s "$ldfn_file" ]
	    then
		exec 3<"$ldfn_file"
		IFS=
		while read ldfn_line <&3
		do   ldfn_body="$ldfn_body
$ldfn_line"
		done
		exec 3<&-
		break
	    fi
	done
	IFS="$OIFS"
	if [ -z "$ldfn_body" ]
	then
	    echo "ldfn: $ldfn_fn: can't find definition to load" >&2
	else
	    eval "$ldfn_fn () {
$ldfn_body
}" ;
	   
	     $ldfn_fn ${1+"$@"} 	# actually call $fn
	fi ;;
    esac
    unset OIFS ldfn_fn ldfn_dir ldfn_file ldfn_body ldfn_line
}
