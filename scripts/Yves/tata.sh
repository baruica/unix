for i in `lsvg -o | lsvg -il | grep -v "N/A" | grep "open" | awk '{ print $1":"$7 }'`
do
	lv=`echo $i | awk -F: '{ print $1 }'`
	mnt=`echo $i | awk -F: '{ print $2 }'`
	(
		printf "%-35s ===> " $mnt
		lslv $lv | grep GROUP | awk '{ print $6 }'
	)
done > tmp_sort
sort -f tmp_sort
rm tmp_sort
