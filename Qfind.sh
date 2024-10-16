#!/bin/bash
cd /localdisk/home/s2761220/MyFirstPipeline/fastq
echo -e "Please specify where your final output files are.\n"
read outputpath
cd ${outputpath}
echo -e "Please specify where your description file is"
read desc
descfile=($(ls *.fqfiles))
allbams=$(ls *.sorted.bam_finalOutputCountsCoverage.txt)
#This runs through and finds appends the mean number based on the repeats to the end of the file.
for file in ${allbams[@]};do
	chmod 777 ${file}
	cd ${outputpath}
	touch ${outputpath}/numbers_to_add.tmp
	fileJustName=$(echo "${file}" | sed 's/\.sorted\.bam\_finalOutputCountsCoverage\.txt$//')
	awk '{print $NF}' ${file} > ${outputpath}/numbers_to_add.tmp
	fileNoDash=$(echo "${fileJustName}" | sed 's/-//')
	echo -e $fileNoDash processing...
	awk -v fjn=$fileNoDash 'BEGIN {FS="\t"} {if($1 == fjn) {print $3}}' ${desc}/${descfile} > numberofrepeats.tmp
	numofrepeats=$(cat numberofrepeats.tmp)
	awk -v repeats="${numofrepeats}" '{print $1/repeats}' ${outputpath}/numbers_to_add.tmp >${outputpath}/${fileJustName}_means.txt
	echo -e Chromosome\tStart\tEnd\tProteinCode\tDescription\tRawCounts\tMeanCounts > ${outputpath}/combined_${fileJustName}.txt
	paste ${file} ${outputpath}/${fileJustName}_means.txt > ${outputpath}/combined_${fileJustName}.txt
done
echo -e All processed!
rm -f *.tmp
