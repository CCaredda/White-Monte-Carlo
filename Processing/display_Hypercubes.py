#!/usr/bin/env python
# -*-coding:Utf-8 -*

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.axes_grid1 import make_axes_locatable

#Patient
Patient = "Patient2"

#Path
path = "/home/caredda/DVP/simulation/output_mcxlab/results/"

#time
t = 0

#Load data
data = np.load(path+Patient+"_Hypercube_t_"+str(t)+".npz")
Diffuse_reflectance = data['Diffuse_reflectance']
Mean_path = data['Mean_path']
Wavelength = data['wavelength']

# display data
w = np.array([500,800])

plt.close('all')
for i in range(w.shape[0]):
    id_w = np.where((Wavelength - w[i]) == 0)[0][0]
    plt.figure()
    plt.suptitle(str(w[i])+" nm")
    plt.subplot(121)
    ax = plt.gca()
    ax.set_title("Diffuse reflectance")
    im = ax.imshow(Diffuse_reflectance[:,:,id_w])
    divider = make_axes_locatable(ax)
    cax = divider.append_axes("right", size="5%", pad=0.05)
    plt.colorbar(im, cax=cax)

    plt.subplot(122)
    ax = plt.gca()
    ax.set_title("Mean path")
    im = ax.imshow(Mean_path[:,:,id_w])
    divider = make_axes_locatable(ax)
    cax = divider.append_axes("right", size="5%", pad=0.05)
    plt.colorbar(im, cax=cax)

    plt.show()


pt_BV = [42,37]
pt_GM = [19,56]


plt.figure()
plt.subplot(121)
plt.title("Diffuse Reflectance")
plt.plot(Wavelength,Diffuse_reflectance[pt_BV[0],pt_BV[1],:],label="Blood vessel")
plt.plot(Wavelength,Diffuse_reflectance[pt_GM[0],pt_GM[1],:],label="Grey matter")
plt.legend(loc="best")
plt.xlabel("Wavelength (nm)")
plt.ylabel("Diffuse reflectance (mm$^{-2}$)")
plt.grid()
plt.subplot(122)
plt.title("Mean path length")
plt.plot(Wavelength,Mean_path[pt_BV[0],pt_BV[1],:],label="Blood vessel")
plt.plot(Wavelength,Mean_path[pt_GM[0],pt_GM[1],:],label="Grey matter")
plt.legend(loc="best")
plt.xlabel("Wavelength (nm)")
plt.ylabel("Mean path length (mm)")
plt.grid()
plt.show()


# Compute coeff of variation
cv_mp = np.zeros(Wavelength.shape[0])
cv_dr = np.zeros(Wavelength.shape[0])

for i in range(Wavelength.shape[0]):
    cv_dr[i] = np.std(Diffuse_reflectance[0:20,0:20,i])/np.mean(Diffuse_reflectance[0:20,0:20,i])
    cv_mp[i] = np.std(Mean_path[0:20,0:20,i])/np.mean(Mean_path[0:20,0:20,i])

plt.figure()
plt.suptitle("Coefficient variation")
plt.subplot(121)
plt.title("Diffuse reflectance")
plt.plot(Wavelength,100*cv_dr)
plt.xlabel("Wavelength (nm)")
plt.ylabel("cv (%)")
plt.subplot(122)
plt.title("Mean path length")
plt.plot(Wavelength,100*cv_mp)
plt.xlabel("Wavelength (nm)")
plt.ylabel("cv (%)")
plt.show()
