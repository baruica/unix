#
#   cut         used to select one or more fields or groups of characters from an input file,
#               presumably for further processing within a pipeline
#
#       cut -c list [ file ... ]
#       cut -f list [ -d delim ] [ file ... ]
#
#   -c list     Cut based on characters. list is a comma-separated list of character numbers or ranges, such as 1,3,5-12,42.
#   -d delim    Use delim as the delimiter. The default delimiter is the tab character.
#   -f list     Cut based on fields. list is a comma-separated list of field numbers or ranges.
#

cut -d : -f 1,5 /etc/passwd     # camus:Albert Camus (1st and 5th fields)
cut -d : -f 6 /etc/passwd       # /home/camus (6th field)
ls -l | cut -c 1-10             # to pull out just the permissions field from ls -l
