import os
import glob
import argparse
import numpy as np
from screed import fasta

##############################
# CODE: By Isaac Thomas
##############################

def mutate_fasta(in_path, out_path, d):
    reads_processed=0
    bases = set(["A", "C", "G", "T"])
    rng = np.random.default_rng()
    with open(in_path, 'r') as fin, open(out_path, 'a') as fout:
        for record in fasta.fasta_iter(fin):
            mutated_seq = "".join([rng.choice(list(bases - set([base]))) if rng.random() < d else base for base in record['sequence'].upper().replace("N","")])
            fout.write(f">{record['name']}_mutated\n")
            fout.write(f'{mutated_seq}\n')
            reads_processed += 1
            print (f"mutated {reads_processed} reads from {os.path.splitext(os.path.basename(in_path))[0]}...", end='\r')
    print ()
    print ("done")

def mutate_existing(args):
    print("starting")
    print(args.existing_dir)
    print(glob.glob(os.path.join(args.existing_dir, '*.fna')))
    for p in glob.glob(os.path.join(args.existing_dir, '*.fna')):
        print(p)
        out_path = os.path.join(args.out_dir, f'{os.path.splitext(os.path.basename(p))[0]}.fna')
        mutate_fasta(p, out_path, args.mutation_prob)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="make some mutated genomes")

    subparsers = parser.add_subparsers()

    existing_parser = subparsers.add_parser('existing')
    existing_parser.add_argument('--existing-dir', type=str, required=True)
    existing_parser.add_argument('--out-dir', type=str, required=True)
    existing_parser.add_argument('--mutation-prob', type=float, required=True) 
    existing_parser.set_defaults(func=mutate_existing)

    args = parser.parse_args()
    args.func(args)
