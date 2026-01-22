#!/bin/bash
#SBATCH --job-name="downsample"
#SBATCH --partition=shared
#SBATCH --account=uot138
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=10G
#SBATCH -o logs/respect_full_%j_%a.out
#SBATCH -e logs/respect_full_%j_%a.err
#SBATCH -t 00:40:00
#SBATCH --array 1-24

source ${HOME}/.bashrc
source ${HOME}/miniconda3/etc/profile.d/conda.sh

conda activate skimming_scripts

echo "========"
set -x

FASTQ_DIR="./kraken_reads/folder_${SLURM_ARRAY_TASK_ID}/"
REFORMAT_DIR="/expanse/lustre/projects/uot138/echarvel3/cunner_reads/scripts/genome_size_scripts/scripts/"
OUT_DIR="./downsampled_fastq/folder_${SLURM_ARRAY_TASK_ID}/"
GENOME_SIZE=143000000
READ_LENGTH=100

date

echo "========"

for x in $(realpath ${FASTQ_DIR}/unclass*); do
	filename=${x##*/}

	for target_cov in 1 2 4 6; do
		mkdir -p "${OUT_DIR}/${target_cov}x_downsampled/"
		sample_num=$((${GENOME_SIZE}*"${target_cov}"/${READ_LENGTH}))

		# Uses "reformat.sh" from bbtools...
		${REFORMAT_DIR}/reformat.sh in="${x}" out="${OUT_DIR}/${y}x_downsampled/${filename%.fastq}.fastq" samplereadstarget="${sample_num}" sampleseed="${y}" overwrite=true

	done
done

echo "========"
date
