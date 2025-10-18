#!/bin/bash

# Load conda
source ~/miniconda3/etc/profile.d/conda.sh
conda activate fastqc_env
# Flag to determine whether to perform quality control
QC_FLAG=YES

# Directory containing FASTQ files for analysis
IN_DIR="/media/hp/DATA1/lung_MC/fastq"

# Number of threads to use for FastQC
THREADS=8

# Check if QC_FLAG is set to "YES"
if [ "${QC_FLAG}" == "YES" ]; then 
    # Create results directory if it doesn't exist
    mkdir -p "$IN_DIR/fastqc_results"

    # Read each line from IDs.list
    while read -r i; do
        # Run FastQC on each FASTQ file corresponding to the ID
        fastqc -t "$THREADS" "$IN_DIR/$i" -o "$IN_DIR/fastqc_results"
    done < "$IN_DIR/IDs.list"

    # Generate a summary report using MultiQC from FastQC output files
    multiqc "$IN_DIR/fastqc_results/" --ignore "*_fastqc.html"
fi
