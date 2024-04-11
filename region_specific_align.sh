#!/bin/bash

# Script to extract a specific chromosome from a genome FASTA file,
# build a reference index, and align FASTQ files to this reference, producing a BAM file.

# Requires: samtools, bowtie2

# Usage:
# chmod +x align_to_chromosome.sh
# ./align_to_chromosome.sh --genome-fasta <genome_fasta> --chromosome <chromosome> --output-dir <output_dir> --fastq1 <fastq1> [--fastq2 <fastq2>]

# Display detailed usage instructions
usage() {
    echo "Usage: $0 --genome-fasta <genome_fasta> --chromosome <chromosome> --output-dir <output_dir> --fastq1 <fastq1> [--fastq2 <fastq2>]"
    echo ""
    echo "Arguments:"
    echo "  --genome-fasta <genome_fasta>    Path to the genome FASTA file. This file should be in FASTA format."
    echo "  --chromosome <chromosome>        Specific chromosome or region to be extracted (e.g., 'chr20', 'chrX:1000-5000')."
    echo "  --output-dir <output_dir>        Directory where output files will be saved. Defaults to the current directory."
    echo "  --fastq1 <fastq1>                Path to the first FASTQ file. Required for both single-end and paired-end reads."
    echo "  --fastq2 <fastq2>                Path to the second FASTQ file. Optional, only for paired-end reads."
    echo ""
    echo "Example:"
    echo "  $0 --genome-fasta path/to/genome.fa --chromosome chr1 --output-dir path/to/output --fastq1 path/to/read1.fastq --fastq2 path/to/read2.fastq"
    exit 1
}

# Default parameters
output_dir="."

# Parse flag-based command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --genome-fasta)
            genome_fasta="$2"
            shift 2
            ;;
        --chromosome)
            chromosome="$2"
            shift 2
            ;;
        --output-dir)
            output_dir="$2"
            shift 2
            ;;
        --fastq1)
            fastq1="$2"
            shift 2
            ;;
        --fastq2)
            fastq2="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Check for required arguments and tools
if [[ -z "$genome_fasta" || -z "$chromosome" || -z "$fastq1" ]]; then
    echo "Error: Missing required arguments."
    usage
fi

if ! command -v samtools &> /dev/null || ! command -v bowtie2 &> /dev/null; then
    echo "Error: samtools and bowtie2 are required."
    exit 1
fi

# Functions
index_genome() {
    echo "Indexing the genome FASTA file..."
    samtools faidx "$1" || { echo "Error indexing genome"; exit 1; }
}

extract_chromosome() {
    local output_fasta="${output_dir}/${2}.fasta"
    echo "Extracting ${2} from $1..."
    samtools faidx "$1" "$2" > "$output_fasta" || { echo "Error extracting chromosome"; exit 1; }
    echo "$output_fasta"
}

build_reference_index() {
    local index_prefix="${1%.fasta}_index"
    echo "Building reference index..."
    bowtie2-build "$1" "$index_prefix" || { echo "Error building reference index"; exit 1; }
    echo "$index_prefix"
}

align_reads() {
    local bam_output="${output_dir}/aligned_${2}.bam"
    echo "Aligning reads to the reference..."
    if [ -z "$3" ]; then
        bowtie2 -x "$1" -U "$2" | samtools view -bS - > "$bam_output" || { echo "Error aligning reads"; exit 1; }
    else
        bowtie2 -x "$1" -1 "$2" -2 "$3" | samtools view -bS - > "$bam_output" || { echo "Error aligning reads"; exit 1; }
    fi
    echo "$bam_output"
}

# Main script logic
index_genome "$genome_fasta"
chromosome_fasta=$(extract_chromosome "$genome_fasta" "$chromosome")
ref_index=$(build_reference_index "$chromosome_fasta")
align_reads "$ref_index" "$fastq1" "$fastq2"

echo "Process complete. Outputs are in ${output_dir}"
