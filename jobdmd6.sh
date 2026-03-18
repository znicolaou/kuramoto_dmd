#!/bin/bash
#SBATCH --account=isaac-utk0437
#SBATCH --partition=campus
#SBATCH --qos=campus
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=50G
#SBATCH --time=01-00:00:00 # Max runtime in DD-HH:MM:SS format.
#SBATCH --export=all
#SBATCH --output=outs/dmd6_%a.out # where STDOUT goes
#SBATCH --error=outs/dmd6_%a.err # where STDERR goes
#SBATCH --array=[1-4]
module load cuda

M=${SLURM_ARRAY_TASK_ID}
N=10000
K=10000
./dmd.py --M $M --D $((N/2*M)) --seed 100 --rank 5000 --runpseudo 1 --load 1 --filesuffix ${M} --mem 50GB --filebase data/dmd2/${N}/${K}/ 
