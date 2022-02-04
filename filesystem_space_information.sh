# With suitable options, the find and ls commands report file sizes, so with the help of a short awk program, you can report how many bytes your files occupy:
find -ls | awk '{ Sum += $7 } END { printf("Total: %.0f bytes\n", Sum) }'
# Total: 23079017 bytes

# However, that report underestimates the space used, because files are allocated in fixed-size blocks,
# and it tells us nothing about the used and available space in the entire filesystem.
# 2 other useful tools provide better solutions: df and du.


#
#   df          (disk free) gives a one-line summary of used and available space on each mounted filesystem
#               The units are system-dependent blocks on some systems, and kilobytes on others.
#
#               The output of df varies considerably between systems, making it hard to use reliably in portable shell scripts.
#               df's output is not sorted.
#               Space reports for remote filesystems may be inaccurate.
#
#       df [ options ] [ files-or-directories ]
#
#   -h  provided by GNU df, to produce a more compact, but possibly more confusing, report (human-readable)
#   -i  show inode counts rather than space
#   -k  most modern implementations support this option to force kilobyte units
#   -l  (lowercase L) to include only local filesystems, excluding network-mounted ones
#
df -k
# Filesystem      1K-blocks      Used Available  Use% Mounted on
# /dev/sda5         5036284   2135488   2644964   45% /
# /dev/sda2           38890      8088     28794   22% /boot
# /dev/sda3        10080520   6457072   3111380   68% /export
# none               513964         0    513964    0% /dev/shm
# /dev/sda8          101089      4421     91449    5% /tmp
# /dev/sda9        13432904    269600  12480948    3% /var
# /dev/sda6         4032092   1683824   2143444   44% /ww

df -h
# Filesystem           Size      Used     Avail  Use% Mounted on
# /dev/sda5            4.9G      2.1G      2.6G   45% /
# /dev/sda2             38M      7.9M       29M   22% /boot
# /dev/sda3            9.7G      6.2G      3.0G   68% /export
# none                 502M         0      502M    0% /dev/shm
# /dev/sda8             99M      4.4M       90M    5% /tmp
# /dev/sda9             13G      264M       12G    3% /var
# /dev/sda6            3.9G      1.7G      2.1G   44% /ww

# You can supply a list of one or more filesystem names or mount points to limit the output to just those:
df -lk /dev/sda6 /var
# Filesystem      1K-blocks      Used Available  Use% Mounted on
# /dev/sda6         4032092   1684660   2142608   45% /ww
# /dev/sda9        13432904    269704  12480844    3% /var

df -i
# Filesystem         Inodes     IUsed     IFree IUse% Mounted on
# /dev/sda5          640000    106991    533009   17% /
# /dev/sda2           10040        35     10005    1% /boot
# /dev/sda3         1281696    229304   1052392   18% /export
# none               128491         1    128490    1% /dev/shm
# /dev/sda8           26104       144     25960    1% /tmp
# /dev/sda9         1706880       996   1705884    1% /var
# /dev/sda6          513024    218937    294087   43% /ww

# The /ww filesystem is in excellent shape, since its inode use and filesystem space are both just over 40 percent of capacity.
# For a healthy computing system, system managers should routinely monitor inode usage on all local filesystems.


#
#   du          (disk usage) shows the space usage in one or more directory trees
#               du's output is not sorted.
#
#       du [ options ] [ files-or-directories ]
#
#   -h  provided by GNU df, to produce a more compact, but possibly more confusing, report (human-readable)
#   -k  Show space in kilobytes rather than (system-dependent) blocks.
#   -s  Show only a one-line summary for each argument.
#
du /tmp
# 12      /tmp/lost+found
# 1       /tmp/.font-unix
# 24      /tmp

du -s /tmp
# 24      /tmp

du -s /var/log /var/spool /var/tmp
# 204480  /var/log
# 236     /var/spool
# 8       /var/tmp

du -h -s /var/log /var/spool /var/tmp
# 200M    /var/log
# 236k    /var/spool
# 8.0k    /var/tmp

# du does not count extra hard links to the same file, and normally ignores soft links.
# However, some implementations provide options to force soft links to be followed, but the option names vary.

# One common problem that du helps to solve is finding out who the big filesystem users are.
# Assuming that user home-directory trees reside in /home/users, root can do this:
du -s -k /home/users/* | sort -k1nr                 # find large home directory trees
# This produces a list of the top space consumers, from largest to smallest.

find dirs -size +10000
# this command in a few of the largest directory trees can quickly locate files that might be candidates for compression or deletion,
# and the du output can identify user directory trees that might better be moved to larger quarters.
