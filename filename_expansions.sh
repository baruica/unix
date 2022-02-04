~                       # home directory of the current user    ($HOME)
~nels                   # home directory of user nels
~+                      # current working directory             ($PWD)      (bash and ksh93)
~-                      # previous working directory            ($OLDPWD)   (bash and ksh93)

vi ~/.profile           # Same as vi $HOME/.profile
vi ~tolstoy/.profile    # Edit user tolstoy's .profile file


#
#   wildcards
#
#   ?           any single character
#   *           anything at all
#   [abc...]    any 1 of the enclosed characters or range of characters (specified with - between)
#   [!abc...]   any 1 character not enclosed
#
ls ??                   # lists any 2 character named file
ls budget??             # returns budget98, budget99...
ls c*                   # lists all the files that start with a c
ls *[eE]                # lists all the files that end with either e or E
ls [c-g]*               # lists all the files that start with letters from c to g
ls 3[2-59]7             # lists all the files like 327, 337, 347, 357 and 397 NOT 3597
ls z[a-dA-D]y           # lists all the files like zay, zby, zcy, zdy, zAy, zBy, zCy and zDy
ls [!e-h]*              # lists all the files that doesn't start with a letter from e to h
