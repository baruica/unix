#
# checkbook.QIF looks like this
#
# !Type:Bank
# D08/28/2000
# T-8.15
# N
# PCHECKCARD SUPERMARKET
# ^
# D08/28/2000
# T-8.25
# N
# PCHECKCARD PUNJAB RESTAURANT
# ^
# D08/28/2000
# T-17.17
# N
# PCHECKCARD SUPERMARKET
#
# checkbook.txt should look like this after extracting from checkbook.QIF
#
# 28	Aug	2000	food	-	-	Y	Supermarket	30.94
# 25	Aug 2000	watr	-	103	Y	Check 103	52.86
#
# All fields are separated by one or more tabs, with one transaction per line.
# After the date, the next field lists the type of expense (or "-" if this is an income item).
# The third field lists the type of income (or "-" if this is an expense item).
# Then, there's a check number field (again, "-" if empty),
# a transaction cleared field ("Y" or "N"),
# a comment and a dollar amount
#
1d										# deletes the 1st line
/^^/d									# deletes the ^ between each record
s/[[:cntrl:]]//g						# substitutes any control characters that may exist in the file (different file format) , by an empty string
/^D/ {									# adds an address so that sed only begins processing when it finds D
	s/^D\(.*\)/\1\tOUTY\tINNY\t/		# transforms D08/28/2000 into 08/28/2000	OUTY	INNY
	s/^01/Jan/
	s/^02/Feb/
	s/^03/Mar/
	s/^04/Apr/
	s/^05/May/
	s/^06/Jun/
	s/^07/Jul/
	s/^08/Aug/							# Aug 28 2000	OUTY	INNY
	s/^09/Sep/							# OUTY and INNY being placeholders for later in the script
	s/^10/Oct/
	s/^11/Nov/
	s/^12/Dec/
	s:^\(.*\)/\(.*\)/\(.*\):\2 \1 \3:
	N									# tells sed to read in the next line in the input and append it to our current pattern space
	N									# the next 3 lines will be appended to our current pattern space buffer
	N									# 28 Aug 2000	OUTY	INNY	\nT-8.15\nN\nPCHECKCARD SUPERMARKET
	# we want to match this pattern \nT.*\nN.*\nP.* (newline, T, 0 or more characters, newline, N, 0 or more characters, P, 0 or more characters)
	s/\nT\(.*\)\nN\(.*\)\nP\(.*\)/NUM\2NUM\t\tY\t\t\3\tAMT\1AMT/			# 28 Aug 2000	OUTY	INNY	NUMNUM	Y	CHECKCARD	SUPERMARKET	AMT-8.15AMT
	s/NUMNUM/-/
	s/NUM\([0-9]*\)NUM/\1/
	s/\([0-9]\),/\1/
	/AMT-[0-9]*.[0-9]*AMT/b fixnegs		# executes the branch command fixnegs
	s/AMT\(.*\)AMT/\1/
	s/OUTY/-/
	s/INNY/inco/
	b done
:fixnegs
	s/AMT-\(.*\)AMT/\1/
	s/OUTY/misc/
	s/INNY/-/							# 28 Aug 2000	misc	-	-	Y	CHECKCARD	SUPERMARKET	-8.15
:done
}
