#
#   A function is a separate piece of code that performs some well-defined single task.
#   The function can then be used (called) from multiple places within the larger program.
#   Within a function body, the positional parameters ($1, $2, etc., $#, $*, and $@) refer to the function's arguments.
#   The parent script's arguments are temporarily shadowed, or hidden, by the function's arguments.
#   $0 remains the name of the parent script.
#   When the function finishes, the original command-line arguments are restored.
#

# wait_for_user --- wait for a user to log in
# Usage:
#       wait_for_user user [ sleeptime ]
wait_for_user()
{
    until who | grep "$1" > /dev/null
    do
        sleep ${2:-30}                  # if no sleeptime is given to the function, the default is 30
    done
}


#
#   return      returns an exit value from a shell function to the calling script
#
#       return [ exit-value ]
#
#   Note: using exit in the body of a shell function terminates the entire shell script.
#   The default exit status used if none is supplied is the exit status of the last command executed ($?).
#

# equal --- compare 2 strings
equal()
{
    case "$1" in                        # quotes are not necessary but don't hurt
    "$2")                               # the quotes force the value to be treated as a literal string, rather than as a shell pattern
        return 0                        # they match
    ;;
    esac

    return 1                            # they don't match
}

if equal "$a" "$b" ...

if ! equal "$c" "$d" ...


fatal()
{
    echo "$0: fatal error:" "$@" >&2    # messages to stderr
    exit 1
}
# same using keyword "function" (bash and ksh)
function fatal()
{
    echo "$0: fatal error:" "$@" >&2    # messages to stderr
    exit 1
}
