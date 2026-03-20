#!/usr/bin/env python
import numpy as np
import os
import argparse
import sys

if __name__ == "__main__":

    #Command line arguments
    parser = argparse.ArgumentParser(description='Numerical integration of networks of phase oscillators.')
    parser.add_argument("--filebase", type=str, required=True, dest='filebase', help='Base string for file output.')
    parser.add_argument("--remove", type=bool, required=False, default=True, dest='remove', help='Remove files.')
    args = parser.parse_args()
    print(*sys.argv,flush=True)


    filebase=args.filebase
    
    # Make avgorder from cluster output

    Ns=100000*np.arange(1,3)
    Ns=os.listdir(args.filebase)
    print(Ns)
    for N in Ns:
        Ks=os.listdir(args.filebase+'/%s'%(N))
        print(N, Ks)
        for K in Ks:
            rs=[]
            if args.remove and os.path.exists(args.filebase+'/%s/%s/orders.npy'%(N,K)):
                rs=np.load(args.filebase+'/%s/%s/orders.npy'%(N,K)).tolist()
            files=os.listdir(args.filebase+'/%s/%s'%(N,K))
            for file in files:
                if file[-9:]=='order.dat':
                    r=np.fromfile(args.filebase+'/%s/%s/%s'%(N,K,file),dtype=np.float32)
                    if r.shape[0]==10001:
                        rs=rs+[r]
                        if args.remove:
                            os.remove(filebase+'/%s/%s/%sfs.dat'%(N,K,file[:-9]))
                            os.remove(filebase+'/%s/%s/%s.out'%(N,K,file[:-9]))
                            os.remove(filebase+'/%s/%s/%sorder.dat'%(N,K,file[:-9]))
                            os.remove(filebase+'/%s/%s/%sfrequencies.dat'%(N,K,file[:-9]))
                    else:
                        print(args.filebase+'/%s/%s/%s'%(N,K,file),len(r))
            if len(rs)>0:
                print('%s\t%s\t%i\t\n'%(N,K,len(rs)),end='')
                try:
                    r1=np.mean(rs,axis=0)
                    np.save(args.filebase+'/%s/%s/avgorder.npy'%(N,K),r1)
                    np.save(args.filebase+'/%s/%s/orders.npy'%(N,K),np.array(rs))

                except Exception as e:
                    print(np.where([r.shape[0]!=10001 for r in rs])[0])
