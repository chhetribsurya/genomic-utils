# Genomic-utils

# TXT to BED Converter Usage Examples

## Directory Mode (Process Multiple Files)
```bash
# Process all files in a directory
python TCGA_ATAC_ToBed/txt_to_bed.py --dir --input_dir ./TCGA-ATAC_Cancer_Type-specific_PeakCalls --output_dir ./TCGA-ATAC_BED_Files
```

## Single File Mode
```bash
# Process a single file
python TCGA_ATAC_ToBed/txt_to_bed.py --single --input_file ./TCGA-ATAC_Cancer_Type-specific_PeakCalls/KIRC_peakCalls.txt --output_file ./TCGA-ATAC_BED_Files/KIRC_peakCalls.bed
```

## Help
```bash
# Get help information
python TCGA_ATAC_ToBed/txt_to_bed.py -h
```

## Example Output
This command:
```bash
python TCGA_ATAC_ToBed/txt_to_bed.py --dir --input_dir ./TCGA-ATAC_Cancer_Type-specific_PeakCalls --output_dir ./TCGA-ATAC_BED_Files
```

Will create BED files in the `./TCGA-ATAC_BED_Files` directory with this format:
```
chr1    943064    943565    KIRC_24    7.055080785314    3' UTR
chr1    1291747   1292248   KIRC_93    7.13223687757963  3' UTR
chr1    1440816   1441317   KIRC_123   6.08659662952614  3' UTR
...
```
