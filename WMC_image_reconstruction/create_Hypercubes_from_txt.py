#!/usr/bin/env python
# -*-coding:Utf-8 -*

import numpy as np
import matplotlib.pyplot as plt
from scipy import interpolate


# Temporal vector
time = 0

#Type of simulation
type = "surface"

#Binning
binning = 1

#Wavelength
wavelength = np.arange(400,1010,10)
w_interp = np.arange(400,1001)

# path that contains the results
path = "/home/caredda/DVP/simulation/output_mcxlab/output_Patient1/results/"



for t in range(np.size(time)):
    #Init hypercuve
    temp = np.loadtxt(path+"dr_"+type+"_"+str(wavelength[0])+"_binning_"+str(binning)+"_t_0.txt")
    dr = np.zeros((temp.shape[0],temp.shape[1],np.size(wavelength)))
    mp = np.zeros((temp.shape[0],temp.shape[1],np.size(wavelength)))



    for w in range(np.size(wavelength)):
        dr[:,:,w] = np.loadtxt(path+"dr_"+type+"_"+str(wavelength[w])+"_binning_"+str(binning)+"_t_"+str(t)+".txt")
        mp[:,:,w] = np.loadtxt(path+"mp_"+type+"_"+str(wavelength[w])+"_binning_"+str(binning)+"_t_"+str(t)+".txt")

    #interpolate
    Diffuse_reflectance = np.zeros((dr.shape[0],dr.shape[1],np.size(w_interp)))
    Mean_path = np.zeros((dr.shape[0],dr.shape[1],np.size(w_interp)))

    for x in range(dr.shape[0]):
        for y in range(dr.shape[1]):
            f = interpolate.interp1d(wavelength,dr[x,y,:], kind='cubic')
            Diffuse_reflectance[x,y,:] = f(w_interp)

            f = interpolate.interp1d(wavelength,mp[x,y,:], kind='cubic')
            Mean_path[x,y,:] = f(w_interp)

    np.savez(path+"Hypercube_"+type+"_binning_"+str(binning)+"_t_"+str(t),
            Diffuse_reflectance = Diffuse_reflectance,
            Mean_path = Mean_path,
            wavelength = w_interp)




