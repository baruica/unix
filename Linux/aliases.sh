#!/bin/bash

# ssh
alias server_name='ssh -v -l USERNAME IP_ADDRESS'


# ls
alias ll='ls -l'
# Another handy ls alias is this:
alias la='ls -a'


# rm safety net
alias rm='rm -i'


# more useful df command
alias df='df -h'


# apt-get update
alias update='sudo apt-get update'


# rpm batch install
# typically dump a bunch of rpm files into an empty directory (created for this specific purpose) and run the command rpm -ivh ~/RPM/*rpm.
alias brpm='rpm -ivh ~/RPM/*rpm'
# You have to create the ~/RPM directory and enter the root password for this to work.
