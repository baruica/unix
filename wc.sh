#
#   wc          (word count)
#               Although commonly used with input from a pipeline, it also accepts command-line file arguments,
#               producing a one-line report for each (lines, words, bytes), followed by a summary report.
#
echo Testing one two three | wc -c                      # 22    count bytes
# -c originally stood for character count, but with multibyte character-set encodings, such as UTF-8, in modern systems,
# bytes are no longer synonymous with characters, so POSIX introduced the -m option to count multibyte characters
echo Testing one two three | wc -m                      # 22    count characters
echo Testing one two three | wc -l                      # 1     count lines
echo Testing one two three | wc -w                      # 4     count words

wc /etc/passwd /etc/group                               # count data in 2 files
# 26     68     1631    /etc/passwd
# 10376  10376  160082  /etc/group
# 10402  10444  161713  total


#
#   word frequency
#
# Read a text stream on standard input,
# and output a list of the n (default: 25) most frequently occurring words and their frequency counts,
# in order of descending counts, on standard output.
#
# Usage:
#       wf [n]
#
tr -cs A-Za-z\' '\n' |                                  # Replace nonletters with newlines
    tr A-Z a-z |                                        # Map uppercase to lowercase
        sort |                                          # Sort the words in ascending order
            uniq -c |                                   # Eliminate duplicates, showing their counts
                sort -k1,1nr -k2 |                      # Sort by descending count, and then by ascending word
                    sed ${1:-25}q                       # Print only the first n (default: 25) lines

# the 12 most used words in hamlet
wf 12 < hamlet | pr -c4 -t -w80                         # printed in 4 columns, no header and 80 characters per line
# 1148 the    671 of     550 a       451 in
#  970 and    635 i      514 my      419 it
#  771 to     554 you    494 hamlet  407 that

# how many unique words there are in the play
wf 999999 < hamlet | wc -l                              # wf produces 1 word per line, so the number of lines is actually the number of words
# 4548

# 12 of the least frequent words
wf 999999 < hamlet | tail -n 12 | pr -c4 -t -w80        # the last 12 lines (words) produced by wf
#    1 yaw        1 yesterday   1 yielding  1 younger
#    1 yawn       1 yesternight 1 yon       1 yourselves
#    1 yeoman     1 yesty       1 yond      1 zone

# how many of the 4548 words were used just once
wf 999999 < hamlet | grep -c '^ *1·'                    # count of lines that match any number (or none) of spaces, followed by 1 and a tab
# 2634                                                    the · following the digit 1 in the grep pattern represents a tab

# the core vocabulary of frequently occurring words
wf 999999 < hamlet | awk '$1 >= 5' | wc -l              # count of lines (words) that occured more than 5 times
# 740
