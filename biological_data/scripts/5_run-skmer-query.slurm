#!/bin/bash
#SBATCH --job-name="skmer_query"
#SBATCH --partition=shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --array=1-24%50
#SBATCH --mem=30G
#SBATCH -o logs/skmer_query_%j_%a.out
#SBATCH -e logs/subsample-and-estimate_%j_%a.err
#SBATCH -t 10:00:00
#SBATCH --account=test_account


source ${HOME}/.bashrc
source ${HOME}/miniconda3/etc/profile.d/conda.sh

echo "========"
date

conda activate skimming_scripts

set -x

REFERENCE_GENOME="/expanse/lustre/scratch/echarvel3/temp_project/skmer2_realdata/haploid-drosophila_data/only_chroms_noY.hist"
SKMER_PATH="/expanse/lustre/scratch/echarvel3/temp_project/Skmer/"

# Making a dummy library with CONFIG file allows for better parallelization...
if [ ! -d "./dummy_lib" ]; then
	mkdir ./dummy_lib
	echo -e "kmer_length\t31\nsketch_size\t100000\nsketching_seed\t42" > ./dummy_lib/CONFIG
fi

species=drosophila

for OUTPUT in 1x_downsampled 2x_downsampled 4x_downsampled 6x_downsampled; do
	# PATH TO RESPECT FILES...
	REFERENCE_RESPECT=$(realpath "./respect-hists/${OUTPUT}_output/skmer-reference.txt")

	INPUT="./downsampled_fastq/folder_${SLURM_ARRAY_TASK_ID}/${OUTPUT}/"

	for x in $(realpath ./${INPUT}/*); do
		# RUNNING SKMER
		mkdir --parents "./${species}_skmer/${OUTPUT}/"
		pushd "./${species}_skmer/${OUTPUT}/"
		${SKMER_PATH}/skmer/__main__.py query $x "../../dummy_lib/" -a -p 2
		popd

		# RUNNING RESKMER + ASSEMBLY
		mkdir --parents "./${species}_reskmer-ref/${OUTPUT}/"
		pushd "./${species}_reskmer-ref/${OUTPUT}/"
		${SKMER_PATH}/skmer/__main__.py query $x "../../dummy_lib/" -a -p 2 -r ${REFERENCE_GENOME}
		popd

		# RUNNING RESKMER + RESPECT
		mkdir --parents "./${species}_reskmer-noref/${OUTPUT}/"
		pushd "./${species}_skmer-repeat-respect/${OUTPUT}/"
		${SKMER_PATH}/skmer/__main__.py query $x "../../dummy_lib/" -a -p 2 -r ${REFERENCE_RESPECT}
		popd

	done
done

