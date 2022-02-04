# A problem that frequently arises in text processing is determining whether the contents of 2 or more files are the same, even if their names differ.


#
#   cmp         (compare) file comparison utility works for if you have just 2 candidates
#               cmp is silent when its 2 argument files are identical.
#
cp /bin/ls /tmp                             # make a private copy of /bin/ls
cmp /bin/ls /tmp/ls                         # compare the original with the copy
#                                           no output means that the files are identical

cmp /bin/cp /bin/ls                         # compare different files
# /bin/cp /bin/ls differ: char 27, line 1   Output identifies the location of the first difference

# If you are interested only in its exit status, you can suppress the warning message with the -s option:
cmp -s /bin/cp /bin/ls                      # compare different files silently
echo $?                                     # display the exit code
# 1                                         nonzero value means that the files differ


#
#   diff        reports the differences between 2 similar files
#               Difference lines prefixed by a left angle bracket (<) correspond to the left (first) file,
#               and those prefixed by a right angle bracket (>) come from the right (second) file.
#               The line preceding the differences is a compact representation of the input file line numbers where the difference occurred,
#               and the operation needed to make the edit:
#                   a means add
#                   c means change
#                   d means delete
#
echo Test 1 > sample.1                      # create first sample file
echo Test 2 > sample.2                      # create second sample file
diff sample.[12]                            # compare the 2 files
# 1c1
# < Test 1
# ---
# > Test 2


#
#   comm        compares 2 sorted files and selects, or rejects, lines common to both
#               Reads the 2 files line by line.
#               The input files must be sorted.
#               Produce 3 columns of output:
#                   lines that are only in file1,
#                   lines that are only in file2,
#                   and lines that are in both files.
#               Either filename can be -, in which case comm reads standard input.
#
#       comm [ options ... ] file1 file2
#
#   -1  Do not print column one (lines unique to file1).
#   -2  Do not print column two (lines unique to file2).
#   -3  Do not print column three (lines common to both files).
#

# Original Unix spellchecking prototype
# We assume the argument syntax for the GNU version of the tr command.
prepare filename |                          # prepare is a filter that strips whatever document markup is present; in the simplest case, it is just cat
    tr A-Z a-z |                            # map uppercase to lowercase
        tr -c a-z '\n' |                    # remove punctuation
            sort |                          # put words in alphabetical order
                uniq |                      # remove duplicate words
                    comm -13 dictionary -   # outputs only lines from the second file (the piped input) that are not in the first file (the dictionary)


#
#   patch       uses the output of diff and either of the original files to reconstruct the other one.
#               patch applies as many of the differences as it can; it reports any failures for you to handle manually.
#
# Here is how patch can convert the contents of test.1 to match those of test.2:
diff -c sample.[12] > sample.dif            # save a context difference in sample.dif
patch < sample.dif                          # apply the differences
# patching file sample.1
cat sample.1                                # show the patched sample.1 file
# Test 2


#
#   CHECKSUMS
#
# If you have lots of files that you suspect have identical contents, using cmp or diff would require comparing all pairs of them,
# leading to an execution time that grows quadratically in the number of files, which is soon intolerable.
#
# You can get nearly linear performance by using file checksums.
# There are several utilities for computing checksums of files and strings,
# including sum, cksum and checksum,
# the message-digest tools md5 and md5sum,
# and the secure-hash algorithm tools sha, sha1sum, sha256 and sha384.
# Regrettably, implementations of sum differ across platforms, making its output useless for comparisons of checksums of files on different flavors of Unix.

md5sum /bin/l?
# 696a4fa5a98b81b066422a39204ffea4  /bin/ln
# cd6761364e3350d010c834ce11464779  /bin/lp
# 351f5eab0baa6eddae391f84d0a6c192  /bin/ls

# The long hexadecimal signature string is just a many-digit integer that is computed from all of the bytes of the file in such a way as to make it unlikely that any other byte stream could produce the same value.
# With good algorithms, longer signatures in general mean greater likelihood of uniqueness.
# The md5sum output has 32 hexadecimal digits, equivalent to 128 bits.

# To find matches in a set of signatures, use them as indices into a table of signature counts, and report just those cases where the counts exceed one.


# Here is what the output of show-identical-files.sh looks like on a GNU/Linux system:
show-identical-files /bin/*
# ...
# 2df30875121b92767259e89282dd3002  /bin/ed
# 2df30875121b92767259e89282dd3002  /bin/red
# ...
# 43252d689938f4d6a513a2f571786aa1  /bin/awk
# 43252d689938f4d6a513a2f571786aa1  /bin/gawk
# 43252d689938f4d6a513a2f571786aa1  /bin/gawk-3.1.0
# ...

# We can conclude, for example, that ed and red are identical programs on this system, although they may still vary their behavior according to the name that they are invoked with.
# Files with identical contents are often links to each other, especially when found in system directories.
# show-identical-files provides more useful information when applied to user directories, where it is less likely that files are links and more likely that they're unintended copies.
