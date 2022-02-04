#
#   cron        daemon started at system startup that provides for running jobs at specified times
#

#
#   crontab     command used to manage a simple text file that records when jobs are to be run by cron
#
#       mm    hh    dd    month  weekday         command
#       0-59  0-23  1-31  1-12   0-6 (0=sunday)
#
#   -e  edit a copy of your crontab file using the editor specified by the EDITOR environment variable (default editor is vi)
#   -l  list your crontab file
#   -r  removes your crontab file from the crontab directory
#
#   You can use an asterisk in any category to mean for every item, such as every day or every month.
#   You can use commas in any category to specify multiple values. For example: mon,wed,fri
#   You can use dashes to specify ranges. For example: mon-fri, or 9-17
#   You can use forward slash to specify a repeating range. For example: */5 for every five minutes, hours, days
#
crontab crontab_file                                            # copie crontab_file vers /var/spool/cron/crontabs sous le nom de l'utilisateur courant


15  *   *   *   *   cmd                                         # run hourly at quarter past the hour
0   2   1   *   *   cmd                                         # run at 02:00 at the start of each month
0   8   1  1,7  *   cmd                                         # run at 08:00 on January 1 and July 1
0   6   *   *   1   cmd                                         # run at 06:00 every Monday
0  8-17 *   *  0,6  cmd                                         # run hourly from 08:00 to 17:00 on weekends

0   0   *   *   *   find /home -name core -exec rm -f {} \;     # détruire tout les jours à minuit les fichiers core sous /home
30  0   *   *  1-5  tar cvf /dev/rst0 /home                     # faire une sauvegarde du répertoire /home tous les jours de la semaine à 00h30
0   1   *   *  0,6  tar cvf /dev/rst0 /                         # faire une sauvegarde de tout le disque le samedi et dimanche à 1h du matin

00 07 * * 1-5           mail_pager.script 'Wake Up'             # Run command at 7:00am each weekday [mon-fri]
30 17 1 * *             pay_rent.script                         # Run command on 1st of each month, at 5:30pm
00 8,10,14 * * *        do_something.script                     # Run command at 8:00am,10:00am and 2:00pm every day
*/5 6-13 * * mon-fri    get_stock_quote.script                  # Run command every 5 minutes during market hours
0 7-23/3 * * *          drink_water.script                      # Run command every 3-hours while awake


# Commands in the crontab file run with a few environment variables already set:
# SHELL is /bin/sh, and HOME, LOGNAME, and sometimes, USER, are set according to values in your entry in the passwd file or database.

# The PATH setting is sharply restricted, often to just /usr/bin.
# If you are used to a more liberal setting, you may either need to specify full paths to commands used in the crontab file, or else set the PATH explicitly:
0   4   *   *   *   /usr/local/bin/updatedb                     # update the GNU fast find database nightly
0   4   *   *   *   PATH=/usr/local/bin:$PATH updatedb          # similar, but pass PATH to updatedb's children


# Any output produced on stderr or stdout is mailed to you, or in some implementations, to the user specified by the value of the MAILTO variable.
# In practice, you more likely want output redirected to a log file and accumulated over successive runs.
55  23  *   *   *   $HOME/bin/daily >> $HOME/logs/daily.log 2>&1
# Log files like this continue to grow, so you should do an occasional cleanup,
# perhaps by using an editor to delete the first half of the log file,
# or tail -n n to extract the last n lines:
cd $HOME/logs                                                   # change to log-file directory
mv daily.log daily.tmp                                          # rename the log file
tail -n 500 daily.tmp > daily.log                               # recover the last 500 lines
rm daily.tmp                                                    # discard the old log file
# Just be sure to do this at a time when the log file is not being updated.
# Obviously, this repetitive process can, and should, itself be relegated to another crontab entry.

# A useful alternative to a cumulative log file is timestamped files with one cron job log per file.
# For a daily log, we could use a crontab entry like this:
55  23  *   *   *   $HOME/bin/daily > $HOME/logs/daily.$(date +\%Y.\%m.\%d).log 2>&1

# You can easily compress or remove old log files with the help of the find command:
find $HOME/logs/*.log -ctime +31 | xargs bzip2 -9               # compress log files older than a month
find $HOME/logs/*.log -ctime +31 | xargs rm                     # remove log files older than a month


# Like rm, crontab -r is irrevocable and unrecoverable.
# Caution suggests preserving a copy like this:
crontab -l > $HOME/.crontab.$(hostname)                         # save the current crontab
crontab -r                                                      # remove the crontab
# so that you can later restore it with:
crontab $HOME/.crontab.$(hostname)                              # restore the saved crontab


# As with the at command, there are cron.allow and cron.deny files in system directories that control whether cron jobs are allowed, and who can run them.
