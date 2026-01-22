#!/bin/bash
#SBATCH --job-name="run_skmer_simulation"
#SBATCH --nodes=1
#SBATCH --array=0-5
#SBATCH --ntasks-per-node=14
#SBATCH -o skmer_sim_%j_%a.out
#SBATCH -e skmer_sim%j_%a.err
#SBATCH -t 72:00:00
#SBATCH -account=test_account

source ${HOME}/.bashrc
source ${HOME}/programs/miniconda3/etc/profile.d/conda.sh
THREADS=10
conda activate skmer

# start logging...
set -x

# choosing selected sample...
sample_arr=("club-moss" "moss" "oyster" "nematode" "rotifer" "leech")
samp=${sample_arr[$SLURM_ARRAY_TASK_ID]}
reference_genome=$(find /scratch01/echarvel/skims_sims/reference_genomes/${samp}_genome/ -name '*fna')

# generate child genomes with selected distances...
SIMULATOR_PATH="/scratch01/echarvel/skims_sims/"

mkdir "./child_genomes/"
pushd "./child_genomes/"

for distance in 0.0 0.001 0.002 0.004 0.006 0.008 0.01 0.02 0.05 0.1 0.15 0.2; do
	mkdir -p "./${samp}/${samp}_${distance}/"

	python ${SIMULATOR_PATH}/make_genomes.py existing \
		--existing-dir "${reference_genome%/*}" \
		--out-dir "./${samp}/${samp}_${distance}/" \
		--mutation-prob "${distance}"
done
popd

# simulate genome skims using ART at chosen coverage, read length, and phred quality...
ART_PATH="/calab_data/mirarab/home/echarvel3/programs/art_bin_MountRainier/"

mkdir "./genome_skims/"
pushd "./genome_skims/"

for distance in 0.0 0.001 0.002 0.004 0.006 0.008 0.01 0.02 0.05 0.1 0.15 0.2; do
	mkdir "${samp}"

	genome=$(realpath ../child_genomes/${samp}/${samp}_${distance}/*) 
	phred_quality=25
	read_length=150
	
	for coverage in 1 2 4 8; do 
		${ART_PATH}/art_illumina -q \
			-i $genome \
			-l $read_len \
			-f $coverage \
			-qL ${phred_quality} -qU ${phred_quality} \
			-o ${samp}/${samp}_${distance}_${coverage}x &
	done
	wait	
	rm ./${samp}/*.aln

done
popd 

# run respect on samples to create respect input...
respect_settings="r50_N1000"
mkdir "./respect/${samp}/"

respect -d ./genome_skims/${samp}/ \
	-I ./${samp}/hist_info.txt \
	-s 50 \
	--threads ${THREADS} \
	-o "./results/${samp}_${respect_settings}"

# run respect on samples to create respect input...
mkdir "./respect/results/"
paste <(cat "./respect/results/${samp}_${respect_settings}/estimated-spectra.txt") <(cut -f5 "./respect/results/${samp}_${respect_settings}/estimated-parameters.txt") > "./respect/results/${samp}_${respect_settings}/input_spectra.txt"

# run different skmer versions and mash...
SKMER_PATH="/calab_data/mirarab/home/echarvel3/programs/Skmer/"

mkdir "./libraries"
mkdir "./dist_matrices"
mkdir "./stat_files"

${SKMER_PATH}/Skmer/skmer/__main__.py reference "./skims/${samp}" \
	-l "./libraries/${samp}" \
	-o "./dist_matrices/skmer_${samp}" \
	-p 2
grep "" ./libraries/${samp}/*/*dat | sort -k2 >  ./stat_files/skmer_${samp}.csv

for distance in 0.0 0.001 0.002 0.004 0.006 0.008 0.01 0.02 0.05 0.1 0.15 0.2; do
    for cov in 1 2 4 8; do
		parent_skim=$(realpath ./libraries/${samp}/${samp}_0.0_${cov}x/*msh)
        child_skim=$(realpath ./libraries/${samp}/${samp}_${distance}_${cov}x/*msh)
        mash dist ${parent_skim} ${child_skim}
    done
done > ./dist_matrices/mash_${samp}.txt

${SKMER_PATH}/skmer/__main__.py reference "./skims/${samp}" \
	-r "./genomes/${samp}/${samp}_0.0/*" \
	-l "./libraries/${samp}" \
	-o "./dist_matrices/reskmer-ref_${samp}" \
	-p 2
grep "" ./libraries/${samp}/*/*dat |sort -k2 >  ./stat_files/reskmer-ref_${samp}.csv

${SKMER_PATH}/skmer/__main__.py reference "./skims/${samp}" \
	-r "./res[ect/results/${samp}/${samp}_${respect_settings}/input_spectra.txt" \
	-l "./libraries/${samp}" \
	-o "./dist_matrices/reskmer-noref_${samp}" \
	-p 2
grep "" ./libraries/${samp}/*/*dat |sort -k2 >  ./stat_files/reskmer-noref_${samp}.csv
	




