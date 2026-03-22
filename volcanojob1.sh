#!/bin/bash
#SBATCH --account=isaac-utk0437
#SBATCH --partition=campus-gpu-bigmem
#SBATCH --qos=campus-gpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:2
#SBATCH --mem=50G
#SBATCH --time=01-00:00:00 # Max runtime in DD-HH:MM:SS format.
#SBATCH --export=all
#SBATCH --output=outs/volcano1_%a.out # where STDOUT goes
#SBATCH --error=outs/volcano1_%a.err # where STDERR goes
#SBATCH --array=1
module load cuda


i=$SLURM_ARRAY_TASK_ID
gid=0
for seed in `seq 1 750`; do
	N=$((5000*i))
	KS="0 2 $((5000*i))"
	for K in $KS; do 
	echo $N $K $dK $seed
	mkdir -p data/normal/$N/$K
	mkdir -p data/lorentz/$N/$K
	jobs=`jobs | wc -l`
	while [ $jobs -ge 8 ]; do 
		sleep 1
		jobs=`jobs | wc -l`
	done

	if [ ! -f data/normal/$N/$K/${seed}.out ]; then
		./kuramoto -N $N -K $K -s $seed -c 1.75 -t 100 -d 0.01 -g $gid -D 0 -a 1E-3 -r 1E-3 -nv data/normal/$N/$K/$seed > /dev/null &
	fi
	if [ ! -f data/lorentz/$N/$K/${seed}.out ]; then
		./kuramoto -N $N -K $K -s $seed -c 3.00 -t 100 -d 0.01 -g $gid -D 0 -a 1E-3 -r 1E-3 -v data/lorentz/$N/$K/$seed > /dev/null &
	fi
	gid=$((gid+1))
	if [ $gid -ge 2 ]; then
		gid=0
	fi
done
done
