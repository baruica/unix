# A process is an instance of a running program.
# New processes are started by the fork() and execve() system calls, and normally run until they issue an exit() system call.
#
# Unix systems have always supported multiple processes.
# Although the computer seems to be doing several things at once, in reality, this is an illusion, unless there are multiple CPUs.
# What really happens is that each process is permitted to run for a short interval, called a time slice,
# and then the process is temporarily suspended while another waiting process is given a chance to run.
# Time slices are quite short, usually only a few milliseconds, so humans seldom notice these context switches as control is transferred from one process to the kernel and then to another process.
# Processes themselves are unaware of context switches, and programs need not be written to relinquish control periodically to the operating system.
#
# A part of the operating-system kernel, called the scheduler, is responsible for managing process execution.
# When multiple CPUs are present, the scheduler tries to use them all to handle the workload; the human user should see no difference except improved response.
#
# Processes are assigned priorities so that time-critical processes run before less important ones.
# The nice and renice commands can be used to adjust process priorities.
#
# The average number of processes awaiting execution at any instant is called the load average.
uptime                  # show uptime, user count and load averages
# 1:51pm up 298 day(s), 15:42, 32 users, load average: 3.51, 3.50, 3.55

# Because the load average varies continually, uptime reports 3 time-averaged estimates, usually for the last 1, 5 and 15 minutes.


# Each process initiated by a command shell starts with these guarantees:
# - The process has a kernel context: data structures inside the kernel that record process-specific information to allow the kernel to manage and control process execution.
# - The process has a private, and protected, virtual address space that potentially can be as large as the machine is capable of addressing.
# - 3 file descriptors (stdin, stdout and stderr) are already open and ready for immediate use.
# - A process started from an interactive shell has a controlling terminal, which serves as the default source and destination for the 3 standard file streams.
# - Wildcard characters in command-line arguments have been expanded.
# - An environment-variable area of memory exists, containing strings with key/value assignments that can be retrieved by a library call (getenv() in C).
#
# These guarantees are nondiscriminatory: all processes at the same priority level are treated equally and may be written in any convenient programming language.
#
# The private address space ensures that processes cannot interfere with one another, or with the kernel.
# Operating systems that do not offer such protection are highly prone to failure.
#
# The 3 already-open files suffice for many programs, which can use them without the burden of having to deal with file opening and closing,
# and without having to know anything about filename syntax, or filesystems.
#
# Wildcard expansion by the shell removes a significant burden from programs and provides uniform handling of command lines.
#
# The environment space provides another way to supply information to processes, beyond their command lines and input files.


#
#   ps          (process status) lists the running processes
#
#   -e  every process in the entire system
#   -f  full listing        UID (User ID)  PID  PPID (Parent PID)  C  STIME  TTY  TIME  TIME  CMD
#   -l  long listing shows more details, inculding NI (nice value)
#   -u  the processes for one particular user
#
ps                                      # PID (Process ID)  TTY (terminal name)  TIME (run time)  CMD (command)
#   PID  TTY     TIME  CMD
#  2659  pts/60  0:00  ps
#  5026  pts/60  0:02  ksh
# 12369  pts/92  0:02  bash

ps -efl
#  F S  UID PID PPID C PRI NI ADDR  SZ WCHAN STIME  TTY    TIME CMD
# 19 T root   0    0 0   0 SY    ?   0       Dec 27 ?      0:00 sched
#  8 S root   1    0 0  41 20    ? 106     ? Dec 27 ?      9:53 /etc/init -
# 19 S root   2    0 0   0 SY    ?   0     ? Dec 27 ?      0:18 pageout
# 19 S root   3    0 0   0 SY    ?   0     ? Dec 27 ?   2852:26 fsflush
# ...

ps -fu mike                             # full listing of mike's processes


# 4 keyboard characters (settable with stty command options) interrupt foreground processes:
#   Ctrl-C (intr: kill),
#   Ctrl-Y (dsusp: suspend, but delay until input is flushed),
#   Ctrl-Z (susp: suspend),
#   Ctrl-\ (quit: kill with core dump).


#
#   cmd &       Execute cmd in the background (returns [job_number] followed by the PID)
#               The job_number is given by the shell to each process running in the background,
#               whereas the PID is given by the OS to all the processes running on the entire system.
#               When putting a series of commands separated by semicolons into the background,
#               the Bourne shell puts only the last command on the line into the background, but waits for the first
#
nroff some_file > some_file.txt &       # formats some_file in the background
sleep 15; ls &                          # ls will be executed in the background after 15 seconds
(sleep 15; ls)&                         # use the () to put a series of commands in the background
sort bigfile > bigfile.sorted &         # runs this command in the background, returns [job_number] and the PID


#
#   bg          (background)
#   fg          (foreground)
#
sort hugefile1 hugefile2 > sorted       # start a long process
bg                                      # puts the sorting process in the background
# [1] sort hugefile1 hugefile2 > sorted &
mail eduardo@nacional.cl                # now we can do something else while the sorting process is running in the background
fg                                      # brings the sorting process back to the foreground


#
#   nice        lets you run a command at a lower (higher nice value) or higher (lower nice value) priority
#
nice genreport Tuesday.raw &            # nice tells genreport to run with an increased niceness of 10 by default
nice -8 genreport Tuesday.raw &         # we specify nice to add 8 to the niceness of genreport


# Well-behaved processes ultimately complete their work and terminate with an exit() system call.
# Sometimes, however, it is necessary to terminate a process prematurely, perhaps because it was started in error, requires more resources than you care to spend, or is misbehaving.

#
#   kill        sends a signal to running processes
#               A process that receives a signal cannot tell where it came from.
#
#       kill [ -s { SignalName | SignalNumber } ] PID ...
#       kill [ - SignalName | - SignalNumber ] PID ...
#
#   -l [ ExitStatus ]   to list signal names
#
kill -l 6
# ABRT

kill -l                                 # signal names supported by AIX 4.3
#  1) HUP           14) ALRM            27) MSG                 40) bad trap            53) bad trap
#  2) INT           15) TERM            28) WINCH               41) bad trap            54) bad trap
#  3) QUIT          16) URG             29) PWR                 42) bad trap            55) bad trap
#  4) ILL           17) STOP            30) USR1                43) bad trap            56) bad trap
#  5) TRAP          18) TSTP            31) USR2                44) bad trap            57) bad trap
#  6) ABRT          19) CONT            32) PROF                45) bad trap            58) bad trap
#  7) EMT           20) CHLD            33) DANGER              46) bad trap            59) CPUFAIL
#  8) FPE           21) TTIN            34) VTALRM              47) bad trap            60) GRANT
#  9) KILL          22) TTOU            35) MIGRATE             48) bad trap            61) RETRACT
# 10) BUS           23) IO              36) PRE                 49) bad trap            62) SOUND
# 11) SEGV          24) XCPU            37) bad trap            50) bad trap            63) SAK
# 12) SYS           25) XFSZ            38) bad trap            51) bad trap
# 13) PIPE          26) bad trap        39) bad trap            52) bad trap

# Uncaught signals generally cause termination, although STOP and TSTP normally just suspend the process until a CONT signal requests that it continues execution.
# You might use STOP and CONT to delay execution of a legitimate process until a less-busy time:
kill -STOP 17787                        # suspend process
sleep 36000 && kill -CONT 17787 &       # resume process in 10 hours

# For deleting processes, it is important to know about only 4 signals:
#   ABRT    (abort)
#   HUP     (hangup)
#   KILL
#   TERM    (terminate)
# Some programs prefer to do some cleanup before they exit: they generally interpret a TERM signal to mean clean up quickly and exit.
# kill sends that signal if you do not specify one.
# ABRT is like TERM, but may suppress cleanup actions, and may produce a copy of the process memory image in a core, program.core or core.PID file.

# The HUP signal similarly requests termination, but with many daemons, it often means that the process should stop what it is doing,
# and then get ready for new work, as if it were freshly started.
# For example, after you make changes to a configuration file, a HUP signal makes the daemon reread that file.

# The 2 signals that no process can catch or ignore are KILL and STOP. These 2 signals are always delivered immediately.

# When multiple signals are sent, the order of their delivery, and whether the same signal is delivered more than once, is unpredictable.
# The only guarantee that some systems provide is that at least one of the signals is delivered.
# There is such wide variation in signal handling across Unix platforms that only the simplest use of signals is portable.

kill -HUP 25094                         # As a rule, you should give the process a chance to shut down gracefully by sending it a HUP signal first;
kill -TERM 25094                        # if that does not cause it to exit shortly, then try the TERM signal;
kill -KILL 25094                        # If that still does not cause exit, use the last-resort KILL signal.

# Processes register with the kernel those signals that they wish to handle.
# They specify in the arguments of the signal() library call whether the signal should be caught, should be ignored, or should terminate the process, possibly with a core dump.
# To free most programs from the need to deal with signals, the kernel itself has defaults for each signal.

# on a Sun Solaris system:
man -a signal                           # look at all manual pages for signal
# ...
#      Name             Value   Default    Event
#      SIGHUP           1       Exit       Hangup (see termio(7I))
#      SIGINT           2       Exit       Interrupt (see termio(7I))
#      SIGQUIT          3       Core       Quit (see termio(7I))
# ...
#      SIGABRT          6       Core       Abort
# ...
#      SIGFPE           8       Core       Arithmetic Exception
# ...
#      SIGPIPE          13      Exit       Broken Pipe
# ...
#      SIGUSR1          16      Exit       User Signal 1
#      SIGUSR2          17      Exit       User Signal 2
#      SIGCHLD          18      Ignore     Child Status Changed
# ...

# The trap command causes the shell to register a signal handler to catch the specified signals.
# trap takes a string argument containing a list of commands to be executed when the trap is taken, followed by a list of signals for which the trap is set.

### looper.sh
trap 'echo Ignoring HUP ...' HUP                        # simply reports that the HUP signal was received
trap 'echo Terminating on USR1 ... ; exit 1' USR1       # reports a USR1 signal and exits

while true
do
    sleep 2
    date >/dev/null
done
### looper.sh

./looper &                              # run looper in the background
# [1]     24179

kill -HUP 24179                         # send looper a HUP signal
# Ignoring HUP ...

kill -USR1 24179                        # send looper a USR1 signal
# Terminating on USR1 ...
# [1] +  Done(1)         ./looper &

# Now let's try some other signals:
./looper &
# [1]     24286

kill -CHLD 24286

# Is looper still running?
jobs
# [1] +  Running         ./looper &

kill -FPE 24286
# [1] + Arithmetic Exception(coredump)./looper &

./looper &
# [1]     24395

kill -PIPE 24395
# [1] + Broken Pipe      ./looper &

# Notice that the CHLD signal did not terminate the process; it is one of the signals whose kernel default is to be ignored.
# By contrast, the floating-point exception (FPE) and broken pipe (PIPE) signals that we sent are among those that cause process termination.

./looper &
# [1]     24621

kill 24621                              # send looper the default signal, TERM
# [1] +  Done(208)       ./looper &


# The value of the exit status $? on entry to the EXIT trap is preserved on completion of the trap, unless an exit in the trap resets its value.
# bash, ksh and zsh provide 2 more signals for trap: DEBUG traps at every statement, and ERR traps after statements returning a nonzero exit code.
# The DEBUG trap is quite tricky, however: in ksh88, it traps after the statement, whereas in later shells, it traps before.
# The public-domain Korn shell implementation available on several platforms does not support the DEBUG trap at all.

### debug-trap
trap 'echo This is an EXIT trap' EXIT
trap 'echo This is a DEBUG trap' DEBUG
pwd
pwd
### debug-trap

# Now supply this script to several different shells on a Sun Solaris system:
/bin/sh debug-trap                      # try the Bourne shell
# debug-trap: trap: bad trap
# /tmp
# /tmp
# This is an EXIT trap

/bin/ksh debug-trap                     # try the 1988 (i) Korn shell
# /tmp
# This is a DEBUG trap
# /tmp
# This is a DEBUG trap
# This is an EXIT trap

/usr/xpg4/bin/sh debug-trap             # try the POSIX shell (1988 (i) Korn shell)
# /tmp
# This is a DEBUG trap
# /tmp
# This is a DEBUG trap
# This is an EXIT trap

/usr/dt/bin/dtksh debug-trap            # try the 1993 (d) Korn shell
# This is a DEBUG trap
# /tmp
# This is a DEBUG trap
# /tmp
# This is a DEBUG trap
# This is an EXIT trap

/usr/local/bin/ksh93 debug-trap         # try the 1993 (o+) Korn shell
# This is a DEBUG trap
# /tmp
# This is a DEBUG trap
# /tmp
# This is a DEBUG trap
# This is an EXIT trap

/usr/local/bin/bash debug-trap          # try the GNU Bourne-Again shell
# This is a DEBUG trap
# /tmp
# This is a DEBUG trap
# /tmp
# This is a DEBUG trap
# This is an EXIT trap

/usr/local/bin/pdksh debug-trap         # try the public-domain Korn shell
# debug-trap[2]: trap: bad signal DEBUG

/usr/local/bin/zsh debug-trap           # try the Z-shell
# This is a DEBUG trap
# /tmp
# This is a DEBUG trap
# /tmp
# This is a DEBUG trap
# This is an EXIT trap
# This is a DEBUG trap

# Older versions of bash and ksh may behave differently in these tests.
# This variation in behavior for the DEBUG trap is problematic, but it is unlikely that you need that trap in portable shell scripts.


# The ERR trap also has a surprise: command substitutions that fail do not trap.

### err-trap
#!/bin/ksh -
trap 'echo This is an ERR trap.' ERR
echo Try cmd substitution: $(ls no-such-file)
echo Try a standalone cmd:
ls no-such-file
### err-trap

./err-trap                              # run the test program
# ls: no-such-file: No such file or directory
# Try cmd substitution:
# Try a standalone cmd:
# ls: no-such-file: No such file or directory
# This is an ERR trap.

# Both ls commands failed, but only the second caused a trap.


grep '^trap' /usr/bin/*                 # find traps in system shell scripts


# Unix systems support process accounting, although it is often disabled to reduce the administrative log-file management burden.
# When it is enabled, on completion of each process, the kernel writes a compact binary record in a system-dependent accounting file, such as /var/adm/pacct or /var/account/pacct.
# The accounting file requires further processing before it can be turned into a text stream that is amenable to processing with standard tools.
# For example, on Sun Solaris, root might do something like this to produce a human-readable listing:
acctcom -a                              # list accounting records
# ...
# COMMAND                  START     END       REAL   CPU    MEAN
# NAME       USER  TTYNAME TIME      TIME      (SECS) (SECS) SIZE(K)
# ...
# cat        jones       ? 21:33:38  21:33:38  0.07   0.04   1046.00
# echo       jones       ? 21:33:38  21:33:38  0.13   0.04    884.00
# make       jones       ? 21:33:38  21:33:38  0.53   0.05   1048.00
# grep       jones       ? 21:33:38  21:33:38  0.14   0.03    840.00
# bash       jones       ? 21:33:38  21:33:38  0.55   0.02   1592.00
# ...

# Because the output format and the accounting tools differ between Unix implementations, we cannot provide portable scripts for summarizing accounting data.
# However, the sample output shows that the text format is relatively simple.
# For example, we can easily produce a list of the top 10 commands and their usage counts like this:
acctcom -a |
    cut -d ' ' -f 1 |                   # extract the first field
        sort |                          # order that list
            uniq -c |                   # reduce it to counts of duplicates
                sort -k1nr -k2 |        # sort that by descending count
                    head -n 10          # display the first 10 records in the list
# 21129 bash
#  5538 cat
#  4669 rm
#  3538 sed
#  1713 acomp
#  1378 cc
#  1252 cg
#  1252 iropt
#  1172 uname
#   808 gawk

apropos accounting                      # to identify accounting commands on your system
# Common ones are acctcom, lastcomm and sa: most have options to help reduce the voluminous log data to manageable reports.


#
#   sleep       When a process should not be started until a certain time period has elapsed,
#               use the sleep command to suspend execution for a specified number of seconds, then issue the delayed command.
#               The sleep command uses few resources, and can be used without causing interference with active processes:
#               indeed, the scheduler simply ignores the sleeping process until it finally awakes when its timer expires.
#
# Most daemons do their work, and then sleep for a short while before waking to check for more work;
# that way, they consume few resources and run with little effect on other processes for as long as the system is operational.
# They usually invoke the sleep() or usleep() functions, instead of using the sleep command directly, unless they are themselves shell scripts.


#
#   at          provides a simple way to run a program at a specified time
#
#   atq         lists the jobs in the at queue
#
#   atrm        removes jobs in the at queue
#
# The syntax varies somewhat from system to system:
at 21:00             < cmd-file         # run at 21:00
at now               < cmd-file         # run immediately
at now + 10 minutes  < cmd-file         # run after 10 minutes
at now + 8 hours     < cmd-file         # run after 8 hours
at 0400 tomorrow     < cmd-file         # run at 04:00 tomorrow
at 14 July           < cmd-file         # run next Bastille Day
at noon + 15 minutes < cmd-file         # run at 12:15 today
at teatime           < cmd-file         # run at 16:00

# Whether the at family of commands is available to you depends on management policies.
# The files at.allow and at.deny control access: they are stored in /etc, /usr/lib/cron/at, /var/adm/cron or /var/at, depending on the Unix flavor.
# If neither file exists, then only root can use at.


#
#   batch       allow processes to be added to one of possibly several different batch queues
#
# The syntax of batch varies from system to system, but all support reading commands from standard input:
batch < cmd-file                        # run commands in batch

# On some systems, this is equivalent to:
at -q b -m now < cmd-file               # run commands now under the batch queue
# -q b specifies the batch queue, -m requests mail to the user when the job completes, and now means that it is ready to run immediately

# The problem with batch is that it is too simplistic: it offers little control over batch processing order, and nothing in the way of batch policy.
# It is rarely needed on smaller systems.
# On larger ones, and especially on distributed systems, batch is replaced by much more sophisticated implementations, such as:
#   Generic Network Queueing System     http://www.gnqs.org/
#   IBM LoadLeveler                     http://www.ibm.com/servers/eserver/pseries/library/sp_books/loadleveler.html
#   Maui Cluster Scheduler              http://supercluster.org/maui/
#   Platform LSF system                 http://www.platform.com/products/LSFfamily/
#   Portable Batch System               http://www.openpbs.org/
#   Silver Grid Scheduler               http://supercluster.org/silver/
#   Sun GridEngine                      http://gridengine.sunsource.net/
