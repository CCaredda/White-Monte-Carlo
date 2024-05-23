#!/usr/bin/env python
# -*-coding:Utf-8 -*

import numpy as np
import matplotlib.pyplot as plt
import cv2 as cv
from scipy import interpolate
import scipy.io
from skimage.restoration import denoise_nl_means, estimate_sigma

def level_A(z_min, z_med, z_max, z_xy, S_xy, S_max):
    if(z_min < z_med < z_max):
        return level_B(z_min, z_med, z_max, z_xy, S_xy, S_max)
    else:
        S_xy += 2 #increase the size of S_xy to the next odd value.
        if(S_xy <= S_max): #repeat process
            return level_A(z_min, z_med, z_max, z_xy, S_xy, S_max)
        else:
            return z_med



def level_B(z_min, z_med, z_max, z_xy, S_xy, S_max):
    if(z_min < z_xy < z_max):
        return z_xy
    else:
        return z_med



def amf(image, initial_window, max_window):
    """runs the Adaptive Median Filter proess on an image"""
    xlength, ylength = image.shape #get the shape of the image.

    z_min, z_med, z_max, z_xy = 0, 0, 0, 0
    S_max = max_window
    S_xy = initial_window #dynamically to grow

    output_image = image.copy()

    for row in range(S_xy, xlength-S_xy-1):
        for col in range(S_xy, ylength-S_xy-1):
            filter_window = image[row - S_xy : row + S_xy + 1, col - S_xy : col + S_xy + 1] #filter window
            target = filter_window.reshape(-1) #make 1-dimensional
            z_min = np.min(target) #min of intensity values
            z_max = np.max(target) #max of intensity values
            z_med = np.median(target) #median of intensity values
            z_xy = image[row, col] #current intensity

            #Level A & B
            new_intensity = level_A(z_min, z_med, z_max, z_xy, S_xy, S_max)
            output_image[row, col] = new_intensity
    return output_image


#Non local mean filter patch
patch_kw = dict(patch_size=5,      # 5x5 patches
                patch_distance=6,  # 13x13 search area
                channel_axis=-1)

h = 0.6

big_win_med = 7

apply_denoising = 1


# path that contains the results
array_Patient = np.array(["Patient2"])
for Patient in array_Patient:

    print(Patient)
    path = "/home/caredda/Videos/Data_simulation/"+Patient+"/output/results_veins/"

    # Temporal vector
    time = np.array([0]) #np.array([0,1])

    #Wavelength
    # wavelength = np.array([500])
    wavelength = np.arange(400,1000+10,10)

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
        ppl = np.zeros((output_rows,output_cols,np.size(wavelength),6))


        for w in range(np.size(wavelength)):
            # print(w)
            # Load diffuse reflectance
            temp = np.loadtxt(path+"dr_"+str(wavelength[w])+"_t_"+str(t)+".txt")
            temp[np.isnan(temp)] = 0

            if apply_denoising:
                #Estimate standard deviation
                sigma_est = np.mean(estimate_sigma(temp, channel_axis=-1))
                temp = np.expand_dims(temp, axis=2) #expand dimension (to be used be denoise_nl_means)
                #apply denoising
                temp = denoise_nl_means(temp, h=h * sigma_est, sigma=sigma_est,
                                    fast_mode=True, **patch_kw)
                # temp = amf(temp,3,big_win_med)

            dr[:,:,w] = temp


            #load mean path length
            temp = np.loadtxt(path+"mp_"+str(wavelength[w])+"_t_"+str(t)+".txt")
            temp[np.isnan(temp)] = 0


            if apply_denoising:
                #Estimate standard deviation
                sigma_est = np.mean(estimate_sigma(temp, channel_axis=-1))
                temp = np.expand_dims(temp, axis=2) #expand dimension (to be used be denoise_nl_means)
                #apply denoising
                temp = denoise_nl_means(temp, h=h * sigma_est, sigma=sigma_est,
                                    fast_mode=True, **patch_kw)
                # temp = amf(temp,3,big_win_med)
            mp[:,:,w] = temp


            #load ppl
            for p in range(6):
                temp = np.loadtxt(path+"mp_tissue_"+str(p)+"_"+str(wavelength[w])+"_t_"+str(t)+".txt")
                temp[np.isnan(temp)] = 0

                if apply_denoising:
                    #Estimate standard deviation
                    sigma_est = np.mean(estimate_sigma(temp, channel_axis=-1))
                    temp = np.expand_dims(temp, axis=2) #expand dimension (to be used be denoise_nl_means)
                    #apply denoising
                    temp = denoise_nl_means(temp, h=h * sigma_est, sigma=sigma_est,
                                        fast_mode=True, **patch_kw)
                    # temp = amf(temp,3,big_win_med)
                ppl[:,:,w,p] = temp




        #Save results
        np.savez(path+Patient+"_Hypercube_t_"+str(t),
                Diffuse_reflectance = dr,
                Mean_path = mp,
                wavelength = wavelength,
                ppl = ppl,
                info = info,
                volume_modelled = vol,
                Segmented_tissue = img_seg,
                denoising = apply_denoising)

