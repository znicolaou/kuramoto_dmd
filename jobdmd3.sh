#!/bin/bash
#SBATCH --account=isaac-utk0437
#SBATCH --partition=short
#SBATCH --qos=short
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=50G
#SBATCH --time=00-03:00:00 # Max runtime in DD-HH:MM:SS format.
#SBATCH --export=all
#SBATCH --output=outs/dmd3_%a.out # where STDOUT goes
#SBATCH --error=outs/dmd3_%a.err # where STDERR goes
#SBATCH --array=[1-5]

M=${SLURM_ARRAY_TASK_ID}
N=10000
K=2
filebase0=data/dmd2
./dmd.py --M $M --D $((N/2*M)) --seed 100 --rank 5000 --dense_amplitudes 1 --runpseudo 1 --load 1 --filesuffix ${M} --mem 40GB --filebase ${filebase0}/${N}/${K}/ 
rm -rf ${filebase0}/${N}/${K}/${M}X0
rm -rf ${filebase0}/${N}/${K}/${M}X
rm -rf ${filebase0}/${N}/${K}/${M}v
rm -rf ${filebase0}/${N}/${K}/${M}u

