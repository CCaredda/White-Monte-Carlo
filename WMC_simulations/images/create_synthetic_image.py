import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib import colors
import cv2 as cv

# Create synthetic image

path = "/home/caredda/DVP/simulation/CREATIS-UCL-White-Monte-Carlo-Framework/WMC_simulations/images/centered_blood_vessel/"

reso = 0.345

# size_vessel = 7
size_vessel = 3
#LBV mask
LBV_mask = np.zeros((64,64),dtype=np.uint8)
# LBV_mask[:,40:40+size_vessel] = 1
LBV_mask[:,30:35] = 1


#GM mask
GM_mask = np.ones((64,64),dtype=np.uint8)
# GM_mask[:,40:47] = 0


#Activated GM
act_GM_mask = np.zeros((64,64),dtype=np.uint8)
# act_GM_mask[23:41,22:40] = 1

#zero mask
zeros_mask = np.zeros((64,64),dtype=np.uint8)

#Mask segmentation
mask_segmenation = np.ones((64,64),dtype=np.uint8)
mask_segmenation[LBV_mask==1] = 2
mask_segmenation[act_GM_mask==1] = 4


# #Write mask
cv.imwrite(path+"mask_activated_capillaries.png",zeros_mask)
cv.imwrite(path+"mask_activated_large_vessels.png",zeros_mask)
cv.imwrite(path+"mask_activated_grey_matter.png",act_GM_mask)

cv.imwrite(path+"mask_capillaries.png",zeros_mask)
cv.imwrite(path+"mask_large_vessels.png",LBV_mask)
cv.imwrite(path+"mask_grey_matter.png",GM_mask)

cv.imwrite(path+"mask_segmentation.png",mask_segmenation)



# plt.close('all')
# # plt.subplot(131)
# # plt.imshow(LBV_mask)
# # plt.subplot(132)
# # plt.imshow(GM_mask)
# # plt.subplot(133)
# # plt.imshow(act_GM_mask)
# plt.imshow(mask_segmenation)
# plt.show()

# make a color map of fixed colors
mask_segmenation[mask_segmenation == 4] = 3 # replace 4 by 3
# colors = ['grey','green', 'red']
colors = ((181/255,197/255,181/255),(0,0,0),(152/255,182/255,142/255))
# cmap = plt.cm.colors.ListedColormap(colors)

#temp
mask2 = np.zeros((mask_segmenation.shape[0],mask_segmenation.shape[1],3),dtype=np.uint8)
temp = np.zeros(mask_segmenation.shape)
temp[mask_segmenation==1] = 181
temp[mask_segmenation==2] = 152
mask2[:,:,0] = temp
temp = np.zeros(mask_segmenation.shape)
temp[mask_segmenation==1] = 197
temp[mask_segmenation==2] = 182
mask2[:,:,1] = temp
temp = np.zeros(mask_segmenation.shape)
temp[mask_segmenation==1] = 181
temp[mask_segmenation==2] = 142
mask2[:,:,2] = temp


ft =18
# plt.rcParams.update({'font.size': ft})

plt.close('all')
plt.figure()
ax = plt.gca()
# ax.set_title("Segmentation map")
im = ax.imshow(mask2,extent=[0, mask_segmenation.shape[1]*reso, 0, mask_segmenation.shape[0]*reso])

# create a patch (proxy artist) for every color
patches = []
patches.append(mpatches.Patch(color=colors[0], label="Grey matter"))
patches.append(mpatches.Patch(color=colors[2], label="Blood vessel"))
# patches.append(mpatches.Patch(color=colors[2], label="Activated grey matter"))


# put those patched as legend-handles into the legend
plt.legend(handles=patches, bbox_to_anchor=(0.05, 1), loc=2, borderaxespad=0. ,fontsize=ft)
plt.xlabel('x axis (mm)',fontsize=ft)
plt.ylabel('y axis (mm)',fontsize=ft)
plt.show()
