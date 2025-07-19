#!/bin/bash
#SBATCH --job-name=circlator_captive
#SBATCH --output=log/circlator_captive_%A_%a.out
#SBATCH --error=log/circlator_captive_%A_%a.err
#SBATCH --time=24:00:00
#SBATCH --mem=10G
#SBATCH --cpus-per-task=4
#SBATCH --array=1-205

# Define input and output directories
INPUT_DIR="/u/wau2/scratch/giraffes/aligned_mitogenomes/consensus"
OUTPUT_DIR="/u/wau2/scratch/giraffes/aligned_mitogenomes/circularized"

# Create output directory if it doesn't exist
mkdir -p ${OUTPUT_DIR}

# Get list of all FASTA files
SAMPLES=($(ls ${INPUT_DIR}/*.fasta | xargs -n 1 basename))

# Check if SLURM_ARRAY_TASK_ID is within range
if [ $SLURM_ARRAY_TASK_ID -gt ${#SAMPLES[@]} ]; then
    echo "Error: SLURM_ARRAY_TASK_ID ($SLURM_ARRAY_TASK_ID) exceeds available samples (${#SAMPLES[@]})."
    exit 1
fi

# Get the sample name based on SLURM array index
SAMPLE=${SAMPLES[$SLURM_ARRAY_TASK_ID-1]}
BASENAME=$(basename ${SAMPLE} .fasta)

echo "Processing ${BASENAME}..."

# Run Circlator (no need for --start_gene, Circlator auto-detects the best start)
circlator fixstart ${INPUT_DIR}/${SAMPLE} ${OUTPUT_DIR}/${BASENAME}_circularized

echo "Circularization completed for ${BASENAME}"

