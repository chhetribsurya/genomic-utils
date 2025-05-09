#!/usr/bin/env python3
"""
Convert TCGA ATAC-seq peak calls from txt format to BED format.
This script excludes percentGC and percentAT columns as requested.

Usage:
    Single file: python txt_to_bed.py input.txt output.bed
    Directory:   python txt_to_bed.py --input_dir INPUT_DIR --output_dir OUTPUT_DIR
    python txt_to_bed.py --dir ./TCGA-ATAC_Cancer_Type-specific_PeakCalls ./TCGA-ATAC_BED_Files
"""

import sys
import os
import argparse

def convert_txt_to_bed(input_file, output_file):
    """
    Convert txt peak call file to BED format.
    BED format used: chromosome, start, end, name, score, annotation
    Only percentGC and percentAT columns are excluded.
    """
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        # Skip the header line
        header = infile.readline()
        
        # Process each peak line
        for line in infile:
            fields = line.strip().split('\t')
            
            # Extract relevant fields (skipping percentGC and percentAT)
            chromosome = fields[0]  # seqnames
            start = fields[1]       # start
            end = fields[2]         # end
            name = fields[3]        # name
            score = fields[4]       # score
            annotation = fields[5]  # annotation
            
            # Write BED format line (tab-delimited) including the name column
            outfile.write(f"{chromosome}\t{start}\t{end}\t{name}\t{score}\t{annotation}\n")
            
    print(f"Converted {input_file} to BED format: {output_file}")

def process_directory(input_dir, output_dir):
    """Process all txt files in a directory"""
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        
    for filename in os.listdir(input_dir):
        if filename.endswith("_peakCalls.txt"):
            input_path = os.path.join(input_dir, filename)
            output_path = os.path.join(output_dir, filename.replace(".txt", ".bed"))
            convert_txt_to_bed(input_path, output_path)

if __name__ == "__main__":
    # Set up command line argument parser
    parser = argparse.ArgumentParser(description='Convert TCGA ATAC-seq peak calls from txt to BED format.')
    
    # Create a mutually exclusive group for single file or directory mode
    mode_group = parser.add_mutually_exclusive_group(required=True)
    
    # Single file mode arguments
    mode_group.add_argument('--single', action='store_true', help='Process a single file')
    parser.add_argument('--input_file', help='Input txt file (for single file mode)')
    parser.add_argument('--output_file', help='Output BED file (for single file mode)')
    
    # Directory mode arguments
    mode_group.add_argument('--dir', action='store_true', help='Process all files in a directory')
    parser.add_argument('--input_dir', help='Input directory containing txt files')
    parser.add_argument('--output_dir', help='Output directory for BED files')
    
    # Parse arguments
    args = parser.parse_args()
    
    # Process based on selected mode
    if args.single:
        if not args.input_file or not args.output_file:
            parser.error("--single mode requires --input_file and --output_file")
        convert_txt_to_bed(args.input_file, args.output_file)
    elif args.dir:
        if not args.input_dir or not args.output_dir:
            parser.error("--dir mode requires --input_dir and --output_dir")
        process_directory(args.input_dir, args.output_dir)
    else:
        parser.print_help()
