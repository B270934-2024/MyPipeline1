#!/bin/bash
echo -e "\nPlease type the path to the FASTA files\nThis will initially assess the quality of the files.\n"
read path
cd $path
rm -f results.tsv
rm -f results.txt

touch results.tsv
mkdir $path/Output

FileList=($(ls *.fq.gz))
##all files in the selected folder that end in fq.gz##

echo -e "\nAre these files paired or unpaired?\nType [u] or [p]\n"
read pairing


if [ $pairing == "u" ]
then
for Files in ${FileList[@]}; do
        echo Processing $Files
        ###let the user know we are looking at this one file first.
        fastqc -o $path/Output $Files -q
        FileJustName=$(echo "${Files}"|sed 's/\.fq\.gz$//')
        echo ${FileJustName}
        cd ${path}/Output
        unzip -qqo ${FileJustName}_fastqc.zip
	cd ${path}/Output/${FileJustName}_fastqc
	awk -v fjn=$FileJustName 'BEGIN {FS = "\t"; OFS = "\t";}
        {if($1=="FAIL"){print fjn,$1,$2;}}' summary.txt >> $path/Output/results.tsv
        awk -v fjn=$FileJustName '
        {if($1==">>Basic"){print fjn,$1,$2,"\t",$3;}}
        {if($1=="Sequences" && $2=="flagged"){print fjn,$4,$5,"\t",$6}}
        {if($1==">>Per"){print fjn,$1,$2,$3,$4,"\t",$5}}
        {if($1==">>Sequence"){print fjn,$1,$2,$3,$4,"\t",$5}}
        {if($1==">>Overrepresented"){print fjn,$1,$2,"\t",$3}}' fastqc_data.txt >>$path/Output/results.tsv
        awk -v fjn=$FileJustName '{if($NF=="fail"){print "\n",fjn,"Fails a test! Check results.\n Test failed is:",$0}}' fastqc_data.txt
	awk -v fjn=$FileJustName 'BEGIN {count=0} {if($NF=="fail"){count++}} END
       	{if(count>=4){print "We recommend deletion of ",fjn,"as it has failed ",count," tests."}}' fastqc_data.txt
        touch flag
	echo "del" > flag
	awk -v fjn=$FileJustName 'BEGIN {count=0} {if($NF=="fail"){count++}}END {if(count>=4){print "Del\nDel\nDel"}}' fastqc_data.txt > flag
	wc -l < flag
	if [ $(wc -l < flag) -gt 1 ] 
	then
         	cd ${path}
		rm -i $Files
        fi
        cd ${path}/Output
	rm -rf ${FileJustName}_fastqc 
        rm -rf *.html
        rm -rf flag
     	cd $path
done
##### Above, the files are all awked, to sort through the files and print whatever fails. Below, its the same.
elif [ $pairing == "p" ]
	then
	FileList=($(ls *_1.fq.gz))

	for Files in ${FileList[@]}; do
		echo Processing $Files
                ###let the user know we are looking at this one file first.
		FileJustName=$(echo "${Files}"|sed 's/\_1\.fq\.gz$//')
		fastqc -o $path/Output ${FileJustName}_1.fq.gz ${FileJustName}_2.fq.gz -q
		echo ${FileJustName}
		cd ${path}/Output
       		echo ${path}/Output
		unzip -qqo ${FileJustName}_1_fastqc.zip
		unzip -qqo ${FileJustName}_2_fastqc.zip
        	cd ${path}/Output/${FileJustName}_2_fastqc
        	awk -v fjn=$FileJustName 'BEGIN {FS = "\t"; OFS = "\t"}	{if($1=="FAIL"){print fjn,$1,$2;}}' summary.txt >> $path/results.tsv
        	awk -v fjn=$FileJustNam unzip -qqo ${FileJustName}_1_fastqc.zip
                unzip -qqo ${FileJustName}_2_fastqc.zip
		awk -v fjn=$FileJustName 'BEGIN {FS = "\t"; OFS = "\t";}
        	{if($1==">>Basic"){print fjn,$1,$2,"\t",$3;}}
        	{if($1=="Sequences" && $2=="flagged"){print fjn,$4,$5,"\t",$6}}
		{if($1==">>Per"){print fjn,$1,$2,$3,$4,"\t",$5}}
		{if($1=="Total"){print fjn,$1,$2,"\t",$3}}
		{if($1==">>Sequence"){print fjn,$1,$2,$3,$4,"\t",$5}}
        	{if($1==">>Overrepresented"){print fjn,$1,$2,"\t",$3}}' fastqc_data.txt >>${path}/Output/results.tsv
        	awk -v fjn=$FileJustName '{if($NF=="fail"){print "\n",fjn,"Fails a test! Check results.\n Test failed is:",$0}}' fastqc_data.txt
        	awk -v fjn=$FileJustName 'BEGIN{count=0}{if($NF=="fail"){count++}} {if(count>=4){print "We recommend deletion of ",fjn,"as it has failed ",count," tests."}}' fastqc_data.txt
        	touch flag
		echo "del" > flag
       		awk -v fjn=$FileJustName 'BEGIN {count=0} {if($NF=="fail"){count++}}END {if(count>=4){print "Del\nDel\nDel"}}' fastqc_data.txt > flag
	        if [ $(wc -l < flag) -gt 1 ]
	       	then
               		cd ${path}
                	rm -i ${files}
        	fi
        	cd ${path}/Output
        	rm -rf ${FileJustName}_fastqc
	        rm -rf *.html
       		rm -rf flag
        	echo ${FileJustName}
        	cd ${path}/Output
        	cd ${path}/Output/${FileJustName}_2_fastqc
        	awk -v fjn=$FileJustName 'BEGIN {FS = "\t"; OFS = "\tfastqc_data.txt "} {if($1=="FAIL"){print fjn,$1,$2;}}' summary.txt >> $path/results.tsv
	        awk -v fjn=$FileJustName '
	        {if($1==">>Basic"){print fjn,$1,$2,"\t",$3;}}
	        {if($1=="Sequences" && $2=="flagged"){print fjn,$4,$5,"\t",$6}}
       		{if($1==">>Per"){print fjn,$1,$2,$3,$4,"\t",$5}}
        	{if($1==">>Sequence"){print fjn,$1,$2,$3,$4,"\t",$5}}
        	{if($1==">>Overrepresented"){print fjn,$1,$2,"\t",$3}}' fastqc_data.txt >>$path/Output/results.tsv
        	awk -v fjn=$FileJustName '{if($NF=="fail"){print "\n",fjn,"Fails a test! Check results.\n Test failed is:",$0}}' fastqc_data.txt
        	awk -v fjn=$FileJustName 'BEGIN {count=0}{if($NF=="fail"){count++}} END {if(count>= 4){print "We recommend deletion of ",fjn,"as it has failed ",count," tests."}}' fastqc_data.txt
        	touch flag
		echo "del" > flag
		awk -v fjn="$FileJustName" 'BEGIN {count=0} {if($NF=="fail"){count++}} END {if(count>=4){print "Del\nDel\nDel"}}' fastqc_data.txt > flag
		if [ $(wc -l < flag) -gt 1 ]
	       	then
               		cd $path
                 	rm -i $files
        	fi
        	cd $path/Output
       		rm -rf ${FileJustName}_fastqc
        	rm -rf *.html
        	rm -rf flag
        	cd $path
done
fi
echo -e "\n\n\nAll files now processed! View results.txt in your FASTA folder. For more details, the fastqc_data.txt file, or the fastqc_report.html file."
