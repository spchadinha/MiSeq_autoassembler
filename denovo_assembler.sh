
# Arguments from denovo_analysis.sh
PPATH=$1 # Project path
# Trim file names
TRIM1=$2 
TRIM2=$3
KSTART=$4 # Starting k-mer value
KEND=$5 # Final k-mer value
NUMRAND=$6 # Number of extractions
NUM=$7 # Run number in file name

# Generate file names for extraction files and interweaved file
RAND1=${TRIM1/.fastq/"_"$NUMRAND".fastq"}
RAND2=${TRIM2/.fastq/"_"$NUMRAND".fastq"}
S=${RAND1/.fastq/"_combined.fastq"}
SHUFFLE=${S/_$NUM_/"_"}

# Run the extraction program and move output to the temp sub-directory
echo "Extracting sample of reads..."
python ./$PPATH/extractions/extract_random_PE_reads.py ./$PPATH/extractions/$TRIM1 ./$PPATH/extractions/$TRIM2 ./$PPATH/extractions/$RAND1 ./$PPATH/extractions/$RAND2 $NUMRAND
cp ./$PPATH/extractions/$RAND1 ./$PPATH/extractions/temp
cp ./$PPATH/extractions/$RAND2 ./$PPATH/extractions/temp
echo "Done!"

# Move the contents of extractions/temp into the velvet directory and run interweaving program. Move results into velvet/temp
echo "Interweaving random read files..."
cp ./$PPATH/extractions/temp/$RAND1 ./$PPATH/velvet
cp ./$PPATH/extractions/temp/$RAND2 ./$PPATH/velvet
cp ./scripts/shuffle_seqs_fastq.py ./$PPATH/velvet
python ./$PPATH/velvet/shuffle_seqs_fastq.py ./$PPATH/extractions/$RAND1 ./$PPATH/extractions/$RAND2 ./$PPATH/velvet/$SHUFFLE
cp ./$PPATH/velvet/$SHUFFLE ./$PPATH/velvet/temp
rm ./$PPATH/velvet/$RAND1
rm ./$PPATH/velvet/$RAND2
echo "Done!"

# Run velvet on the files in the velvet/temp directory
echo "Beginning velvet runs...."
cp ./scripts/velvet_script.sh ./$PPATH/velvet
cp ./scripts/assemstats3.py ./$PPATH/velvet
chmod 755 ./$PPATH/velvet/velvet_script.sh
./$PPATH/velvet/velvet_script.sh ./$PPATH/velvet/$SHUFFLE $KSTART $KEND $PPATH

# Remove files from all temp folders to make way for the next run
rm ./$PPATH/extractions/temp/*.fastq
rm ./$PPATH/velvet/temp/*.fastq


