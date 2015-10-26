#!/usr/bin/env python2.7

import sys
import itertools
from Bio.SeqIO.QualityIO import FastqGeneralIterator
from Bio import SeqIO
from Bio.Seq import Seq


#if len(sys.argv) is not 5:
#    sys.exit("usage:  script.py <in pair 1> <in pair 2> <out trimmed 1> <out trimmed 2>")


# in and out
print sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6]

LENGTH = int(sys.argv[5])
QUAL = int(sys.argv[6])
BARCODE_LENGTH = 5


read_pair1 = open(sys.argv[1])
read_pair2 = open(sys.argv[2])

filtered_read_pair1_out = open(sys.argv[3], "w")
filtered_read_pair2_out = open(sys.argv[4], "w")

# make read files iterable
f_iter1 = FastqGeneralIterator(read_pair1)
f_iter2 = FastqGeneralIterator(read_pair2)

count = 0
loops = 0
print "    Iterating in lock step..."
for (title1, seq1, qual1), (title2, seq2, qual2) in itertools.izip(f_iter1,f_iter2): #izip does lock step interator
    if loops % 100000 == 0:
        print "      Processed %d lines..." % (loops)
    loops += 1
    # check the Casava pass/fail filter
    if "1:N:0" in title1 and "2:N:0" in title2:
        seq1_len = seq1[BARCODE_LENGTH - 1:(LENGTH + BARCODE_LENGTH - 1)]
        seq2_len = seq2[BARCODE_LENGTH - 1:(LENGTH + BARCODE_LENGTH - 1)]
            
        if "N" not in seq1_len and "N" not in seq2_len:
            count += 1
            seq1_flag = 0
            seq2_flag = 0
            qual1_len = qual1[BARCODE_LENGTH - 1:(LENGTH + BARCODE_LENGTH - 1)]
            qual2_len = qual2[BARCODE_LENGTH - 1:(LENGTH + BARCODE_LENGTH - 1)]
            
            # notes about adjusting quality
            # solexa ->  solexa + 64   old
            # Illumina 1.3 and 1.5 ->  Phred + 64    old
            # Illumina 1.8 -> Phred + 33    current
            
            for i in qual1_len:
                if ord(i)-33 < QUAL:
                    seq1_flag += 1
                    
            for i in qual2_len:
                if ord(i)-33 < QUAL:
                    seq2_flag += 1
            
            if seq1_flag == 0 and seq2_flag == 0:
                filtered_read_pair1_out.write("@%s\n%s\n+\n%s\n" % (title1, seq1_len, qual1_len))
                filtered_read_pair2_out.write("@%s\n%s\n+\n%s\n" % (title2, seq2_len, qual2_len))


filtered_read_pair1_out.close()
filtered_read_pair2_out.close()
read_pair1.close()
read_pair2.close()

