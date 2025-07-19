#!/bin/bash
#SBATCH --time=1:00:00
#SBATCH -n 1
#SBATCH --mem=20g
#SBATCH -p aces
#SBATCH --output=slurm_%A_%a.out
#SBATCH --error=slurm_%A_%a.err
#SBATCH --job-name=Froh

# Input and output directories
INPUT_DIR="/projects/illinois/aces/ansci/roca/wesley/results/2024-11-13-combined-vcf-prune/"
PLINK_INPUT="${INPUT_DIR}/combined_plink_data"
OUTPUT_DIR="/projects/illinois/aces/ansci/roca/wesley/analysis/roh/combined/roh_inbreeding"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Calculate inbreeding coefficients
echo "Calculating inbreeding coefficients..."
plink --bfile "$PLINK_INPUT" --het --out "${OUTPUT_DIR}/inbreeding_data"

# Calculate Runs of Homozygosity (ROH)
echo "Calculating Runs of Homozygosity (ROH)..."
plink --bfile "$PLINK_INPUT" --homozyg \
  --homozyg-window-snp 50 \
  --homozyg-window-het 1 \
  --homozyg-gap 1000 \
  --homozyg-kb 500 \
  --homozyg-window-threshold 0.05 \
  --homozyg-het 0 \
  --homozyg-density 50 \
  --homozyg-snp 50 \
  --out "${OUTPUT_DIR}/roh_data"


echo "ROH analysis completed successfully."

