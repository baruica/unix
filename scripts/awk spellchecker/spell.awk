#!/bin/awk

# Implementation of a simple spellchecker, with user-specifiable exception lists.
# The built-in dictionary is constructed from a list of standard Unix spelling dictionaries, which can be overridden on the command line.

...

# Usage:
#		awk [-v Dictionaries="sysdict1 sysdict2 ..."] -f spell.awk -- \
#		    [=suffixfile1 =suffixfile2 ...] [+dict1 +dict2 ...] \
#		    [-strip] [-verbose] [file(s)]

# awk -f spell.awk testfile
#	deroff
#	eqn
#	ier
#	nx
#	tbl
#	thier
#
# or in verbose mode, like this:
# awk -f spell.awk -- -verbose testfile
#	testfile:7:eqn
#	testfile:7:tbl
#	testfile:11:deroff
#	testfile:12:nx
#	testfile:19:ier
#	testfile:19:thier


BEGIN	{ initialize( ) }

		{ spell_check_line( ) }

END		{ report_exceptions( ) }

# Fills in a list of default system dictionaries: we supply 2 convenient ones.
# The user can override that choice by providing a list of dictionaries as the value of the command-line variable Dictionaries, or the environment variable DICTIONARIES.
function get_dictionaries(files, key)
{
	# If Dictionaries is empty, we consult the environment array, ENVIRON, and use any value set there.
	if ((Dictionaries =  = "") && ("DICTIONARIES" in ENVIRON))
		Dictionaries = ENVIRON["DICTIONARIES"]
	# If Dictionaries is still empty, we supply a built-in list
	if (Dictionaries =  = "")
	{
		DictionaryFiles["/usr/dict/words"]++
		DictionaryFiles["/usr/local/share/dict/words.knuth"]++
	}
	# Otherwise, Dictionaries contains a whitespace-separated list of dictionary filenames, which we split and store in the global DictionaryFiles array.
	else
	{
		split(Dictionaries, files)
		for (key in files)
			DictionaryFiles[files[key]]++
	}
	# Notice how the dictionary names are stored: they are array indices, rather than array values.
	# There are 2 reasons for this design choice.
	# First, it automatically handles the case of a dictionary that is supplied more than once: only one instance of the filename is saved.
	# Second, it then makes it easy to iterate over the dictionary list with a for (key in array) loop.
	# There is no need to maintain a variable with the count of the number of dictionaries.
}

function initialize( )
{
	# NonWordChars holds a regular expression that is later used to eliminate unwanted characters.
	# Along with the ASCII letters and apostrophe,
	# characters in the range 161 to 255 are preserved as word characters so that files in ASCII,
	# any of the ISO 8859-n character sets and Unicode in UTF-8 encoding all can be handled without further concern for character sets.
	# Characters 128 to 160 are ignored because in all of those character sets, they serve as additional control characters and a nonbreaking space.
	# Some of those character sets have a few nonalphabetic characters above 160, but it adds undesirable character-set dependence to deal with them.
	# The nonalphabetic ones are rare enough that their worst effect on our program may be an occasional false report of a spelling exception.
	NonWordChars = "[^" \
		"'" \
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ" \
		"abcdefghijklmnopqrstuvwxyz" \
		    "\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257" \
		"\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277" \
		"\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317" \
		"\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337" \
		"\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357" \
		"\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377" \
		"]"
	# If all awk implementations were POSIX-conformant, we would set NonWordChars like this:
	#	NonWordChars = "[^'[:alpha:]]"
	# The current locale would then determine exactly which characters could be ignored.

	get_dictionaries( )
	scan_options( )
	load_dictionaries( )
	load_suffixes( )
	order_suffixes( )
}

# reads the word lists from all of the dictionaries
function load_dictionaries(myfile, word)
{
	for (myfile in DictionaryFiles)				# read a line at a time
	{
		while ((getline word < myfile) > 0)
			# Each line contains exactly one word known to be spelled correctly.
			# The dictionaries are created once, and then used repeatedly, so we assume that lines are free of whitespace, and we make no attempt to remove it.
			Dictionary[tolower(word)]++			# each word is converted to lowercase and stored as an index of the global Dictionary array
		close(myfile)
		# No separate count of the number of entries in this array is needed because the array is used elsewhere only in membership tests.
		# Among all of the data structures provided by various programming languages, associative arrays are the fastest and most concise way to handle such tests.
	}
}

# In many languages, words can be reduced to shorter root words by stripping suffixes.
# For example, in English: jumped, jumper, jumpers, jumpier, jumpiness, jumping, jumps and jumpy all have the root word jump.
# Suffixes sometimes change the final letters of a word: try is the root of triable, trial, tried and trying.
# Thus, the set of base words that we need to store in a dictionary is several times smaller than the set of words that includes suffixes.
# Since I/O is relatively slow compared to computation, it may pay to handle suffixes in this program,
# to shorten dictionary size and reduce the number of false reports in the exception list.

# Handles the loading of suffix rules.
# Unlike dictionary loading, here we have the possibility of supplying built-in rules, instead of reading them from a file.
# Thus, we keep a global count of the number of entries in the array that holds the suffix-rule filenames.
function load_suffixes(myfile, k, myline, n, parts)
{
	if (NSuffixFiles > 0)						# load suffix regexps from files
	{
		for (myfile in SuffixFiles)
		{
			while ((getline myline < myfile) > 0)
			{
				# The simplest specification of a suffix rule is a regular expression to match the suffix, followed by a whitespace-separated list of replacements.
				sub(" *#.*$", "", myline)		# strip comments
				sub("^[ \t]+", "", myline)		# strip leading whitespace
				sub("[ \t]+$", "", myline)		# strip trailing whitespace
				# one of the possible replacements may be an empty string
				if (myline =  = "")
					continue
				# What remains is a regular expression and a list of zero or more replacements that are used elsewhere in calls to the awk built-in string substitution function, sub().
				# The replacement list is stored as a space-separated string to which we can now apply the split() built-in function.
				n = split(myline, parts)
				Suffixes[parts[1]]++
				Replacement[parts[1]] = parts[2]
				for (k = 3; k <= n; k++)
					Replacement[parts[1]] = Replacement[parts[1]] " " parts[k]
			}
			close(myfile)
		}
	}
	else										# If no suffix files are supplied, we load a default set of suffixes with empty replacement values.
	{
		split("'$ 's$ ed$ edly$ es$ ing$ ingly$ ly$ s$", parts)
		for (k in parts)
		{
			Suffixes[parts[k]] = 1
			Replacement[parts[k]] = ""
		}
	}
}

# Takes the list of suffix rules saved in the global Suffixes array,
# and copies it into the OrderedSuffix array,
# indexing that array by an integer that runs from one to NOrderedSuffix.
function order_suffixes(i, j, key)
{
	# Order suffixes by decreasing length
	NOrderedSuffix = 0
	for (key in Suffixes)
		OrderedSuffix[++NOrderedSuffix] = key
	for (i = 1; i < NOrderedSuffix; i++)
		for (j = i + 1; j <= NOrderedSuffix; j++)
			if (length(OrderedSuffix[i]) < length(OrderedSuffix[j]))
				swap(OrderedSuffix, i, j)		# reorder the entries in OrderedSuffix by decreasing pattern length
}

# Sets up a pipeline to sort with command-line options that depend on whether the user requested a compact listing of unique exception words, or a verbose report with location information.
# In either case, we give sort the -f option to ignore lettercase, and the -u option to get unique output lines.
function report_exceptions(key, sortpipe)
{
	sortpipe = Verbose ? "sort -f -t: -u -k1,1 -k2n,2 -k3" : "sort -f -u -k1"
	for (key in Exception)
		print Exception[key] | sortpipe
	close(sortpipe)								# shuts down the pipeline and completes the program
}

# Handles the command line.
# It expects to find options (-strip and/or -verbose),
# user dictionaries (indicated with a leading +, a Unix spell tradition),
# suffix-rule files (marked with a leading =),
# and files to be spellchecked.
# Any -v option to set the Dictionaries variable has already been handled by awk, and is not in the argument array, ARGV.
function scan_options(k)
{
	for (k = 1; k < ARGC; k++)
	{
		if (ARGV[k] =  = "-strip")
		{
			ARGV[k] = ""
			Strip = 1
		}
		else if (ARGV[k] =  = "-verbose")
		{
			ARGV[k] = ""
			Verbose = 1
		}
		else if (ARGV[k] ~ /^=/)				# suffix file
		{
			NSuffixFiles++
			SuffixFiles[substr(ARGV[k], 2)]++
			ARGV[k] = ""
		}
		else if (ARGV[k] ~ /^[+]/)				# private dictionary
		{
			DictionaryFiles[substr(ARGV[k], 2)]++
			ARGV[k] = ""
		}
	}

	# nawk does not read standard input if empty arguments are left at the end of ARGV, whereas gawk and mawk do.
	# We therefore reduce ARGC until we have a nonempty argument at the end of ARGV.
	while ((ARGC > 0) && (ARGV[ARGC-1] =  = ""))
		ARGC--									# remove trailing empty arguments (for nawk)
}

function spell_check_line(k, word)
{
	gsub(NonWordChars, " ")						# removes nonalphanumeric characters
	# the resulting words are then available as $1, $2, ..., $NF
	for (k = 1; k <= NF; k++)
	{
		# As a general awk programming convention, we avoid reference to anonymous numeric field names, like $1, in function bodies,
		# preferring to restrict their use to short action-code blocks.
		# We made an exception in this function: $k is the only such anonymous reference in the entire program.
		word = $k								# to avoid unnecessary record reassembly when it is modified, we copy $k into a local variable
		sub("^'+", "", word)					# strip leading apostrophes
		sub("'+$", "", word)					# strip trailing apostrophes
		if (word != "")
			spell_check_word(word)
	}
	# It is not particularly nice to have character-specific special handling once a word has been recognized.
	# However, the apostrophe is an overloaded character that serves both to indicate contractions in some languages, as well as provide outer quoting.
	# Eliminating its quoting use reduces the number of false reports in the final spelling-exception list.
}

function spell_check_word(word, key, lc_word, location, w, wordlist)
{
	lc_word = tolower(word)
	if (lc_word in Dictionary)					# the lowercase word is spelled correctly
		return
	else										# probably a spelling exception
	{
		if (Strip)
		{
			strip_suffixes(lc_word, wordlist)
			for (w in wordlist)
			{
				if (w in Dictionary)
					return
			}
		}
		# If suffix stripping is not requested, or if we did not find any replacement words in the dictionary, then the word is definitely a spelling exception.
		# However, it is a bad idea to write a report at this point because we usually want to produce a sorted list of unique spelling exceptions.
		# Instead, we store the word in the global Exception array.
		location = Verbose ? (FILENAME ":" FNR ":") : ""
		if (lc_word in Exception)				# prefix the word with a location defined by a colon-terminated filename and line number
			Exception[lc_word] = Exception[lc_word] "\n" location word
		else
			Exception[lc_word] = location word
	}
}

# produces a list of one or more related words stored as indices of the local wordlist array
function strip_suffixes(word, wordlist, ending, k, n, regexp)
{
	split("", wordlist)
	for (k = 1; k <= NOrderedSuffix; k++)
	{
		regexp = OrderedSuffix[k]
		if (match(word, regexp))
		{
			word = substr(word, 1, RSTART - 1)			# the suffix is removed to obtain the root word
			if (Replacement[regexp] =  = "")			# if there are no replacement suffixes
				wordlist[word] = 1						# the word is stored as an index of the wordlist array
			else
			{
				split(Replacement[regexp], ending)		# we split the replacement list into its members
				for (n in ending)
				{
					if (ending[n] =  = "\"\"")			# check for the special two-character string ""
						ending[n] = ""					# replace with an empty string
					wordlist[word ending[n]] = 1		# append each replacement in turn to the root word
				}
			}
			break
		}
	}
}

function swap(a, i, j, temp)
{
	temp = a[i]
	a[i] = a[j]
	a[j] = temp
}
