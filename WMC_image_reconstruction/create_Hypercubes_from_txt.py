#!/usr/bin/env python
# -*-coding:Utf-8 -*

import numpy as np
import matplotlib.pyplot as plt
from scipy import interpolate
import scipy.io

# path that contains the results
array_Patient = np.array(["Patient1"])
for Patient in array_Patient:
    path = "/home/caredda/DVP/simulation/output_mcxlab/output_"+Patient+"/results/"

    # Temporal vector
    time = 0

    #Wavelength
    w_start = 400
    w_end = 1000
    wavelength = np.arange(w_start,w_end+10,10)
    w_interp = np.arange(w_start,w_end+1)

    #get resolution
    info = np.genfromtxt(path+"info_out.txt",dtype='str')

    #Get modelled volume
    struct = scipy.io.loadmat(path+"../cst.mat")
    info_model = struct['info_model']
    vol = info_model[0][0][0][0][0][11]
    print(vol.shape)


    for t in range(np.size(time)):
        #Init hypercuve
        temp = np.loadtxt(path+"dr_"+str(wavelength[0])+"_t_0.txt")
        dr = np.zeros((temp.shape[0],temp.shape[1],np.size(wavelength)))
        mp = np.zeros((temp.shape[0],temp.shape[1],np.size(wavelength)))



        for w in range(np.size(wavelength)):
            dr[:,:,w] = np.loadtxt(path+"dr_"+str(wavelength[w])+"_t_"+str(t)+".txt")
            mp[:,:,w] = np.loadtxt(path+"mp_"+str(wavelength[w])+"_t_"+str(t)+".txt")

        #interpolate
        Diffuse_reflectance = np.zeros((dr.shape[0],dr.shape[1],np.size(w_interp)))
        Mean_path = np.zeros((dr.shape[0],dr.shape[1],np.size(w_interp)))

        for x in range(dr.shape[0]):
            for y in range(dr.shape[1]):
                f = interpolate.interp1d(wavelength,dr[x,y,:], kind='cubic')
                Diffuse_reflectance[x,y,:] = f(w_interp)

                f = interpolate.interp1d(wavelength,mp[x,y,:], kind='cubic')
                Mean_path[x,y,:] = f(w_interp)

        np.savez(path+Patient+"_Hypercube_t_"+str(t),
                Diffuse_reflectance = Diffuse_reflectance,
                Mean_path = Mean_path,
                wavelength = w_interp,
                info = info,
                volume_modelled = vol)




