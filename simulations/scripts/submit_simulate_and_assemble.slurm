#!/bin/bash
#SBATCH --job-name="simulate_and_assemble"
#SBATCH --nodes=1
#SBATCH --array=0-5
#SBATCH --ntasks-per-node=14
#SBATCH -o skmer_sim_%j_%a.out
#SBATCH -e skmer_sim%j_%a.err
#SBATCH -t 72:00:00
#SBATCH -account=test_account


source ${HOME}/.bashrc
source ${HOME}/programs/miniconda3/etc/profile.d/conda.sh

conda activate skmer
set -x

# choosing sample...
sample_arr=("rotifer" "leech" "club-moss" "nematode" "moss" "oyster")
samp=${sample_arr[$SLURM_ARRAY_TASK_ID]}

mkdir "./genomes/"
pushd "./genomes/"

reference_genome=$(realpath /scratch01/echarvel/skims_sims/reference_genomes/${samp}_genome/*fna)

# generate child genomes with selected distances...
for distance in 0.0; do
        mkdir ${samp}
        mkdir "./${samp}/${samp}_${distance}/"

        python /scratch03/echarvel_temp/skmer2-sims/skmer2_eqn_analysis/make_genomes.py existing \
			--existing-dir "${reference_genome%/*}" \
			--out-dir "./${samp}/${samp}_${distance}/" \
			--mutation-prob "${distance}"
done
popd

mkdir "./skims/"
mkdir --parents "./assemblies/${samp}/"
pushd "./skims/"

conda deactivate
conda activate megahit

# generate paired-end reads using ART... (removes Ns at 0 distance)

ART_PATH="/calab_data/mirarab/home/echarvel3/programs/art_bin_MountRainier/"

for distance in 0.0; do
	mkdir "${samp}"
	genome=$(realpath ../genomes/${samp}/${samp}_${distance}/*) 
	phred_quality=25
	read_len=150
	
	for coverage in 10 50; do 
		${ART_PATH}/art_illumina -q \
			-i $genome \
			-p \
			-m 250 \
			-s 10 \
			-l $read_len \
			-f $coverage \
			-qL ${phred_quality} -qU ${phred_quality} \
			-o ${samp}/${samp}_${distance}_${coverage}x_paired
		rm ./${samp}/*.aln
	done

# Use megahit to assemble...

	for coverage in 10 50; do
		megahit -1 $(realpath ${samp}/${samp}_${distance}_${coverage}x_paired1.fq)  \
				-2 $(realpath ${samp}/${samp}_${distance}_${coverage}x_paired2.fq) \
				-o "../assemblies/${samp}/${samp}_${coverage}-paired/" \
				-t 12  
		gzip ${samp}/${samp}_${distance}_${coverage}x_paired*.fq
	done

done

# Use these new assemlbies as reference assemblies in 'submit_skmer_simulations.slurm'