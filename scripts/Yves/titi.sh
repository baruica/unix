typeset -i sz
typeset -i pp
typeset -i c
printf "%-25s %-10s %-10s \n" 'FS monte' Taille LV
### lsvg -o | lsvg -il | grep jfs | grep closed | egrep -v "jfslog|N/A" | while read a b c d e f g h
lsvg -o |
	lsvg -il |
		grep jfs |
			egrep -v "jfslog|N/A" |
				while read a b c d e f g h
				do
					pp=`lslv $a | grep "PP SIZE" | awk '{ print $6 }'`
					(( sz = $pp * $c ))
					printf "%-25s %-10s %-10s \n" $g $sz'Mo' $a
				done
