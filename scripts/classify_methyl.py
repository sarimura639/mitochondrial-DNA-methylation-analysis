import csv

# read reference genome seq
def read_fasta(fasta_file):
    fasta_dict = {}
    with open(fasta_file, 'r') as f:
        chrom = ""
        seq = ""
        for line in f:
            if line.startswith(">"):
                if chrom != "":
                    fasta_dict[chrom] = seq
                chrom = line[1:].strip()
                seq = ""
            else:
                seq += line.strip().upper()
        fasta_dict[chrom] = seq
    return fasta_dict

# classify CG、CHG、CHH sites，annotate methylation type
def classify_methylation(txt_file, fasta_dict, output_file):
    with open(txt_file, 'r') as f, \
         open(output_file, 'w', newline='') as out_file:

        reader = csv.reader(f, delimiter='\t')
        writer = csv.writer(out_file, delimiter='\t')

        # add "C_type" 
        writer.writerow(['chrom', 'start', 'end', 'methylation_level', 'methylated_reads', 'unmethylated_reads', 'C_type'])

        for row in reader:
            chrom, start, end, methylation_level, meth_reads, unmeth_reads = row
            start = int(start) - 1  # 0-based indexing for Python
            if chrom in fasta_dict:
                seq = fasta_dict[chrom]
                if start >= 0 and start + 2 < len(seq):  
                    context = seq[start:start + 3]  #at least 3 bases
                else:
                    context = ""

                # classify and annotation
                if context.startswith("CG"):
                    c_type = "CG"
                elif len(context) == 3 and context[1] != "G" and context[2] == "G":
                    c_type = "CHG"
                else:
                    c_type = "CHH"

                # write
                writer.writerow([chrom, start + 1, end, methylation_level, meth_reads, unmeth_reads, c_type])
# main
if __name__ == "__main__":
    fasta_file = "../ngctrl1/ngctrl1.fasta"  # reference file
    txt_file = "suptongctrl.txt"  # original txt file
    output_file = "suptongctrl_with_methylation_types.txt"  # output file

    fasta_dict = read_fasta(fasta_file)  # read reference 
    classify_methylation(txt_file, fasta_dict, output_file)  # classify and write