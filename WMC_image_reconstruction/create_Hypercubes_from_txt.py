#!/usr/bin/env python
# -*-coding:Utf-8 -*

import numpy as np
import matplotlib.pyplot as plt
import cv2 as cv
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
    for i in range(info.shape[0]):
        if info[i,0] == "Reconstructed_image_rows":
            output_rows = int(info[i,1])
        if info[i,0] == "Reconstructed_image_cols":
            output_cols = int(info[i,1])
        if info[i,0] == "Binning":
            Binning = int(info[i,1])

    #Get modelled volume
    struct = scipy.io.loadmat(path+"../cst.mat")
    info_model = struct['info_model']
    vol = info_model[0][0][0][0][0][11]

    #Get segmentation map (with binning)
    img_seg = vol[0:Binning*output_rows:Binning,0:Binning*output_cols:Binning,0]
    img_seg = img_seg - 1 #sart the label from 0 ->nb class -1

    # plt.imshow(img_seg)
    # plt.show()


    for t in range(np.size(time)):
        #Init hypercube
        dr = np.zeros((output_rows,output_cols,np.size(wavelength)))
        mp = np.zeros((output_rows,output_cols,np.size(wavelength)))


        for w in range(np.size(wavelength)):
            # Remove first and last row/column
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

        #Save results
        np.savez(path+Patient+"_Hypercube_t_"+str(t),
                Diffuse_reflectance = Diffuse_reflectance,
                Mean_path = Mean_path,
                wavelength = w_interp,
                info = info,
                volume_modelled = vol,
                Segmented_tissue = img_seg)



##


import cv2
import numpy as np
import matplotlib.pyplot as plt
from skimage.restoration import denoise_nl_means, estimate_sigma


path = path = "/home/caredda/DVP/simulation/output_mcxlab/output_Patient1_repeat_100/results3/"
dr = np.loadtxt(path+"dr_400_t_0.txt")
dr[np.isnan(dr)] = 0
mp = np.loadtxt(path+"mp_400_t_0.txt")
mp[np.isnan(mp)] = 0


patch_kw = dict(patch_size=5,      # 5x5 patches
                patch_distance=6,  # 13x13 search area
                channel_axis=-1)

h = 0.6

# denoise dr
# Graphics processing units-accelerated adaptive nonlocal means filter for denoising three-dimensional Monte Carlo photon transport simulations
sigma_est = np.mean(estimate_sigma(dr, channel_axis=-1))
dr = np.expand_dims(dr, axis=2)
dr_denoise = denoise_nl_means(dr, h=h * sigma_est, sigma=sigma_est,
                                 fast_mode=True, **patch_kw)

# denoise mp
sigma_est = np.mean(estimate_sigma(mp, channel_axis=-1))
mp = np.expand_dims(mp, axis=2)
mp_denoise = denoise_nl_means(mp, h=h * sigma_est, sigma=sigma_est,
                                 fast_mode=True, **patch_kw)

plt.close('all')
plt.figure()
plt.subplot(121)
plt.imshow(dr)
plt.subplot(122)
plt.imshow(dr_denoise)
plt.show()

plt.figure()
plt.subplot(121)
plt.imshow(mp)
plt.subplot(122)
plt.imshow(mp_denoise)
plt.show()


