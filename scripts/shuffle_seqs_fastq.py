#!/usr/bin/env python

import sys
import itertools
from Bio.SeqIO.QualityIO import FastqGeneralIterator

readPair1 = open(sys.argv[1])
readPair2 = open(sys.argv[2])

shuffled_out = open(sys.argv[3], "w")
#filteredReadPair1 = open("out_reads1.fastq", "w")
#filteredReadPair2 = open("out_reads2.fastq", "w")

f_iter1 = FastqGeneralIterator(readPair1)
f_iter2 = FastqGeneralIterator(readPair2)

seq1_lens = []
seq2_lens = []

# length
for (title1, seq1, qual1), (title2, seq2, qual2) in itertools.izip(f_iter1,f_iter2): #izip does lock step interator
    shuffled_out.write("@{0}\n{1}\n+\n{2}\n@{3}\n{4}\n+\n{5}\n".format(title1, seq1, qual1, title2, seq2, qual2))
    



#filteredReadPair1.close()
#filteredReadPair2.close()
readPair1.close()
readPair2.close()
