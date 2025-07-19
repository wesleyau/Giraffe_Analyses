#!/bin/bash
#SBATCH --job-name=mitogenomes
#SBATCH --output=log/%A_%a.out
#SBATCH --error=log/%A_%a.err
#SBATCH --time=72:00:00
#SBATCH --mem=15G
#SBATCH --cpus-per-task=8
#SBATCH --array=1-205
#SBATCH -p aces

# Define directories
FASTQ_DIR="/u/wau2/project-aces/giraffes/data/2023-Aug-WGS-40_Samples/data"
REF_FASTA="/u/wau2/scratch/giraffes/mitogenomes/giraffe_mitogenomes/giraffe_mt.fasta"
OUTPUT_DIR="/u/wau2/scratch/giraffes/aligned_mitogenomes"

# Create output directories if they don't exist
mkdir -p ${OUTPUT_DIR}/bams ${OUTPUT_DIR}/consensus

# Index the reference genome if not already indexed
if [ ! -f "${REF_FASTA}.bwt" ]; then
    echo "Indexing reference genome..."
    bwa index ${REF_FASTA}
fi

# Get the list of sample names (extracting only the first part before the first underscore)
SAMPLES=($(ls ${FASTQ_DIR}/*_R1_001.fastq.gz | xargs -n 1 basename | cut -d'_' -f1 | sort -u))

# Get the current sample based on SLURM array index
SAMPLE=${SAMPLES[$SLURM_ARRAY_TASK_ID-1]}

echo "Processing ${SAMPLE}..."

# Find matching R1 and R2 files
R1=$(ls ${FASTQ_DIR}/${SAMPLE}_*_R1_001.fastq.gz)
R2=$(ls ${FASTQ_DIR}/${SAMPLE}_*_R2_001.fastq.gz)

# Align reads to reference using BWA-MEM
bwa mem -M -t 8 ${REF_FASTA} ${R1} ${R2} | samtools sort -o ${OUTPUT_DIR}/bams/${SAMPLE}.sorted.bam

# Index the BAM file
samtools index ${OUTPUT_DIR}/bams/${SAMPLE}.sorted.bam

# Filter BAM to remove unmapped and low-quality reads
samtools view -b -F 4 -q 20 ${OUTPUT_DIR}/bams/${SAMPLE}.sorted.bam > ${OUTPUT_DIR}/bams/${SAMPLE}.filtered.bam

# Re-index the filtered BAM
samtools index ${OUTPUT_DIR}/bams/${SAMPLE}.filtered.bam

# Generate VCF using filtered BAM
samtools mpileup -aa -A -d 1000000 -f ${REF_FASTA} ${OUTPUT_DIR}/bams/${SAMPLE}.filtered.bam | bcftools call -mv -Oz -o ${OUTPUT_DIR}/consensus/${SAMPLE}.vcf.gz

# Index the VCF file
bcftools index ${OUTPUT_DIR}/consensus/${SAMPLE}.vcf.gz

# Generate consensus FASTA sequence
cat ${REF_FASTA} | bcftools consensus ${OUTPUT_DIR}/consensus/${SAMPLE}.vcf.gz > ${OUTPUT_DIR}/consensus/${SAMPLE}.fasta

echo "Consensus FASTA generated for ${SAMPLE}"

echo "Alignment and consensus generation completed for ${SAMPLE}!"

