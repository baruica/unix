typeset -i occupe
typeset -i pct_used
typeset -i total_libre
typeset -i total_disk
typeset -i total_pris
typeset -i pct_total
total=0
total_disk=0
printf "|%-20s | %-11s | %-11s | %-11s | %6s |\n" Disque Taille' Mo' Free' Mo' Used' Mo' %Used

for d in `lspv | awk '$3 != "None" { print $1 }'`
do
	### taille="`bootinfo -s $d`"     Necessite des droits root
	taille="`lspv $d | grep 'TOTAL PP' | awk -F\( '{ print $2 }' | awk '{ print $1 }'`"
	free="`lspv $d | grep 'FREE PP' | awk -F\( '{ print $2 }'`"
	freeMo=`echo $free | awk '{ print $1 }'`
	occupe=$taille-$freeMo
	total_libre=$total_libre+$freeMo
	total_disk=$total_disk+$taille
	total_pris=$total_pris+$occupe
	(( pct_used = ($occupe * 100 ) / $taille ))
	vg="`lspv $d | head -1 | awk '{ print $6 }'`"
	printf "|%-20s | %-11s | %-11s | %-11s | %6s |\n" $d/$vg $taille $freeMo $occupe $pct_used
done

(( pct_total = ($total_pris * 100) / $total_disk ))
printf "|%-20s | %-11s | %-11s | %-11s | %6s |\n" Total $total_disk $total_libre $total_pris $pct_total
