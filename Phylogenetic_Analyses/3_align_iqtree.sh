#!/bin/bash

mafft --thread 8 --auto all_giraffe_PC_genes.fasta > aligned_giraffe_mt.fasta

iqtree -s aligned_giraffe_mt.fasta -m MFP+CODON -B 1000 -alrt 1000 --prefix giraffe_mt_phylo
