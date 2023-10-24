#!/usr/bin/env python
# -*-coding:Utf-8 -*

import numpy as np
import matplotlib.pyplot as plt

#Path
path = "/home/caredda/DVP/simulation/output_mcxlab/output_Patient1/results/"

#Type of simulation
type = "surface"

#time
t = 0

#binning
binning = 4

#Load data
data = np.load(path+"Hypercube_surface_binning_"+str(binning)+"_t_"+str(t)+".npz")
Diffuse_reflectance = data['Diffuse_reflectance']
Mean_path = data['Mean_path']
Wavelength = data['wavelength']

# display data
w = np.array([500,600])

plt.close('all')
plt.figure()
plt.suptitle("Diffuse reflectance")
for i in range(np.size(w)):
    plt.subplot(1,np.size(w),i+1)
    plt.title(str(w[i])+" nm")
    id_w = np.where((Wavelength - w[i]) == 0)[0][0]
    plt.imshow(Diffuse_reflectance[:,:,id_w])
plt.show()

plt.figure()
plt.suptitle("Mean path")
for i in range(np.size(w)):
    plt.subplot(1,np.size(w),i+1)
    plt.title(str(w[i])+" nm")
    id_w = np.where((Wavelength - w[i]) == 0)[0][0]
    plt.imshow(Mean_path[:,:,id_w])
plt.show()


pt = [67,96]
plt.figure()
plt.subplot(121)
plt.plot(Wavelength,Diffuse_reflectance[pt[0],pt[1],:])
plt.subplot(122)
plt.plot(Wavelength,Mean_path[pt[0],pt[1],:])
plt.show()
