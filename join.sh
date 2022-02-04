#
#   join        is used to merge records in sorted files based on a common key
#
#       join [ options ... ] file1 file2
#
#   -1 field1       specifies the fields on which to join. -1 field1 specifies field1 from file1
#   -2 field2       -2 field2 specifies field2 from file2. Fields are numbered from 1, not from 0.
#   -o file.field   Make the output consist of field field from file file.
#                   The common field is not printed unless requested explicitly.
#                   Use multiple -o options to print multiple output fields.
#   -t separator    Use separator as the input field separator instead of whitespace.
#                   This character becomes the output field separator as well.
#

### sales
# salesperson  amount
# joe 100
# jane 200
# herman 150
# chris 300
### sales

### quotas
# salesperson  quota
# joe 50
# jane 75
# herman 80
# chris 95
### quotas

# First, we need to remove comments and sort datafiles
sed '/^#/d' quotas | sort > quotas.sorted
sed '/^#/d' sales | sort > sales.sorted

join quotas.sorted sales.sorted     # combine on first key, results to standard output
rm quotas.sorted sales.sorted       # delete temporary files

# chris 95 300
# herman 80 150
# jane 75 200
# joe 50 100
