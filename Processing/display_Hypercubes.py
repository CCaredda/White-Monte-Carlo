#!/usr/bin/env python
# -*-coding:Utf-8 -*

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.axes_grid1 import make_axes_locatable




#Patient
Patient = "Patient2"
# Patient = "Synthetic_data"

#Path
path = "/home/caredda/DVP/Deep_Learning/data_simulations/raw/"
# path = "/home/caredda/DVP/Deep_Learning/data_simulations/synthetic/"
#time
t = 0

#Load data
data = np.load(path+Patient+"_Hypercube_t_"+str(t)+".npz")
Diffuse_reflectance = data['Diffuse_reflectance']
Mean_path = data['Mean_path']
Wavelength = data['wavelength']

# display data
w = np.array([500,900])


cmap = 'plasma'

plt.close('all')
plt.figure()
for i in range(w.shape[0]):
    plt.subplot(w.shape[0],2,i*2+1)
    id_w = np.where((Wavelength - w[i]) == 0)[0][0]

    ax = plt.gca()
    ax.set_title("Diffuse reflectance ("+str(w[i])+ "nm)")
    im = ax.imshow(Diffuse_reflectance[:,:,id_w],vmin = 0, vmax = Diffuse_reflectance[:,:,id_w].max(),cmap=cmap)
    divider = make_axes_locatable(ax)
    cax = divider.append_axes("right", size="5%", pad=0.05)
    cb = plt.colorbar(im, cax=cax)
    cb.set_label("$mm^{-2}$")

    plt.subplot(w.shape[0],2,i*2+2)
    ax = plt.gca()
    ax.set_title("Mean path ("+str(w[i])+ "nm)")
    im = ax.imshow(Mean_path[:,:,id_w], vmin = Mean_path[:,:,id_w].min(), vmax = Mean_path[:,:,id_w].max(),cmap=cmap)
    divider = make_axes_locatable(ax)
    cax = divider.append_axes("right", size="5%", pad=0.05)
    cb = plt.colorbar(im, cax=cax)
    cb.set_label("mm")

plt.show()


pt_BV = [61,144]
pt_GM = [41,116]


plt.figure()
plt.subplot(121)
plt.title("Diffuse Reflectance")
plt.plot(Wavelength,Diffuse_reflectance[pt_BV[0],pt_BV[1],:],label="Blood vessel",linewidth=3)
plt.plot(Wavelength,Diffuse_reflectance[pt_GM[0],pt_GM[1],:],label="Grey matter",linewidth=3)
plt.legend(loc="best")
plt.xlabel("Wavelength (nm)")
plt.ylabel("Diffuse reflectance (mm$^{-2}$)")
plt.grid()
plt.subplot(122)
plt.title("Mean path length")
plt.plot(Wavelength,Mean_path[pt_BV[0],pt_BV[1],:],label="Blood vessel",linewidth=3)
plt.plot(Wavelength,Mean_path[pt_GM[0],pt_GM[1],:],label="Grey matter",linewidth=3)
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

# plt.figure()
# plt.suptitle("Coefficient variation")
# plt.subplot(121)
# plt.title("Diffuse reflectance")
# plt.plot(Wavelength,100*cv_dr)
# plt.xlabel("Wavelength (nm)")
# plt.ylabel("cv (%)")
# plt.subplot(122)
# plt.title("Mean path length")
# plt.plot(Wavelength,100*cv_mp)
# plt.xlabel("Wavelength (nm)")
# plt.ylabel("cv (%)")
# plt.show()


