#
#   grep        g/re/p (ed command: globally match re and print it) prints lines of text that match one or more patterns
#
#       grep pattern(s) file(s)
#
#   -c              print only the count of matching lines
#   -f pat-file     read patterns from pat-file
#   -i              ignore lettercase when doing pattern matching
#   -l              list the names of files that match the pattern instead of printing the matching lines
#   -n              print the matched line and its line number
#   -v              print lines that don't match the pattern
#
grep "C\.I\.A\." *          # searches for C.I.A. everywhere
grep '[x' some_file         # if searching for text that contains special characters, put '' around the text
grep '^[abc]' some_file     # lines starting with either a, b or c
grep '^[^0-9]' some_file    # lines not starting with a number
grep 'abc.$' some_file      # lines ending with abc and any character

grep "1417 Arcadia" *
# ts.doc: 1417 Arcadia lane
# tonia.letter: 1417 Arcadia La.

grep -l "1417 Arcadia" *
# ts.doc
# tania.letter


grep -i '^s.*m.*b' /usr/dict/words
# salmonberry
# samba
# sawtimber
# scramble
