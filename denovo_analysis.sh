#!/bin/bash

# shl     : denovo_analysis.sh
# purpose : performs de novo analysis of MiSeq data using velvet
# revised : YYYY-MM-DDThh:mm:ss
# author  : Spencer Chadinha
# notes   : Each line below is a "name-value-pair" meaning each contains (3) elements 
#           -- 1) a KEYWORD  followed by a 2) DELIMITER, followed by (3), a VALUE
#

# Time of program initiation
STARTTIME=$(date +%s)

# Parameters file
RIP_INPUTS=analysis_params.rip

# 1) verify existence of runtime-input-parameters (RIP) file supplying the
# configuration details for this script
if [ ! -f $RIP_INPUTS ] ; then
 echo "Cannot find required runtime inputs config file " $RIP_INPUTS
  exit -1
fi

k=1
# Reads the RIP file line by line, and parses it for (2) tokens, KEYWORD and VALUE
while read line ; 
  do
   KEYWORD="PLACEHOLDER"
   VALUE="0"

  line=`echo $line | grep -v '^#' `
  lineLength=${#line}
  
  if [ $lineLength -ge 2 ] ; then 
    KEYWORD=`echo $line | awk '{ print $1}' `
    VALUE=`echo $line | awk '{ print$2}'`
  fi

  # use KEYWORD, in order to parse out VALUE..
  if [ $KEYWORD  ==  "FILE1" ] ; then
    cp /gs0/LV/MVHPI/MVHPI_MISEQ/MiSeqData/$PATHNAME/FASTQ/$VALUE ./ # immediately copy zip file to cwd
     FILE1=$VALUE
  elif [ $KEYWORD  =  "FILE2" ] ; then
    cp /gs0/LV/MVHPI/MVHPI_MISEQ/MiSeqData/$PATHNAME/FASTQ/$VALUE ./ # immediately copy zip file to cwd
     FILE2=$VALUE
  elif [ $KEYWORD =  "LEN" ] ; then 
     LEN=$VALUE
  elif [ $KEYWORD = "QUAL" ] ; then
     QUAL=$VALUE
  elif [ $KEYWORD = "NUMREAD" ] ; then
     NUMREAD=$VALUE
  elif [ $KEYWORD = "PATHNAME" ] ; then
     PATHNAME=$VALUE
  elif [ $KEYWORD = "KSTART" ] ; then
     KSTART=$VALUE
  elif [ $KEYWORD = "KEND" ] ; then
     KEND=$VALUE
  fi
 
  # 5) Increment counter to next parameter
  ((k++))
done < $RIP_INPUTS
#

# Generate all necessary file names from the given input file name
NUM1=$(echo $FILE1 | cut -d '_' -f 4) # Run number
NUM2=$(echo $FILE2 | cut -d '_' -f 4) # Run number
SUBJ=$(echo $FILE1 | cut -d '_' -f 1) # Name of organism genome being assembled
WHEN=$(date +"%F_%T") # Time and date of current run

# Fastq file names
FASTQ1=${FILE1/.fastq.gz/.fastq}
FASTQ2=${FILE2/.fastq.gz/.fastq}
# Trimmed file names
TRIM1=${FASTQ1/_*./"_"$NUM1"_len"$LEN"_q"$QUAL"."}
TRIM2=${FASTQ2/_*./"_"$NUM2"_len"$LEN"_q"$QUAL"."}
# Extraction file names
RAND1=${TRIM1/.fastq/"_"$NUMREAD".fastq"}
RAND2=${TRIM2/.fastq/"_"$NUMREAD".fastq"}
# Interweaved read file name
S=${RAND1/.fastq/"_combined.fastq"}
SHUFFLE=${S/_$NUM1_/"_"}

##########################################
# Generate directory tree for current run
##########################################

if [ ! -d ./$PATHNAME ] ; then
	echo "Creating new subdirectory: $PATHNAME"
	mkdir ./$PATHNAME
fi
if [ ! -d ./$PATHNAME/$SUBJ ] ; then
	echo "Creating new subdirectory: $SUBJ"
	mkdir ./$PATHNAME/$SUBJ
fi
if [ ! -d ./$PATHNAME/$SUBJ/$WHEN ] ; then
	echo "Creating new subdirectory: $WHEN"
	mkdir ./$PATHNAME/$SUBJ/$WHEN
fi

PPATH=$PATHNAME/$SUBJ/$WHEN # Path to the current projects directory tree

if [ ! -d ./$PPATH/raw_reads ] ; then
	echo "Creating new subdirectory: raw_reads"
	mkdir ./$PPATH/raw_reads
fi

if [ ! -d ./$PPATH/fastqc ] ; then
	echo "Creating new subdirectory: fastqc"
	mkdir ./$PPATH/fastqc
fi

if [ ! -d ./$PPATH/trimming ] ; then
	echo "Creating new subdirectory: trimming"
	mkdir ./$PPATH/trimming
fi

if [ ! -d ./$PPATH/extractions ] ; then
	echo "Creating new subdirectory: extractions"
	mkdir ./$PPATH/extractions
fi
if [ ! -d ./$PPATH/extractions/temp ] ; then
	echo "Creating new subdirectory: extractions/temp"
	mkdir ./$PPATH/extractions/temp
fi

if [ ! -d ./$PPATH/velvet ] ; then
	echo "Creating new subdirectory: velvet"
	mkdir ./$PPATH/velvet
fi
if [ ! -d ./$PPATH/velvet/contig_files ] ; then
	echo "Creating new subdirectory: velvet/contig_files"
	mkdir ./$PPATH/velvet/contig_files
fi
if [ ! -d ./$PPATH/velvet/temp ] ; then
	echo "Creating new subdirectory: velvet/temp"
	mkdir ./$PPATH/velvet/temp
fi

###################################
# Generate Directory Tree Complete
###################################

###################################
# Process MiSeq Data
###################################

# Move zip files to raw_reads folder
mv ./$FILE1 ./$PPATH/raw_reads
mv ./$FILE2 ./$PPATH/raw_reads

# Unzip raw read files
echo "Unzipping files..."
gunzip -f ./$PPATH/raw_reads/$FILE1
gunzip -f ./$PPATH/raw_reads/$FILE2
echo "Done!"

# Generate fastqc files with read quality information
echo "Copying all .fastq files to fastqc directory and generating quality data..."
cp ./$PPATH/raw_reads/*.fastq ./$PPATH/fastqc
fastqc ./$PPATH/fastqc/*.fastq
echo "Done!"

# Trim read files
echo "Copying all files into trimming directory..."
cp ./$PPATH/fastqc/*.fastq ./$PPATH/trimming
cp ./scripts/process_illumina_PE_wqual.py ./$PPATH/trimming
rm ./$PPATH/fastqc/$FASTQ1
rm ./$PPATH/fastqc/$FASTQ2
echo "Done!"

echo "Beginning Trimming..."
python ./$PPATH/trimming/process_illumina_PE_wqual.py ./$PPATH/trimming/$FASTQ1 ./$PPATH/trimming/$FASTQ2 ./$PPATH/trimming/$TRIM1 ./$PPATH/trimming/$TRIM2 $LEN $QUAL
rm ./$PPATH/trimming/$FASTQ1
rm ./$PPATH/trimming/$FASTQ2
echo "Done!"

# Move trimmed files into the extractions folder
cp ./scripts/extract_random_PE_reads.py ./$PPATH/extractions
cp ./$PPATH/trimming/$TRIM1 ./$PPATH/extractions
cp ./$PPATH/trimming/$TRIM2 ./$PPATH/extractions

# Run the extraction program for every specified number of extractions 
for ext in ${NUMREAD//-/ } ; do
  ./denovo_assembler.sh $PPATH $TRIM1 $TRIM2 $KSTART $KEND $ext $NUM1
done

# Copy the .rip file into the current run's path for record keeping
cp ./analysis_params.rip ./$PPATH

# Print elapsed time to the console
ENDTIME=$(date +%s)
echo "Elapsed Time: $(($ENDTIME-$STARTTIME))"