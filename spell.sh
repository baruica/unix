# Unix spell supports several options, most of which are not helpful for day-to-day use.
# One exception is the -b option, which causes spell to prefer British spelling: "centre" instead of "center", "colour" instead of "color" and so on.

# One nice feature is that you can provide your own local spelling list of valid words.
# For example, it often happens that there may be words from a particular discipline that are spelled correctly,
# but that are not in spell's dictionary (for example, "POSIX").
# You can create, and over time maintain, your own list of valid but unusual words, and then use this list when running spell.
# You indicate the pathname to the local spelling list by supplying it before the file to be checked, and by preceding it with a + character:
spell +/usr/local/lib/local.words myfile > myfile.errs

# There are some nuisances with spell: only one + option is permitted, and its dictionaries must be sorted in lexicographic order, which is poor design.
# It also means that most versions of spell break when the locale is changed.
# (While one might consider this to be bad design, it is really just an unanticipated consequence of the introduction of locales.
# The code for spell on these systems probably has not changed in more than 20 years,
# and when the underlying libraries were updated to do locale-based sorting, no one realized that this would be an effect.)

env LC_ALL=en_GB spell +ibmsysj.sok < ibmsysj.bib | wc -l
# 3674

env LC_ALL=en_US spell +ibmsysj.sok < ibmsysj.bib | wc -l
# 3685

env LC_ALL=C spell +ibmsysj.sok < ibmsysj.bib | wc -l
# 2163

# However, if the sorting of the private dictionary matches that of the current locale, spell works properly:
env LC_ALL=en_GB sort ibmsysj.sok > /tmp/foo.en_GB
env LC_ALL=en_GB spell +/tmp/foo.en_GB < ibmsysj.bib | wc -l
# 2163

# The problem is that the default locale can change from one release of an operating system to the next.
# Thus, it is best to set the LC_ALL environment variable to a consistent value for private dictionary sorting, and for running spell.


# There are 2 different, freely available spellchecking programs: ispell and aspell.
# ispell is an interactive spellchecker; it displays your file, highlighting any spelling errors and providing suggested changes.
# aspell is a similar program; for English it does a better job of providing suggested corrections, and its author would like it to eventually replace ispell.
# Both programs can be used to generate a simple list of misspelled words, and since aspell hopes to replace ispell, they both use the same options:
#   -l          Print a list of misspelled words on standard output.
#   -p file     Use file as a personal dictionary of correctly spelled words. This is similar to Unix spell's personal file that starts with a +.
# Both programs provide basic batch spellchecking.
# They also share the same quirk, which is that their results are not sorted, and duplicate bad words are not suppressed. (Unix spell has neither of these problems.)
