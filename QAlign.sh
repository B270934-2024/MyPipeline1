#!/bin/bash
echo -e "\nPlease type the path to the FASTA files\nThis will align all paired files in the given directory.\n"
read path
echo -e "\nPlease type the path to the genome you wish to align the FASTA files to."
read pathGenome
cd $path
rm -f Alignment.tsv
mkdir -p $path/Output
FileList=($(ls *_1.fq.gz))
cd $pathGenome
Genome=($(ls *.fasta.gz))
rm processed
#bowtie2-build $pathGenome/$Genome index
cd $path/Output
for Files in ${FileList[@]}; do
	CoreFileJustName=$(echo "${Files}"| sed 's/_1\.fq\.gz$//')
	echo $path/${CoreFileJustName}_1.fq.gz","${path}/${CoreFileJustName}_2.fq.gz >> commaseparated        
done
touch processed
awk 'BEGIN{FS = ","}{print "-1 ",$1,"-2 "$2}' commaseparated > processed
rm -f output.sam
x=0
while read -r line; do
	CoreFileJustName=$(echo "${line}"|awk '{print $2}'| sed 's/_1\.fq\.gz$//')
	cd $path/Output
	echo "Processing $CoreFileJustName"
	bowtie2 -q -x $pathGenome/index ${line} -S ${CoreFileJustName}.sam
	mv ${CoreFileJustName}.sam $path/Output
	chmod 777 ${output}.sam
	echo "Processed file $CoreFileJustName..."
done < processed
cd $path/Output
samlist=($(ls *.sam))
for file in ${samlist[@]}; do
	echo Converting file to bam
	output=$(echo "$file"| sed 's/\.sam$//')
	samtools view -b -o ${output}.bam ${output}.sam
	chmod 777 ${output}.sam
	samtools sort -o ${output}.sorted.bam ${output}.bam
	chmod 777 ${output}.sorted.bam
	echo Converted!
done
echo -e "BAM files created. Attempting to create some statistics now..."
echo -e "Please specify your bed file location."
read bedpath
cd $bedpath
bed=($(ls *.bed))
cd $path/Output
bamlist=($(ls *.sorted.bam))
for file in ${bamlist[@]}; do
	output=$(echo "$file"| sed 's/\.sorted.\bam$//')
	echo Processing ${output}...
	bedtools coverage -a ${bedpath}/${bed[@]} -b ${path}/Output/$file -counts > ${output}_finalOutputCountsMeanCoverage.txt
	echo Processed!
done
rm -f processed
rm -f commaseparated
rm -f *.bam
rm -f combinedCountsMatrix.txt
echo -e Chromosome\tStartPosition\tEndPosition\tFeatureID\tDescription\tReadCounts > combinedCountsMatrix.txt
paste *_finalOutputCountsMeanCoverage.txt >> combindedCountsMatrix.txt
echo "All files processed and aligned."
