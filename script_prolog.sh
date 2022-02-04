#
#   Chet Ramey, the maintainer of bash, offers the following prolog for use in shell scripts that need to be more secure:
#
# This uses special bash and ksh93 notation, not in POSIX.
#

# Reset IFS.
# Even though ksh doesn't import IFS from the environment, $ENV could set it.
IFS=$' \t\n'

# Make sure unalias is not a function, since it's a regular built-in.
# unset is a special built-in, so it will be found before functions.
unset -f unalias

# Unset all aliases and quote unalias so it's not alias-expanded.
\unalias -a

# Make sure command is not a function, since it's a regular built-in.
# unset is a special built-in, so it will be found before functions.
unset -f command

# Get a reliable path prefix, handling case where getconf is not available.
SYSPATH="$(command -p getconf PATH 2>/dev/null)"
if [ -z "$SYSPATH" ]
then
    SYSPATH="/usr/bin:/bin"         # pick your poison
fi
PATH="$SYSPATH:$PATH"
