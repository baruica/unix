#!/bin/sh

# phrase -- search for words across lines
#
# $1 = search pattern; remaining args = filenames

search=$1
shift
for fich
do
	# the '" "' make sure the enclosed argument is evaluated first by the shell before the sed script is evaluated by sed
	sed '
					# if the search pattern matches the line, the branch command, without a label,
					# transfers control to the bottom of the script where the line is printed
	/'"$search"'/b	# looks for the search pattern on a line by itself
	N				# the Next command appends the next input line to the pattern space
	h				# the hold command places a copy of the two-line pattern space into the hold space
	s/.*\n//		# the substitute command removes the previous line, up to and including the embedded newline
	/'"$search"'/b	# looks for the search pattern on the second line
	g				# the get command retrieves a copy of the original 2-line pair from the hold space, overwriting the line we had worked with in the pattern space
	s/ *\n/ /		# the substitute command replaces the embedded newline and any spaces preceding it with a single space
	/'"$search"'/{	# attempt to match the pattern, if the match is made,
	g				# we get the duplicate of the contents of the pattern space from the hold space (which preserves the newline)
	b				# then print
	}
	g				# retrieves the duplicate, that preserves the newline, from the hold space
	D' $fich		# the Delete command removes the first line in the pattern space and passes control back to the top of the script
done
