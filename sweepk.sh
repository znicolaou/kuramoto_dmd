#!/bin/bash
#SBATCH --account=isaac-utk0437
#SBATCH --partition=campus-gpu
#SBATCH --qos=campus-gpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --gres=gpu:1
#SBATCH --mem=5G
#SBATCH --time=01-00:00:00 # Max runtime in DD-HH:MM:SS format.
#SBATCH --export=all
#SBATCH --output=outs/k%a.out # where STDOUT goes
#SBATCH --error=outs/k%a.err # where STDERR goes
#SBATCH --array=1-10
module load cuda

i=$((SLURM_ARRAY_TASK_ID))
N=10000
K=`awk -v N=$N -v i=$i 'BEGIN{print(int(exp(i/10*log(N))))}'`
dt=0.01
T=100
C=1.75
mkdir -p data/dmd/${N}/${K}
python makeic.py -N $N -K $K --seed 100 --dt $dt -c $C -T $T --filebase data/dmd/${N}/${K}
C=1.00
mkdir -p data/dmd2/${N}/${K}
python makeic.py -N $N -K $K --seed 100 --dt $dt -c $C -T $T --filebase data/dmd2/${N}/${K}
