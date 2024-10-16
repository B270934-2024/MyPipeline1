#!/bin/bash
echo -e "Please type the location of your output files here."
read path
echo -e "Please type the location of your descriptor file here."
read descpath
cd ${descpath}
###Find the places where the files are located.
fqfile=$(ls *.fqfiles)
awk 'BEGIN{FS="\t";OFS="_"}{print $1,"\t"$2,$4,$5,"\t",$6,"\t",$7,"\t",$3}' ${fqfile} > ${fqfile}.sorted.fqfiles
awk 'BEGIN{FS="_\t_";OFS="\t"}{print $1,$2,$3,$4}' ${fqfile}.sorted.fqfiles > listoffiles.txt
###sort out the description file into an easier to read list.
cd ${path}
allfiles=$(ls combined_*.txt)
###Find all of the files and put them into an array
rm -f lastnumfile1.tmp
rm -f lastnumfile2.tmp
rm -f *.tmp
#Delete our temporary files
echo -e "Please type the Condition A that you want. The following types are available:"
awk 'BEGIN{FS="\t"}; {if($3 != "End1"){print $2}}' ${descpath}/listoffiles.txt | sort | uniq
#Show only the unique files that are not the header
read typeofsample
echo -e "Please type the Condition B that you want. The preceding types are available."
read typeofsample2
echo -e "Which replicants do you want: 1, 2 or 3?"
read replic
rm -f filesToFind.tmp
awk -v fjn=$file -v type=$typeofsample '{if($2==type) {print $1}}' ${descpath}/listoffiles.txt >> filesToFind.tmp
awk -v fjn=$file -v type=$typeofsample2 '{if($2==type) {print $1}}' ${descpath}/listoffiles.txt >> filesToFind.tmp
filesToFind=$(cat filesToFind.tmp)
#Shows Find all of the files that meet our criteria
rm -f filesrec.tmp
for file in ${filesToFind[@]}; do
	file=$(echo $file|sed 's/_$//')
	filewithhyphen="${file:0:3}-$(echo "${file:3}")"
	filenamereconstructed="combined_"$filewithhyphen".txt"
	echo $filenamereconstructed
done > filesrec.tmp
#Reconstruct the file names by adding a hyphen after the third character. This could be replaced with a Sed command to find the one after the letters stop.
filesToFinds=($(cat filesrec.tmp))
cd ${path}
echo file 1 ${filesToFinds[-1+$replic]}
echo file 2 ${filesToFinds[2+$replic]}
#Show to the user which two files we are combining together
rm -f tmpoutput2.txt
touch ${typeofsample}_log10foldchangefrom_${typeofsample2}.txt
awk 'BEGIN{FS="\t";OFS="\t"}{print $NF}' ${filesToFinds[-1+$replic]} > lastnumfile1.tmp
awk 'BEGIN{FS="\t";OFS="\t"}{print $NF}' ${filesToFinds[2+$replic]} > lastnumfile2.tmp
#Place our means from the chosen files into a temporary file
counter=0
linecount=$(wc -l < lastnumfile1.tmp)
paste lastnumfile1.tmp lastnumfile2.tmp | while read -r File1Mean File2Mean; do
	if [[ $File1Mean != 0 && $File2Mean != 0 ]]; then
		fold_change=$(echo "scale=5;l($File2Mean/$File1Mean)/l(10)"|bc -l)
		counter=$((counter + 1))
		echo Processed $counter of $linecount Fold change = $fold_change
	else
		counter=$((counter +1))
		fold_change="N/A"
		echo Processed $counter of $linecount Fold change = $fold_change
	fi
	echo $fold_change >> ${path}/tmpoutput2.txt
done
#Here's the complex stuff. Read both files line by line, with file1 mean being the first and file2 mean being the second. This then
#will go through this, check if mean 1 and mean 2 are not 0, if they are not zero, we use bc (basic calculator)'s l (log) function to 
#get a log10 value of the means, which is log10 fold change.

cp ${filesToFinds[-1+$replic]} ${typeofsample}_log10foldchangefrom_${typeofsample2}.txt
paste lastnumfile2.tmp ${typeofsample}_log10foldchangefrom_${typeofsample2}.txt > o.tmp
mv o.tmp ${typeofsample}_log10foldchangefrom_${typeofsample2}.txt
paste tmpoutput2.txt ${typeofsample}_log10foldchangefrom_${typeofsample2}.txt > fin.tmp
mv fin.tmp ${typeofsample}_log10foldchangefrom_${typeofsample2}.txt
awk 'BEGIN{FS="\t";OFS="\t"}{print $3,$6,$7,$8,$2,$1}' ${typeofsample}_log10foldchangefrom_${typeofsample2}.txt > ${typeofsample}_log10foldchangefrom_${typeofsample2}.tsv
#This initially puts the files together, putting the second mean files in, then the fold change files (tmpoutput2.txt) come in after
#This is then awked into a new file, the final .tsv file. This prints the names in order of: chromosome, protein id, description, means from the original file
#means from the file we are comparing it to, then the fold change.

echo -e "Chrom\tProtID\tDesc\tMean${filesToFinds[-1+$replic]}\tMean${filesToFinds[2+$replic]}\tFoldChange" | cat - ${typeofsample}_log10foldchangefrom_${typeofsample2}.tsv > tmp && mv tmp ${typeofsample}_log10foldchangefrom_${typeofsample2}.tsv
#This adds a header onto the file to let a human read it better.

#Finally, we are done, and we inform the user.
echo printed it! final file is called ${typeofsample}_log10foldchangefrom_${typeofsample2}.tsv
