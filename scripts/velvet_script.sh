

SAMPLE=$(echo $1 | cut -d '/' -f 6 | cut -d '.' -f 1)
NEWNAME=${SAMPLE/_R*_l/_ll}

for i in `seq $2 2 $3`; do
    echo "Beginning run $i..."
    velveth $NEWNAME.$i $i -fastq -shortPaired $1;
    velvetg $NEWNAME.$i -exp_cov auto -cov_cutoff auto -scaffolding no;
    echo "Run $i complete!"
done

python ./$4/velvet/assemstats3.py 200 ./$NEWNAME.*/contigs.fa
cp -r ./$NEWNAME.* ./$4/velvet/contig_files
rm -r ./$NEWNAME.*