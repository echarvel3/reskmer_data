#!/bin/bash
#SBATCH --job-name="skmer_distance"
#SBATCH --partition=shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=15
#SBATCH --mem=30G
#SBATCH -o logs/distance_%j_%a.out
#SBATCH -e logs/distance_%j_%a.err
#SBATCH -t 15:00:00
#SBATCH --account=test_account

source ${HOME}/.bashrc
source ${HOME}/miniconda3/etc/profile.d/conda.sh

echo "========"
set -x

date
conda activate skimming_scripts

REFERENCE_GENOME="/expanse/lustre/scratch/echarvel3/temp_project/skmer2_realdata/haploid-drosophila_data/only_chroms_noY.hist"
SKMER_PATH="/expanse/lustre/scratch/echarvel3/temp_project/Skmer/"

for OUTPUT in 1x_downsampled 2x_downsampled 4x_downsampled 6x_downsampled; do
	RESPECT="../respect-hists/${OUTPUT}_output/skmer-reference.txt"

	INPUT="./downsampled_fastq/folder_${SLURM_ARRAY_TASK_ID}/${OUTPUT}/"

	echo -e "kmer_length\t31\nsketch_size\t100000\nsketching_seed\t42" > ./${OUTPUT}/CONFIG
	${SKMER_PATH}/skmer/__main__.py distance ${OUTPUT} -p 15 -o ${OUTPUT}_skmer
	${SKMER_PATH}/skmer/__main__.py  distance ${OUTPUT} -p 15 -r ${REFERENCE_GENOME} -o ${OUTPUT}_reskmer-ref
	${SKMER_PATH}/skmer/__main__.py  distance ${OUTPUT} -p 15 -r ${RESPECT} -o ${OUTPUT}_reskmer-noref


done


