#!/bin/bash
#SBATCH --job-name="consult-2"
#SBATCH --partition=shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --array=1-24
#SBATCH --mem=20G
#SBATCH -o logs/consult-2_%j_%a.out
#SBATCH -e logs/consult-2_%j_%a.err
#SBATCH -t 48:00:00
#SBATCH --account=uot138

source ${HOME}/.bashrc
source ${HOME}/miniconda3/etc/profile.d/conda.sh

NTHREADS=${NTHREADS:-10}
SCRIPT_DIR="../skimming_scripts-echarvel"
OUT_DIR="./"

echo "========"
date

conda activate skimming_scripts

mkdir --parent "${OUT_DIR}/consult_reads/folder_${SLURM_ARRAY_TASK_ID}"

${SCRIPT_DIR}/CONSULT-II/consult_search \
	-i "${SCRIPT_DIR}/CONSULT-II/library-h13_t2_l2_b16/" \
	-o "${OUT_DIR}/consult_reads/folder_${SLURM_ARRAY_TASK_ID}" \
	--query-path "${OUT_DIR}/bbmap_reads/folder_${SLURM_ARRAY_TASK_ID}" \
	--number-of-matches 2 \
	--thread-count ${NTHREADS} \
	--unclassified-out "${OUT_DIR}/consult_reads/folder_${SLURM_ARRAY_TASK_ID}"

echo "========"
date
