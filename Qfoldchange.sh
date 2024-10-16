#!/bin/bash
echo -e "Please type the location of your output files here."
read path
echo -e "Please type the location of your descriptor file here."
read descpath
cd ${descpath}
fqfile=$(ls *.fqfiles)
awk 'BEGIN{FS="\t";OFS="_"}{print $1,"\t"$2,$4,$5,"\t",$6,"\t",$7,"\t",$3}' Tco2.fqfiles > Tco2.sorted.fqfiles
awk 'BEGIN{FS="_\t_";OFS="\t"}{print $1,$2,$3,$4}' Tco2.sorted.fqfiles > listoffiles.txt
cd ${path}
allfiles=$(ls combined_*.txt)
rm -f lastnumfile1.tmp
rm -f lastnumfile2.tmp
rm -f *.tmp
echo -e "Please type the Condition A that you want. The following types are available:"
awk 'BEGIN{FS="\t"}; {print $2}' ${descpath}/listoffiles.txt | sort | uniq
read typeofsample
echo -e "Please type the Condition B that you want. The preceding types are available."
read typeofsample2
rm -f filesToFind.tmp
awk -v fjn=$file -v type=$typeofsample '{if($2==type) {print $1}}' ${descpath}/listoffiles.txt >> filesToFind.tmp
awk -v fjn=$file -v type=$typeofsample2 '{if($2==type) {print $1}}' ${descpath}/listoffiles.txt >> filesToFind.tmp
filesToFind=$(cat filesToFind.tmp)
rm -f filesrec.tmp
for file in ${filesToFind[@]}; do
	file=$(echo $file|sed 's/_$//')
	filewithhyphen="${file:0:3}-$(echo "${file:3}")"
	filenamereconstructed="combined_"$filewithhyphen".txt"
	echo $filenamereconstructed
done > filesrec.tmp
filesToFinds=($(cat filesrec.tmp))
#for file in ${filesToFinds[@]};do
cd ${path}
echo file 1 ${filesToFinds[0]}
echo file 2 ${filesToFinds[1]}
echo ${filesToFinds[@]}
rm -f tmpoutput2.txt
touch ${typeofsample}_log10foldchangefrom_${typeofsample2}.txt
#paste ${filesToFinds[0]} ${path}/${typeofsample}_log10foldchangefrom_${typeofsample2}.txt
awk 'BEGIN{FS="\t";OFS="\t"}{print $NF}' ${filesToFinds[0]} > lastnumfile1.tmp
awk 'BEGIN{FS="\t";OFS="\t"}{print $NF}' ${filesToFinds[1]} > lastnumfile2.tmp
counter=0
linecount=$(wc -l < lastnumfile1.tmp)
paste lastnumfile1.tmp lastnumfile2.tmp | while read -r File1Mean File2Mean; do
	if [[ $File1Mean != 0 && $File2Mean != 0 ]]; then
		fold_change=$(echo "scale=5;l($File2Mean/$File1Mean)/l(10)"|bc -l)
		counter=$((counter + 1))
		echo Processed $counter of $linecount Fold change = $fold_change
	else
		fold_change="N/A"
		echo Processed $counter of $linecount Fold change = $fold_change
	fi
	echo $fold_change >> ${path}/tmpoutput2.txt
done

cp ${filesToFinds[0]} ${typeofsample}_log10foldchangefrom_${typeofsample2}.txt
paste lastnumfile2.tmp ${typeofsample}_log10foldchangefrom_${typeofsample2}.txt > o.tmp
mv o.tmp ${typeofsample}_log10foldchangefrom_${typeofsample2}.txt
paste tmpoutput2.txt ${typeofsample}_log10foldchangefrom_${typeofsample2}.txt > fin.tmp
mv fin.tmp ${typeofsample}_log10foldchangefrom_${typeofsample2}.txt
awk 'BEGIN{FS="\t";OFS="\t"}{print $3,$6,$7,$8,$2,$1}' ${typeofsample}_log10foldchangefrom_${typeofsample2}.txt > ${typeofsample}_log10foldchangefrom_${typeofsample2}.tsv
echo -e "Chrom\tProtI \tDesc\tMean${filesToFinds[0]}\tMean${filesToFinds[1]}\tFoldChange" | cat - ${typeofsample}_log10foldchangefrom_${typeofsample2}.tsv > tmp && mv tmp ${typeofsample}_log10foldchangefrom_${typeofsample2}.tsv

echo printed it! final file is called ${typeofsample}_log10foldchangefrom_${typeofsample2}.tsv
