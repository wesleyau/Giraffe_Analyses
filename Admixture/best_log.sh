#!/bin/bash

# Set base directory
BASE_DIR="/projects/illinois/aces/ansci/roca/wesley/analysis/admixture_combined"

# Output file
OUTPUT_FILE="${BASE_DIR}/best_K.txt"

# Find all K directories and sort them numerically
K_DIRS=$(ls -d ${BASE_DIR}/K* 2>/dev/null | sort -V)

# Loop through sorted K directories
for KDIR in $K_DIRS; do
    if [[ -d "$KDIR" ]]; then
        K=$(basename "$KDIR")  # Extract K value
        BEST_LL="-inf"          # Initialize the best log likelihood
        BEST_FILE="None"        # Initialize best file name

        # Loop through all log files in the directory
        for LOGFILE in "$KDIR"/admixture_*.log; do
            if [[ -f "$LOGFILE" ]]; then
                # Extract last occurrence of "Loglikelihood:"
                LL=$(grep "Loglikelihood:" "$LOGFILE" | tail -n1 | awk '{print $2}')

                # Ensure LL is numeric
                if [[ ! -z "$LL" && "$LL" != "Loglikelihood:" ]]; then
                    # Compare and update best likelihood
                    if [[ "$BEST_LL" == "-inf" || $(echo "$LL > $BEST_LL" | bc -l) -eq 1 ]]; then
                        BEST_LL=$LL
                        BEST_FILE=$(basename "$LOGFILE")  # Store filename
                    fi
                fi
            fi
        done

        # Append result to file
        echo -e "$BEST_FILE" | tee -a $OUTPUT_FILE
    fi
done

echo "Best log likelihood values and filenames saved in: $OUTPUT_FILE"

