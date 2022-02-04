#
#   Printing support in UNIX evolved into 2 camps with differing commands but equivalent functionality.
#   Commercial UNIX systems and GNU/Linux usually support both camps, whereas BSD systems offer only the Berkeley style.
#   POSIX specifies only the lp command.
#
#    Berkeley | System V |  Purpose
#   ----------|----------|--------------------------------
#    lpr      | lp       |  Send files to print queue
#    lprm     | cancel   |  Remove files from print queue
#    lpq      | lpstat   |  Report queue status
#
#   System management can make a particular single queue the system default so that queue names need not be supplied.
#   Individual users can set an environment variable, PRINTER (Berkeley) or LPDEST (System V), to select a personal default printer.
#

#
#   Berkeley
#
lpr -Plcb102 sample.ps      # send PostScript file to print queue lcb102

lpq -Plcb102                # ask for print queue status
# lcb102 is ready and printing
# Rank      Owner   Job     File(s)     Total Size
# active    jones   81352   sample.ps   122888346 bytes

lprm -Plcb102 81352         # cancel using the job number

#
#   System V
#
lp -d lcb102 sample.ps      # send PostScript file to print queue lcb102
# request id is lcb102-81355 (1 file(s))

lpstat -t lcb102            # ask for print queue status
# printer lcb102 now printing lcb102-81355

cancel lcb102-81355         # cancel using the request id
cancel printer_name         # cancel whatever was printing on printer_name



#
#   pr          formats and paginates text for printing
#
#   -cn         produce n-column output
#   -h althdr   use the string althdr to replace the filename in the page header
#   -ln         produce n-line pages (default is 66). Some implementations include page header and trailer lines, whereas others don't
#   -on         offset output lines with n spaces
#   -t          suppress page headers
#   -wn         produce lines of at most n characters (width)
#
pr my_file | lp                                         # add a title (default is filename and last modified date)

pr -f -l60 -o10 -w65 my_file | lp                       # 60 lines long, offset of 10 with a width of 65

sed -n -e 19000,19025p /usr/dict/words | pr -c5 -t      # 26 words into 5 colomns
# reproach      repugnant     request       reredos       resemblant
# reptile       repulsion     require       rerouted      resemble
# reptilian     repulsive     requisite     rerouting     resent
# republic      reputation    requisition   rescind       resentful
# republican    repute        requited      rescue        reserpine
# repudiate
