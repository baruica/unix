# say we have 2 different files, first and second
ln second extra.name    # ln gives second an extra name (link)
cp first second         # cp replaces the current contents of second with a copy of first, which means that second is gone

# mv disconnects the name second from its current contents (still linked to extra.name)
# then connects the name second to the contents of first
# and finally, disconnects the name first from the file so that no file is named first
mv first second


#
#   noclobber option (the >| operator overrides the noclobber option)
#
set -C                  # POSIX
set -o noclobber        # bash and ksh
set noclobber           # csh


#
#   use the -i (interactive) flag with rm, cp and mv
#
rm -i sec*

ls sec*                 # first make sure all the files stating with sec are all concerned by the deletion
