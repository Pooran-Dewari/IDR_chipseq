#sort narrowPeak
ls *narrowPeak | while read filename;
do
sort -k8,8nr $filename > $filename"_sorted";
done


######## get filenames prefixes ###########
for fname in *sorted
do
  tmp=$(echo "$fname" | awk -F '_' '{print $1"_"$2}' )
  newfname=${tmp}
  echo $newfname >> sorted_tmp.txt
done;

sort -u sorted_tmp.txt > sorted_list.txt

rm sorted_tmp.txt

#run IDR  using a loop

#first create a directory to put in all results for today
DIR_TEMP=$(date +%Y_%m_%d)
DIR_FINAL="IDR_${DIR_TEMP}"
mkdir $DIR_FINAL

#now run IDR
while read SORTED;
do
   mkdir $SORTED
   SORT_FILES=$(ls * | grep "$SORTED.*sorted")
   mv $SORT_FILES $SORTED/
   cd $SORTED
   NARROW=$(ls | grep $SORTED.*sorted)
   for i in $NARROW
    do
      for j in $NARROW
      do
        if [ "$i" \< "$j" ]
        then
         STAGE=$(echo $i| cut -d'_' -f 1)
         MARK=$(echo $i| cut -d'_' -f 2)
         REP1=$(echo $i| cut -d'_' -f 3)
         REP2=$(echo $j| cut -d'_' -f 3)
         #echo "Now doing IDR for $i & $j"
         echo "Now doing IDR:"
         echo "       - $i"
         echo "       - $j"
         echo "--------------------------------"
         idr --samples $i $j \
	    --input-file-type narrowPeak \
	    --rank p.value \
	    --output-file $STAGE-$MARK-$REP1-$REP2-idr \
	    --plot \
	    --log-output-file $STAGE-$MARK-$REP1-$REP2.log
        fi
      done
    done
    cd ..
    mv $SORTED $DIR_FINAL
done < sorted_list.txt
rm sorted_list.txt

echo " *************"
echo "  ***********"
echo "   ********"
echo "    ******"
echo "     ****"
echo "   IDR done!!"
