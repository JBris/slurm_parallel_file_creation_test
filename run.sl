#!/bin/bash
#SBATCH --job-name=create_json_files_batch
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=500MB
#SBATCH --time=00:03:00
#SBATCH --hint=multithread

module load R/4.0.0

# Vars
# Override using sbatch --export=pjson=P run.sl

Rscript create_files.R "$pjson"
