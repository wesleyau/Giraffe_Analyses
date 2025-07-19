#!/bin/bash

# Define directories and file paths
INPUT_DIR="/projects/illinois/aces/ansci/roca/wesley/results/2024-10-24-combined-vcf"
PLINK_INPUT="${INPUT_DIR}/final_merged_4species_plink_data"
PLINK_OUTPUT_DIR="/projects/illinois/aces/ansci/roca/wesley/analysis/final_admixture4"
LOG_FILE="${PLINK_OUTPUT_DIR}/pipeline.log"
CV_ERROR_FILE="${PLINK_OUTPUT_DIR}/cv_errors.log"

# Create output directory if it doesn't exist
mkdir -p $PLINK_OUTPUT_DIR

# Redirect all output to the log file
exec > >(tee -a $LOG_FILE) 2>&1

# Initialize CV errors log file
echo "K,Run,CV_Error" > $CV_ERROR_FILE

# Function to run ADMIXTURE multiple times for a given K
run_admixture () {
    local K=$1
    local RUNS=$2
    local K_DIR="${PLINK_OUTPUT_DIR}/K${K}"
    mkdir -p $K_DIR

    local BEST_LL=-99999999
    local BEST_RUN=""
    local BEST_CV_ERROR=99999999

    for (( i=1; i<=RUNS; i++ )); do
        echo "Running ADMIXTURE for K=$K, run $i..."
        SEED=$RANDOM
        admixture --cv ${PLINK_INPUT}.bed $K --seed=$SEED > ${K_DIR}/admixture_K${K}_run${i}.log

	# Check if the .P and .Q files were generated
        if [[ -f "combined_final_pruned_plink_data.${K}.P" && -f "combined_final_pruned_plink_data.${K}.Q" ]]; then
            mv "combined_final_pruned_plink_data.${K}.P" "${K_DIR}/admixture_K${K}_run${i}.P"
            mv "combined_final_pruned_plink_data.${K}.Q" "${K_DIR}/admixture_K${K}_run${i}.Q"
        else
            echo "ADMIXTURE did not produce .P or .Q files for K=$K, run $i. Check ${K_DIR}/admixture_K${K}_run${i}.log for details."
            tail -n 20 ${K_DIR}/admixture_K${K}_run${i}.log
            continue
        fi

        # Get the last log-likelihood value from the log file
        local LL=$(grep -oP "(?<=Loglikelihood: )-?\d+\.\d+" ${K_DIR}/admixture_K${K}_run${i}.log | tail -1)

        # Get the CV error from the log file
        local CV_ERROR=$(grep -oP "(?<=CV error \(K=${K}\): )\d+\.\d+" ${K_DIR}/admixture_K${K}_run${i}.log | tail -1)

        echo "$K,$i,$CV_ERROR" >> $CV_ERROR_FILE

	# Update BEST_RUN and BEST_LL if we find a better log-likelihood
        if (( $(echo "$LL > $BEST_LL" | bc -l) )); then
            BEST_LL=$LL
            BEST_RUN=$i
            BEST_CV_ERROR=$CV_ERROR
        fi

    done

    echo "Best run for K=$K: Run $BEST_RUN with Loglikelihood $BEST_LL and CV error $BEST_CV_ERROR" >> ${PLINK_OUTPUT_DIR}/best_runs.log
}

# Check if ADMIXTURE is installed and accessible
if ! command -v admixture &> /dev/null; then
    echo "ADMIXTURE could not be found. Please ensure it is installed and in your PATH."
    exit 1
fi

# Ensure the input files exist
if [[ ! -f "${PLINK_INPUT}.bed" || ! -f "${PLINK_INPUT}.bim" || ! -f "${PLINK_INPUT}.fam" ]]; then
    echo "PLINK input files (.bed, .bim, .fam) not found in ${INPUT_DIR}. Ensure these files are present and correctly named."
    exit 1
fi

# Run ADMIXTURE for K=2 to K=10 with 100 runs each
for K in 2 6; do
    run_admixture $K 100
done

echo "ADMIXTURE analysis completed. Check the output in ${PLINK_OUTPUT_DIR}."
