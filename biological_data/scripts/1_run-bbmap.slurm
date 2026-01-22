#!/bin/bash
#SBATCH --job-name="bbmap_pipeline"
#SBATCH --partition=shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20
#SBATCH --array=1-24
#SBATCH -o logs/bbmap_%j-%a.out
#SBATCH -e logs/bbmap_%j-%a.err
#SBATCH -t 6:00:00
#SBATCH --account=test_account

source ${HOME}/.bashrc
source ${HOME}/programs/miniconda3/etc/profile.d/conda.sh
set -x

echo "========"
# Processes all skims in the folder with the same number as the array ID...
date
NTHREADS=${NTHREADS:-15}
INPUT="/expanse/lustre/projects/uot138/echarvel3/reads/folder_${SLURM_ARRAY_TASK_ID}/"
BBMAP_PATH="/expanse/lustre/projects/uot138/echarvel3/bbmap/"

# Suffix of the paired end reads (_R1.fastq, _R1.fq.gz, etc...)
SUFF_1="_1.fastq"
SUFF_2="_2.fastq"
echo "========"


mkdir -p ./bbmap_reads/folder_${SLURM_ARRAY_TASK_ID}/

for file in $(realpath "${INPUT}/*${READ_1}"); do
        read1=$file
        read2=${read1%${SUFF_1}}${SUFF_2}
        out_read=${file##*/}

        "${BBMAP_PATH}"/bbmap_pipeline.sh \
                "$read1" \
                "$read2" \
                "./bbmap_reads/folder_${SLURM_ARRAY_TASK_ID}/${out_read%${READ_1}}.fastq"
done

echo "========"
date
