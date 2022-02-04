#!/bin/sh -

# Read one or more HTML/SGML/XML files given on the command line containing markup like <tag>word</tag>
# and output on standard output a tab-separated list of
#		count word tag filename
#
# sorted by ascending word and tag
#
# Usage:
#		tag-list2 xml-files

process()
{
	cat "$1" |
		# converts tags such as <systemitem role="URL"> and </systemitem> into simpler <URL> and </URL> tags
		sed -e 's#systemitem *role="url"#URL#g' -e 's#/systemitem#/URL#' |
			# replace spaces and paired delimiters by newlines
			tr ' ( ){  }[  ]' '\n\n\n\n\n\n\n' |
				# selects tag-enclosed words
				egrep '>[^<>]+</' |
					# <> are the field separators, so the input <literal>tr</literal> is split into 3 fields: literal, tr, and /literal
					awk -F'[<>]' -v MY_FILE="$1" '{ printf("%-31s\t%-15s\t%s\n", $3, $2, MY_FILE) }' |
						# sort into word order
						sort |
							# removes duplicates and prefixes the count field
							uniq -c | 			# outputs count, word, file, tag
								# orders the output by word and tag (the 2nd and 3rd fields)
								sort -k2 -k3 |
									# filters successive lines, adding a trailing arrow when it sees the same word as on the previous line
									awk '{ print ($2 == Last) ? ($0 " <----") : $0 Last = $2 }'
}

for f in "$@"
do
	process "$f"
done
