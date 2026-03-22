#!/bin/bash
#SBATCH --account=isaac-utk0437
#SBATCH --partition=campus-gpu-large
#SBATCH --qos=campus-gpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --gres=gpu:2
#SBATCH --mem=20G
#SBATCH --time=01-00:00:00 # Max runtime in DD-HH:MM:SS format.
#SBATCH --export=all
#SBATCH --output=outs/volcano3_%a.out # where STDOUT goes
#SBATCH --error=outs/volcano3_%a.err # where STDERR goes
#SBATCH --array=1-2
module load cuda


i=$SLURM_ARRAY_TASK_ID
gid=0
for seed in `seq 1 500`; do
	N=$((100000*i))
	dK=$((2*N/10))
	KS="0 $((dK)) $((2*dK)) $((3*dK)) $((4*dK)) $((5*dK))"
	for K in $KS; do 
	echo $N $K $dK
	mkdir -p data/normal/$N/$K
	jobs=`jobs | wc -l`
	while [ $jobs -ge 4 ]; do 
		sleep 1
		jobs=`jobs | wc -l`
	done
	if [ ! -f data/normal/$N/$K/${seed}.out ]; then
		./kuramoto -N $N -K $K -s $seed -c 1.75 -t 100 -d 0.01 -g $gid -D 0 -a 1E-3 -r 1E-3 -nvAR data/normal/$N/$K/$seed > /dev/null &
	fi
	gid=$((gid+1))
	if [ $gid -ge 2 ]; then
		gid=0
	fi
done
done
