# MiSeq_autoassembler
This package will take the raw read data from a MiSeq next generation sequencing device and generate a de novo
assembly of the reads using Velvet.


Dependencies: fastqc, velvet


The package is currently specific to the creators directory structure as the raw read path name is hard coded into 
the denovo_analysis.sh file.


Usage Instructions:
All user specified parameters are set in the analysis_params.rip file. To alter the default parameters, simply
repalce the current parameter with new values - taking care not to change the spacing between the variable name and the 
value. 

Once the parameters are set to your liking, navigate to into your repository and input "./denovo_analysis.sh" to the 
command line.

The package will generate a directory structure based on the MiSeq run, sequence name, and initiation time. Thus all 
every instance of this package will be separated by time.
