#
#   POSIX regular expressions come in 2 flavors: Basic Regular Expressions (BREs) and Extended Regular Expressions (EREs)
#
#
#   .       Match any single character except NUL (and newline for certain programs). Can match newline in awk.
#   *       Match any number (or none) of the single character (or regular expression in POSIX ERE) that precedes it.
#   \       Escape character: turns off the special meaning of the character that follows.
#
b.g             # the letter b, any character, and the letter g, anywhere on a line

tol.*toy        # the 3 letters tol, any sequence of zero or more characters, and the 3 letters toy, anywhere on a line
# toltoy, tolstoy, tolWHOtoy ...

bugs*           # the 3 letters bug, followed by zero or more s characters
# bug, bugs, bugss ...


#
#   Anchors
#
#   ^       match the following regular expression at the beginning of the line or string
#   $       match the preceding regular expression at the end of the line or string
#
^bag            # the 3 letters bag at the beginning of a line
bag$            # the 3 letters bag at the end of a line
^bag$           # a line containing exactly the 3 letters bag, and nothing else
^...$           # Any line containing exactly three characters
^\.             # Any line that begins with a dot (.) (the . character has been escaped by \)


#
#   POSIX bracket expressions
#
#   []      Match any one of the enclosed characters: a hyphen (-) indicates a range of consecutive character.
#   [^ ]    ^ as the first character in the brackets reverses the sense: it matches any one character not in the list.
#           A hyphen (-) or close bracket (]) as the first character is treated as a member of the list.
#           All other metacharacters are treated as members of the list (i.e., literally).
#
[Bb]ag          # Bag or bag, anywhere on a line
[a-d]           # either a, b, c or d
b[aeiou]g       # bag, beg, big, bog or bug
b[^aeiou]g      # second letter is not a lowercase vowel
^\.[a-z][a-z]   # any line that begins with a dot, followed by 2 lowercase letters
[*\.]           # matches a literal asterisk (*), a literal backslash (\), or a literal period (.)
[]*\.]          # adds ] to the list, must be placed first in the list
[-*\.]          # adds - to the list, must be placed first in the list
[]*\.-]         # if you need both a ] and a -, make the ] the first character, and make the - the last one in the list
^[^.]           # Any line that doesn't begin with a dot (.). ^ has 2 different meanings, outside and inside brackets []
[^0-9A-Za-z]    # any character that is not a letter or a number
[^[:alnum:]]    # same, using a POSIX character class
[A-Z].*         # an uppercase letter, followed by zero or more characters
[A-Z]*          # zero or more uppercase letters


#
#   Collating elements, equivalence classes, and character classes are only recognized inside [] of a bracket expression
#
#   POSIX Character classes
#
[:alnum:]       #  Alphanumeric characters
[:alpha:]       #    Alphabetic characters
[:blank:]       # Space and tab characters
[:cntrl:]       #       Control characters
[:digit:]       #       Numeric characters
[:graph:]       #      Nonspace characters
[:lower:]       #     Lowercase characters
[:print:]       #     Printable characters
[:punct:]       #   Punctuation characters
[:space:]       #    Whitespace characters
[:upper:]       #     Uppercase characters
[:xdigit:]      #   Hexadecimal digits


#
#   POSIX Collating symbols
#
#       A collating symbol is a multicharacter sequence that should be treated as a unit.
#       Collating symbols are specific to the locale in which they are used.
#       In several languages, certain pairs of characters must be treated, for comparison purposes, as if they were a single character.
#       Such pairs have a defined way of sorting when compared with single letters in the language.
#       For example, in Czech and Spanish, the two characters ch are kept together and are treated as a single unit for comparison purposes.
#       It consists of the characters bracketed by [. and .]
#
[.ch.]          # matches the collating element ch, but does not match just the letter c or the letter h
[a[.ch.]d]      # matches any of the characters a, d, or the pair ch. It does not match a standalone c or h character


#
#   POSIX Equivalence classes
#
#       An equivalence class lists a set of characters that should be considered equivalent, such as e and è.
#       It consists of a named element from the locale, bracketed by [= and =]
#
[=e=]           # in French locale, it might match any of e, è, ë, ê, or é


#
#   Backreferences are particularly useful for finding duplicated words and matching quotes
#
# \( \)     Save the subpattern enclosed between \( and \) into a special holding space.
#           Up to 9 subpatterns can be saved on a single pattern.
#           The text matched by the subpatterns can be reused later in the same pattern, by the escape sequences \1 to \9.
# \{n,m\}   Interval expression. Matches a range of occurrences of the single character (or regular expression) that immediately precedes it.
# \{n\}     matches exactly n occurrences
# \{n,\}    matches at least n occurrences
# \{n,m\}   Matches any number of occurrences between n and m. n and m must be between 0 and RE_DUP_MAX (min 255), inclusive.
#           RE_DUP_MAX is a symbolic constant defined by POSIX and available via the getconf command (getconf RE_DUP_MAX)
#  {n,m}    ERE version of \{n,m\}
#
0\{5,\}                                 # 5 or more zeros in a row
^\.[a-z]\{2\}                           # any line that begins with a dot (.), followed by 2 lowercase letters
\(why\).*\1                             # a line with two occurrences of why
\([[:alpha:]_][[:alnum:]_]*\) = \1;     # simple C/C++ assignment statement
[0-9]\{3\}-[0-9]\{2\}-[0-9]\{4\}        # U.S. Social Security number (nnn-nn-nnnn)
\(["']\).*\1                            # Match single- or double-quoted words, like 'foo' or "bar"
                                        # this way, you don't have to worry about whether a ' or " was found first

#
#   BRE operator precedence from highest to lowest
#
#   [. .] [= =] [: :]       Bracket symbols for character collation
#   \metacharacter          Escaped metacharacters
#   [ ]                     Bracket expressions
#   \( \) \digit            Subexpressions and backreferences
#   * \{ \}                 Repetition of the preceding single-character regular expression
#   no symbol               Concatenation
#   ^ $                     Anchors
#


#
#   +       Repetition operator
#
#       ERE. Match 1 or more instances of preceding regular expression
#
ab+c                                    # matches abc, abbc, abbbc, and so on, but does not match ac
[A-Z][A-Z]*                             # One or more uppercase letters
[A-Z]+                                  # Same (egrep or awk only)
[[:upper:]]+                            # Same as previous using a POSIX character class


#
#   ?       Optional
#
#       ERE. Match 0 or 1 instances of preceding regular expression
#
ab?c                                    # abc or ac
80[2-4]?86                              # 8086, 80286, 80386, or 80486


#
#   |       Alternation operator
#
#       Match the regular expression specified before or after.
#
five|six|seven                          # One of the words five, six, or seven


#
#   ( )     Grouping
#
#       Apply a match to the enclosed group of regular expressions
#
(why)+                                  # matches one or more occurrences of the word why
compan(y|ies)                           # company or companies
(yes|no)+                               # matches one or more occurrences of either of the words yes or no
^abcd|efgh$                             # matches abcd at the beginning of the string, or match efgh at the end of the string
^(abcd|efgh)$                           # using the grouping operator, matches a string containing exactly abcd or exactly efgh
80[2-4]?86|(Pentium(-III?)?)            # 8086, 80286, 80386, 80486, Pentium, Pentium-II, or Pentium-III


#
#   ERE operator precedence from highest to lowest
#
#   [. .] [= =] [: :]       Bracket symbols for character collation
#   \metacharacter          Escaped metacharacters
#   [ ]                     Bracket expressions
#   ( )                     Grouping
#   * + ? { }               Repetition of the preceding regular expression
#   no symbol               Concatenation
#   ^ $                     Anchors
#   |                       Alternation
#


#
#   GNU regular expression operators
#
#   word-constituent characters are those who constitute words: letters, digits, and underscores
#
#   \w      Matches any word-constituent character. Equivalent to [[:alnum:]_].
#   \W      Matches any nonword-constituent character. Equivalent to [^[:alnum:]_].
#   \< \>   Matches the beginning and end of a word, respectively.
#   \b      Matches the null string found at either the beginning or the end of a word. It's a generalization of the \< and \> operators.
#           Note: Because awk uses \b to represent the backspace character, GNU awk (gawk) uses \y.
#   \B      Matches the null string between two word-constituent characters.
#   \' \`   Matches the beginning and end of an emacs buffer, respectively.
#           GNU programs (besides emacs) generally treat these as being equivalent to ^ and $
#


#           grep    sed    ed    ex/vi    more    egrep    awk    lex
#   BRE     ·       ·      ·     ·        ·
#   ERE                                           ·        ·      ·
#   \< \>   ·       ·      ·     ·        ·

# By default, POSIX grep uses BREs.
# With the -E option, it uses EREs, like egrep.
# With the -F option, it uses the fgrep fixed-string matching algorithm.
