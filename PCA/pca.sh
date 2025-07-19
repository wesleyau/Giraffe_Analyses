#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH -n 1
#SBATCH --mem=20g
#SBATCH -p aces
#SBATCH --output=slurm_%A_%a.out
#SBATCH --error=slurm_%A_%a.err
#SBATCH --job-name=pca

INPUT_DIR="/projects/illinois/aces/ansci/roca/wesley/results/2024-11-13-combined-vcf-prune/combined"
PLINK_INPUT="${INPUT_DIR}/combined_pruned_plink_data"
PLINK_OUTPUT_DIR="/projects/illinois/aces/ansci/roca/wesley/analysis/pca_combined"
PCA_OUTPUT="${PLINK_OUTPUT_DIR}/pca_output_combined"

# Create output directory if it doesn't exist
mkdir -p $PLINK_OUTPUT_DIR

# Run PCA using PLINK
echo "Running PCA with PLINK..."
plink --bfile $PLINK_INPUT --allow-extra-chr --pca 5 --out $PCA_OUTPUT

echo "VCF to PLINK conversion, PCA, and ADMIXTURE analysis completed. Check the output in ${PLINK_OUTPUT_DIR}."
