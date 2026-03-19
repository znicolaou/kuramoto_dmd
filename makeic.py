#!/usr/bin/env python
import numpy as np
import os
import argparse
import sys

if __name__ == "__main__":

    #Command line arguments
    parser = argparse.ArgumentParser(description='Numerical integration of networks of phase oscillators.')
    parser.add_argument("--filebase", type=str, required=True, dest='filebase', help='Base string for file output.')
    parser.add_argument("-N", type=int, required=False, dest='N', default=10000, help='Number of oscillators.')
    parser.add_argument("-K", type=int, required=False, dest='K', default=1, help='Rank.')
    parser.add_argument("--seed", type=int, required=False, dest='seed', default=1, help='Seed for frequencies and adjacency.')
    parser.add_argument("-c", type=float, required=False, dest='c', default=1.75, help='Coupling strength.')
    parser.add_argument("--dt", type=float, required=False, dest='dt', default=1E-2, help='Initial step.')
    parser.add_argument("-T", type=float, required=False, dest='T', default=100, help='Integration time.')
    args = parser.parse_args()
    print(*sys.argv,flush=True)


    filebase=args.filebase
    N=args.N
    K=args.K
    c=args.c
    T=args.T
    seed=args.seed
    dt=args.dt
    fs=np.zeros(N+2)
    ns=[0,1,-1]
    omega=np.zeros(N)
    fs[-2]=-1E-14
    fs[-1]=dt
    
    os.system('mkdir -p %s'%(filebase))
    #Generate three intial conditions and save to files
    for n in np.arange(len(ns)):
        os.system('rm %s/%i*'%(filebase,n))
        fs[np.argsort(-omega)]=ns[n]*(2*np.pi*np.arange(N)/N-np.pi)
        fs.tofile('%s/%ifs.dat'%(filebase,n))
        print('bash -c "module load cuda && ./kuramoto_64 -N %i -K %i -c %f -t %f -d %f -s %i -a %e -D 1 -nvAR %s/%i"'%(N,K,c,T,dt,seed,1E-10,filebase,n))
        os.system('bash -c "module load cuda && ./kuramoto_64 -N %i -K %i -c %f -t %f -d %f -s %i -a %e -D 1 -nvAR %s/%i"'%(N,K,c,T,dt,seed,1E-10,filebase,n))
        omega=np.fromfile('%s/0frequencies.dat'%(filebase),dtype=np.float64)
