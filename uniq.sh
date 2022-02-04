#
#   uniq        frequently used in a pipeline to eliminate duplicate records downstream from a sort operation
#
#   -c  prefixes each output line with a count of the number of times that it occurred
#   -d  shows only lines that are duplicated
#   -u  shows just the nonduplicate lines
#
cat latin-numbers
# tres
# unus
# duo
# tres
# duo
# tres

sort latin-numbers | uniq               # show unique sorted records
# duo
# tres
# unus

sort latin-numbers | uniq -c            # count unique sorted records
# 2 duo
# 3 tres
# 1 unus

sort latin-numbers | uniq -d            # show only duplicate records
# duo
# tres

sort latin-numbers | uniq -u            # show only nonduplicate records
# unus
