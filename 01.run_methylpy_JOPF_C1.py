#!/usr/bin/python2.7
from methylpy.call_mc import call_methylated_sites_pe
from methylpy.call_mc import run_methylation_pipeline_pe
import os

sample="JOPF_C1"
fastq_dir="/cndd/projects/Public_Datasets/JOPF/JOPF/"

fastq_R1 = [fastq_dir+sample+".1.fastq.gz"]
fastq_R2 = [fastq_dir+sample+".2.fastq.gz"]

libraries=["libA"]

#Revise here for different reference
f_ref = "/cndd/projects/genomes/mm10/mm10_C57BL6_f"
r_ref = "/cndd/projects/genomes/mm10/mm10_C57BL6_r"
fasta_ref = "/cndd/projects/genomes/mm10/mm10_C57BL6.fasta"

#Number of processors to use
np = 8

# os.remove('*.tsv')

run_methylation_pipeline_pe(read1_files=fastq_R1, read2_files=fastq_R2,
libraries=libraries, sample=sample,
forward_reference = f_ref,
reverse_reference = r_ref,
reference_fasta = fasta_ref,
unmethylated_control="chrL:", path_to_samtools='', path_to_bowtie='',
num_procs=np, min_cov=3,
sig_cutoff=0.01, binom_test=True, bh=True, sort_mem='2G', trim_reads=False)
"""
call_methylated_sites_pe(fastq_dir+sample+"_processed_reads_no_clonal.bam",
sample,
fasta_ref,
"chrL:","1.8",num_procs=np,binom_test=True,sort_mem='2G',bh=True,sig_cutoff=0.01,min_cov=3)
"""
