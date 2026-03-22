#!/bin/bash
#SBATCH --account=isaac-utk0437
#SBATCH --partition=campus
#SBATCH --qos=campus
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=100G
#SBATCH --time=01-00:00:00 # Max runtime in DD-HH:MM:SS format.
#SBATCH --export=all
#SBATCH --output=outs/dmd5_%a.out # where STDOUT goes
#SBATCH --error=outs/dmd5_%a.err # where STDERR goes
#SBATCH --array=0-9

export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
M=5
N=10000
filebase0='data/dmd2'
Ks=(`ls ${filebase0}/${N}`)
K=${Ks[$SLURM_ARRAY_TASK_ID]}
if [ ! -f ${filebase0}/${N}/${K}/${M}evals.npy ]; then
	./dmd.py --M $M --D $((N/2*M)) --seed 100 --rank 6000 --runpseudo 0 --dense 1 --filesuffix ${M} --mem 40GB --filebase ${filebase0}/${N}/${K}/ 
fi
