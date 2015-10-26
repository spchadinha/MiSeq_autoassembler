#!/usr/bin/env python2.7

import sys
import itertools
from Bio.SeqIO.QualityIO import FastqGeneralIterator
from Bio import SeqIO
from Bio.Seq import Seq
import random


# in and out
read_pair1 = sys.argv[1]
read_pair2 = sys.argv[2]
read_pair1_out = open(sys.argv[3], "w")
read_pair2_out = open(sys.argv[4], "w")

# how many
number_to_sample = int(sys.argv[5])

# total number of reads
with open(read_pair1) as input:
    num_lines = sum((1 for line in input))
num_records = num_lines / 4

# make read files iterable
f_iter1 = FastqGeneralIterator(open(read_pair1))
f_iter2 = FastqGeneralIterator(open(read_pair2))

records_to_keep = set(random.sample(xrange(num_records + 1), number_to_sample))

record_number = 0
records_used = 0
for (title1, seq1, qual1), (title2, seq2, qual2) in itertools.izip(f_iter1,f_iter2): #izip does lock step interator
    if records_used < number_to_sample:
        if record_number in records_to_keep:
            read_pair1_out.write("@%s\n%s\n+\n%s\n" % (title1, seq1, qual1))
            read_pair2_out.write("@%s\n%s\n+\n%s\n" % (title2, seq2, qual2))
            records_used += 1
        record_number += 1


