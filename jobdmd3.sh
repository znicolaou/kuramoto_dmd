#!/bin/bash
#SBATCH --account=isaac-utk0437
#SBATCH --partition=campus
#SBATCH --qos=campus
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=80G
#SBATCH --time=01-00:00:00 # Max runtime in DD-HH:MM:SS format.
#SBATCH --export=all
#SBATCH --output=outs/dmd3%a.out # where STDOUT goes
#SBATCH --error=outs/dmd3%a.err # where STDERR goes
#SBATCH --array=0-3
module load cuda

M=5
N=10000
KS=(2 2 10000 10000)
filebases=('data/dmd' 'data/dmd2' 'data/dmd' 'data/dmd2')
filebase0=${filebases[SLURM_ARRAY_TASK_ID]}
K=${KS[SLURM_ARRAY_TASK_ID]}
./dmd.py --M $M --D $((N/2*M)) --seed 100 --rank 5000 --runpseudo 0 --dense_amplitudes 1 --load 0 --filesuffix ${M} --mem 50GB --filebase ${filebase0}/${N}/${K}/ 
