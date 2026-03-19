Integrate a large network of Kuramoto oscillators on a gpu with a random or user-specified adjacency matrix

# Files in this repository
The files kuramoto.cu and kuramoto_64.cu contains cuda code to numerically integrate phase oscillators on a gpu. They the Dormand-Prince adaptive timestep 4/5 Runge-Kutta integration scheme implemented in dp45.cu and dp45_64.cu. The 64 bit versions use double precision, and the others use single precision.  
The jupyter notebook volacno.ibnb plots results. The python script dmd.py calculates an extended DMD spectrum with residuals, employing a truncated SVD (exactDMD) and utilizing dask to handle large datasets with efficient disk usage.

# Installation
Create a conda environment with for the jupyter notebook:
`conda create -n kuramoto_env numpy scipy jupyter matplotlib`.  Activate this environment with `conda activate kuramoto_env`. 

The kuramoto.cu program can be compiled on a computer with the nvidia cuda compiler with `nvcc -O3 -lcuda -lcublas -lcurand kuramoto.cu dp45.cu -o kuramoto`.

# kuromoto Usage
Running `./kuramoto -h` produces the following usage message:
```
usage:	kuramoto [-hvnDRFA] [-N N] [-K K]
	[-c c] [-t t] [-d dt] [-f f] [-s seed] 
	[-I init] [-r rtol] [-a atol] [-g gpu] filebase 

-h for help 
-v for verbose 
-n for normal random frequencies (default is cauchy) 
-D to supress dense output 
-R to reload adjacency, frequencies, and initial conditions from files if possible
-F for fixed timestep 
-A to regenerate volcano adjacency each step to save memory 
N is number of oscillators. Default 5000. 
K is rank of volcano adjacency. Default 5. 
c is the coupling coefficient. Default 3.0. 
t is total integration time. Default 1e2. 
dt is the time between outputs. Default 1e0. 
f is the scale of the frequencies. Default 1e0. 
seed is random seed. Default 1. 
init is uniform random initial condition scale. Default 0. 
rtol is relative error tolerance. Default 0.
atol is absolute error tolerance. Default 1e-6.
gpu is index of the gpu. Default 0.
filebase is base file name for output. 
```


# Output and input files
The kuramoto program requires the positional argument FILEBASE, which is the base name for output and input files. 

FILEBASE.out is a text file, which contains the command line that was run on the first line, the runtime, and step information if -v is set.

FILEBASEfs.dat contains the final state of the phases in a binary format. The final time and timestep are appended at the end for restarting simulations with the -R option.

FILEBASEorder.dat contains the order parameter evaluated in steps of dt, in a binary format.

FILEBASEthetas.dat contains the oscillator phases evaluated in steps of dt, in a binary format. If the -D option is set, this output file is not produced. 

FILEBASEtimes.dat contains the time steps taken by the integrator, in a binary format. If the -D option is set, this output file is not produced. 

FILEBASEadj.dat contains the adjacency matrix in a binary column, major format. If the -D option is set, this output file is not produced. If the -R option is set, the adjacency matrix is loaded from this file rather than being generated randomly.

FILEBASEfrequencies.dat contains the oscillator frequencies in a binary format. If the -R option is set, the frequencies are loaded from this file rather than being generated randomly.

# dmd.py Usage
Running `./dmd.py -h` produces the following usage message:
```
usage: dmd.py [-h] --filebase FILEBASE [--filesuffix FILESUFFIX] [--verbose VERBOSE] [--pcatol PCATOL] [--resmax RESMAX] [--minr MINR] [--maxr MAXR] [--mini MINI] [--maxi MAXI] [--nr NR] [--ni NI]
              [--num_traj NUM_TRAJ] [--order ORDER] [--seed SEED] [--M M] [--D D] [--rank RANK] [--savepca SAVEPCA] [--runpseudo RUNPSEUDO] [--dense_amplitudes DENSE_AMPLITUDES] [--load LOAD] [--mem MEM]
              [--threads THREADS] [--chunks CHUNKS]

Numerical integration of networks of phase oscillators.

options:
  -h, --help            show this help message and exit
  --filebase FILEBASE   Base string for file output.
  --filesuffix FILESUFFIX
                        Suffix string for file output.
  --verbose VERBOSE     Verbose printing.
  --pcatol PCATOL       Reconstruction error cutoff for pca.
  --resmax RESMAX       Maximum residue.
  --minr MINR           Pseudospectra real scale.
  --maxr MAXR           Pseudospectra real scale.
  --mini MINI           Pseudospectra imaginary scale.
  --maxi MAXI           Pseudospectra imaginary scale.
  --nr NR               Number of real pseudospectra points.
  --ni NI               Number of imaginary pseudospectra points.
  --num_traj NUM_TRAJ   Number of trajectories.
  --order ORDER         Number of trajectories.
  --seed SEED           Random seed for library.
  --M M                 Number of angle multiples to include in library.
  --D D                 Number of angle pairs to include in library.
  --rank RANK           Ritz rank for svd.
  --savepca SAVEPCA     Save dense PCA data.
  --runpseudo RUNPSEUDO
                        Run the pseudospectrum calculation.
  --dense_amplitudes DENSE_AMPLITUDES
                        Save dense amplitude data.
  --load LOAD           Load data from previous runs.
  --mem MEM             Memory limit for dask.
  --threads THREADS     Threads for dask.
  --chunks CHUNKS       Chunk size for dask.
```


# Output and input files
The dmd.py program requires the argument FILEBASE, which is the base name for output and input files. 

FILEBASE/FILESUFFIX{X0,X,u,v} are folders containing dask arrays storing the input trajectories, extended input dictionary, and SVD matrices.

FILEBASE/FILESUFFIX{lengths,s,errs,A,res,evals,revecs,levecs,phis,phitildes,bs,zs,its,xis,pseudos}.npy output numpy arrays containing the DMD results.

# Slurm batch jobs and plots

To reproduce the results in the manuscript, first submit the sweepk.sh Slurm job array to generate the trajectory data for a range of coupling constants and adjacency ranks. Then submit the jobdmd{1,2,3,4,5}.sh scripts in sequence to calculate the various DMD spectra. Finally, plot the results in the dmdplot.ipynb Jupyter notebook file.
