#
#   printf      to produce output from shell scripts
#               Since printf's behavior is defined by the POSIX standard, scripts that use it can be more portable than those that use echo.
#
#       printf format [ string ... ]
#
#   printf uses the format string to control the output.
#   Plain characters in the string are printed.
#   Escape sequences as described for echo are interpreted.
#   Format specifiers consisting of % and a letter direct formatting of corresponding argument strings.
#

#
#   ESCAPE SEQUENCES
#
#   \a      Alert character, usually the ASCII BEL character
#   \b      Backspace
#   \c      Suppress any final newline in the output. Furthermore, any characters left in the argument, any following arguments, and any characters left in the format string are ignored (not printed)
#   \f      Formfeed
#   \n      Newline
#   \r      Carriage return
#   \t      Horizontal tab
#   \v      Vertical tab
#   \       A literal backslash character
#   \ddd    Character represented as a 1- to 3-digit octal value. Valid only in the format string
#   \0ddd   Character represented as a 1- to 3-digit octal value
#

#
#   FORMAT SPECIFIERS
#
#   %b      The corresponding argument is treated as a string containing escape sequences to be processed
#   %c      ASCII character. Print the first character of the corresponding argument
#   %d, %i  Decimal integer
#   %e      Floating-point format ([-]d.precisione[+-]dd)
#   %E      Floating-point format ([-]d.precisionE[+-]dd)
#   %f      Floating-point format ([-]ddd.precision)
#   %g      %e or %f conversion, whichever is shorter, with trailing zeros removed
#   %G      %E or %f conversion, whichever is shorter, with trailing zeros removed
#   %o      Unsigned octal value
#   %s      String
#   %u      Unsigned decimal value
#   %x      Unsigned hexadecimal number. Use a-f for 10 to 15
#   %X      Unsigned hexadecimal number. Use A-F for 10 to 15
#   %%      Literal %
#

#
#   By default, escape sequences are treated specially only in the format string.
#   Escape sequences appearing in argument strings are not interpreted
#
printf "a string, no processing: <%s>\n" "A\nB"
# a string, no processing: <A\nB>

#
#   When the %b format specifier is used, printf does interpret escape sequences in argument strings
#
printf "a string, with processing: <%b>\n" "A\nB"
# a string, with processing: <A
# B>


#
#   printf can be used to specify the width and alignment of output fields.
#   To accomplish this, a format expression can take 3 optional modifiers following the % and preceding the format specifier:
#
#       %flags width.precision format-specifier
#
#   The width of the output field is a numeric value.
#   When you specify a field width, the contents of the field are right-justified by default.
#   You must specify a flag of - to get left justification.
#
#       "%-20s" outputs a left-justified string in a field 20 characters wide
#
#   If the string is less than 20 characters, the field is padded with spaces to fill.
#
printf "|%10s|\n" hello                     # |     hello|
printf "|%-10s|\n" hello                    # |hello     |

#
#   The precision modifier is optional.
#   For decimal or floating-point values, it controls the number of digits that appear in the result.
#   For string values, it controls the maximum number of characters from the string that will be printed.
#   The precise meaning varies by format specifier:
#
#   %d, %i, %o, %u, %x, %X      The minimum number of digits to print
#                               When the value has fewer digits, it is padded with leading zeros
#                               The default precision is 1
#   %e, %E      The minimum number of digits to print
#               When the value has fewer digits, it is padded with zeros after the decimal point
#               The default precision is 6. A precision of 0 inhibits printing of the decimal point
#   %f          The number of digits to the right of the decimal point
#   %g, %G      The maximum number of significant digits
#   %s          The maximum number of characters to print
#
printf "%.5d\n" 15                          # 00015
printf "%.10s\n" "a very long string"       # a very lon
printf "%.2f\n" 123.4567                    # 123.46


# POSIX doesn't allow dynamic width and precision specification via additional values in the argument list, but ksh93 and bash do
# POSIX
width=5
prec=6
myvar=42.123456
printf "|%${width}.${prec}G|\n" $myvar      # |42.1235|

# ksh93 and bash
printf "|%*.*G|\n" 5 6 $myvar               # |42.1235|


#
#   FLAGS
#
#   -       Left-justify the formatted value within the field
#   space   Prefix positive values with a space and negative values with a minus
#   +       Always prefix numeric values with a sign, even if the value is positive
#   #       Use an alternate form:
#               %o has a preceding 0
#               %x and %X are prefixed with 0x and 0X, respectively
#               %e, %E, and %f always have a decimal point in the result
#               %g and %G do not have trailing zeros removed
#   0       Pad output with zeros, not spaces. This happens only when the field width is wider than the converted result.
#           In the C language, this flag applies to all output formats, even nonnumeric ones.
#           For the printf command, it applies only to the numeric formats
#
printf "|%-10s| |%10s|\n" hello world       # |hello     | |     world|
printf "|% d| |% d|\n" 15 -15               # | 15| |-15|
printf "%+d %+d\n" 15 -15                   # +15 -15
printf "%x %#x\n" 15 15                     # f 0xf
printf "%05d\n" 15                          # 00015
