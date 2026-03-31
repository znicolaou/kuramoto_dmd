#!/bin/bash
#SBATCH --account=isaac-utk0437
#SBATCH --partition=ai-tenn
#SBATCH --qos=ai-tenn
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --gres=gpu:1
#SBATCH --mem=20G
#SBATCH --time=03-00:00:00 # Max runtime in DD-HH:MM:SS format.
#SBATCH --export=all
#SBATCH --output=outs/volcano5_%a.out # where STDOUT goes
#SBATCH --error=outs/volcano5_%a.err # where STDERR goes
#SBATCH --array=0-19
module load cuda


i=$((SLURM_ARRAY_TASK_ID/10+1))

gid=0
seed0=$((SLURM_ARRAY_TASK_ID%10+1))
for seed in `seq ${seed0} 10 500`; do
	N=$((100000*i))
	dK=$((2*N/10))
	KS="0 $((dK)) $((2*dK)) $((3*dK)) $((4*dK)) $((5*dK))"
	for K in $KS; do 
	C=`bc -l <<< "1.75*sqrt($K/10000)"`
	echo $N $K $dK $seed
	mkdir -p data/scaled/$N/$K
	jobs=`jobs | wc -l`
	sleep 1
	while [ $jobs -ge 2 ]; do 
		sleep 1
		jobs=`jobs | wc -l`
		echo -en "$jobs \r"
	done
	echo "./kuramoto -N $N -K $K -s $seed -c $C -t 100 -d 0.01 -g $gid -D 0 -a 1E-3 -r 1E-3 -nvAR data/scaled/$N/$K/$seed > /dev/null &"
	./kuramoto -N $N -K $K -s $seed -c $C -t 100 -d 0.01 -g $gid -D 0 -a 1E-3 -r 1E-3 -nvAR data/scaled/$N/$K/$seed > /dev/null &
	gid=$((gid+1))
	if [ $gid -ge 1 ]; then
		gid=0
	fi
done
done
wait
