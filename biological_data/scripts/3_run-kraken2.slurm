#!/bin/bash
#SBATCH --job-name="kraken-2"
#SBATCH --partition=shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --array=1-24
#SBATCH --mem=20G
#SBATCH -o logs/kraken-2_%j_%a.out
#SBATCH -e logs/kraken-2_%j_%a.err
#SBATCH -t 12:00:00
#SBATCH --account=test_account

echo "========"

source ${HOME}/.bashrc
source ${HOME}/miniconda3/etc/profile.d/conda.sh
conda activate kraken2

NTHREADS=${NTHREADS:-10}
SCRIPT_DIR="./skimming_scripts-echarvel"
OUT_DIR="./"
KRAKEN_LIB="../human_lib/"

echo "========"

mkdir --parents ${OUT_DIR}/kraken_reads/folder_${SLURM_ARRAY_TASK_ID}

for file in $(ls "${OUT_DIR}/consult_reads/folder_${SLURM_ARRAY_TASK_ID}/"); do
	    kraken2 \
			--db "${KRAKEN_LIB}" \
			"${OUT_DIR}/consult_reads/folder_${SLURM_ARRAY_TASK_ID}/${file}" \
			--threads ${NTHREADS} \
			--unclassified-out ${OUT_DIR}/kraken_reads/folder_${SLURM_ARRAY_TASK_ID}/${file%".fastq"}.fastq
done

echo "========"
date
