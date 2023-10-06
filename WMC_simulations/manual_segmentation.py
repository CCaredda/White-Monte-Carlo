## @file manual_segmentation.py
#
# @brief Python script to segment RGB image of brain cortex into six classes:
# - Non activated grey matter
# - Non activated large blood vessels
# - Non activated capillaries
# - Activated grey matter
# - Activated large blood vessels
# - Activated capillaries
#
# @author Charly Caredda
# Contact: caredda.c@gmail.com



import numpy as np
import cv2 as cv
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider, Button
from matplotlib.colors import ListedColormap

# Compute histogram equalization within the surgical window of RGB image
def EqualizeHist(img,mask):
    r = np.copy(img[:,:,0])
    g = np.copy(img[:,:,1])
    b = np.copy(img[:,:,2])
    coord = np.where(mask==255)
    r_pixels = r[coord]
    g_pixels = g[coord]
    b_pixels = b[coord]
    r_equalized_pixels = cv.equalizeHist(r_pixels)
    g_equalized_pixels = cv.equalizeHist(g_pixels)
    b_equalized_pixels = cv.equalizeHist(b_pixels)
    for i, C in enumerate(zip(coord[0], coord[1])):
        r[C[0], C[1]] = r_equalized_pixels[i][0]
        g[C[0], C[1]] = g_equalized_pixels[i][0]
        b[C[0], C[1]] = b_equalized_pixels[i][0]
    return np.dstack([r,g,b])



## Process K-MEans

#Change this
directory_path = "/home/caredda/DVP/simulation/CREATIS-UCL-White-Monte-Carlo-Framework/WMC_simulations/"

# Load image
path = directory_path+"images/Patient1/"
img = cv.imread(path+"initial_img.png")
mask = cv.imread(path+"mask.png",cv.IMREAD_GRAYSCALE)

#find boundrect of the contour of mask
contours, hierarchy = cv.findContours(np.copy(mask), cv.RETR_TREE, cv.CHAIN_APPROX_SIMPLE)
x,y,w,h = cv.boundingRect(contours[0])

mask = mask[y:y+h,x:x+w]
img = img[y:y+h,x:x+w,:]



# Apply histrogtamm equalization
# img_proc = EqualizeHist(img,mask)
img_proc = img

#Only selet pixel inside the ROI
r = np.copy(img_proc[:,:,0])
g = np.copy(img_proc[:,:,1])
b = np.copy(img_proc[:,:,2])
coord = np.where(mask==255)
r_pixels = r[coord]
g_pixels = g[coord]
b_pixels = b[coord]

#Init Z for K-means clustering
Z = np.squeeze(np.dstack([r_pixels,g_pixels,b_pixels]))
Z = Z.astype(np.float32)

# Apply K-means clustering
K = 10
criteria = (cv.TERM_CRITERIA_EPS + cv.TERM_CRITERIA_MAX_ITER, 500, 1.0)
ret,label,center=cv.kmeans(Z,K,None,criteria,10,cv.KMEANS_RANDOM_CENTERS)

# reconstruct the original image
output = np.zeros(mask.shape)

for i, C in enumerate(zip(coord[0], coord[1])):

    output[C[0], C[1]] = label[i]
    output[C[0], C[1]] = label[i]
    output[C[0], C[1]] = label[i]

output = output.astype(np.uint8)

plt.close('all')
plt.imshow(output)
plt.show()

## identify label of large blood vessels and capillaries

#Define Labels
label_BV = np.array([9,3])
label_capillaries = np.array([2])





# Mask lage blood vessels
mask_large_vessels = np.zeros(mask.shape)
for i in range(label_BV.shape[0]):
    mask_large_vessels[output==label_BV[i]] = 255
mask_large_vessels = np.bitwise_and(mask_large_vessels.astype(np.uint8),mask)

#Apply morpho math
kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE,(3,3))
mask_large_vessels = cv.morphologyEx(mask_large_vessels, cv.MORPH_OPEN, kernel,iterations = 1)
mask_large_vessels = cv.morphologyEx(mask_large_vessels, cv.MORPH_CLOSE, kernel,iterations = 1)

# Find contours and remove small ones
contours, hierarchy = cv.findContours(np.copy(mask_large_vessels), cv.RETR_TREE, cv.CHAIN_APPROX_SIMPLE)

# contour area
area_min = 101
mask_large_vessels = np.zeros(mask_large_vessels.shape)
for i in range(len(contours)):
    if cv.contourArea(contours[i]) > area_min:
        cv.drawContours(mask_large_vessels,contours,i,255,cv.FILLED)
mask_large_vessels = np.bitwise_and(mask_large_vessels.astype(np.uint8),mask)

#Mask capillaries
mask_capillaries = np.zeros(mask.shape)
for i in range(label_capillaries.shape[0]):
    mask_capillaries[output==label_capillaries[i]] = 255
mask_capillaries = np.bitwise_and(mask_capillaries.astype(np.uint8),mask)

#Apply morpho math
kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE,(3,3))
mask_capillaries = cv.morphologyEx(mask_capillaries, cv.MORPH_OPEN, kernel,iterations = 1)
mask_capillaries = cv.morphologyEx(mask_capillaries, cv.MORPH_CLOSE, kernel,iterations = 1)
mask_capillaries = cv.morphologyEx(mask_capillaries, cv.MORPH_OPEN, kernel,iterations = 1)
mask_capillaries = np.bitwise_and(mask_capillaries.astype(np.uint8),mask)


#mask grey matter
mask_GM = np.bitwise_and(np.bitwise_not(mask_large_vessels),np.bitwise_not(mask_capillaries))



# ## Detect small vessels
#
# img_Eq = EqualizeHist(img_proc,mask)
#
# img_Eq = cv.cvtColor(img_Eq, cv.COLOR_RGB2GRAY)
# kernelSize = 31 # kernelSize is defined as the characteristic diameter of blood vessels in pixels
#
# mask_capillaries = cv.adaptiveThreshold(img_Eq,255,cv.ADAPTIVE_THRESH_GAUSSIAN_C,cv.THRESH_BINARY,kernelSize,0) #Segment vascular network with adaptive thresholding
# mask_capillaries = np.bitwise_not(mask_capillaries)
# mask_capillaries = mask_capillaries*mask
# mask_capillaries = np.bitwise_and(mask_capillaries,np.bitwise_not(mask_large_vessels))
#
#
#
# plt.figure()
# plt.imshow(mask_capillaries)
# plt.show()


## Select functional brain areas

plt.close('all')
plt.imshow(img)
plt.show()

rows = np.array([198, 56, 187, 336])
cols = np.array([101, 231, 236, 143])
radius = 30

## Create segmentation mask

mask_activation = np.zeros(mask.shape)
for i in range(rows.shape[0]):
    cv.circle(mask_activation,(cols[i],rows[i]),radius,255,cv.FILLED)
mask_activation = mask_activation.astype(np.uint8)

#mask actvated grey matter
mask_activated_grey_matter = np.bitwise_and(mask_activation,mask_GM)
mask_activated_large_vessels = np.bitwise_and(mask_activation,mask_large_vessels)
mask_activated_capillaries = np.bitwise_and(mask_activation,mask_capillaries)


##


plt.close('all')
plt.subplot(321)
plt.imshow(mask_GM)
plt.subplot(322)
plt.imshow(mask_activation)
plt.subplot(323)
plt.imshow(mask_large_vessels)
plt.subplot(324)
plt.imshow(mask_activated_large_vessels)
plt.subplot(325)
plt.imshow(mask_capillaries)
plt.subplot(326)
plt.imshow(mask_activated_capillaries)
plt.show()


##

cMap = ListedColormap(['grey', 'red', 'magenta','green','yellow','white'])
label = np.array(["Grey matter","Large blood vessel","Capillaries","Activated grey matter","Activated large vessel","Activated capillaries"])
index = np.linspace(1 + 1/label.shape[0] ,6-1/label.shape[0],6)

mask_output = np.ones(mask.shape)

mask_output[mask_large_vessels>0] = 2
mask_output[mask_capillaries>0] = 3

mask_output[mask_activated_grey_matter>0] = 4
mask_output[mask_activated_large_vessels>0] = 5
mask_output[mask_activated_capillaries>0] = 6

plt.close('all')
plt.figure()
plt.imshow(cv.cvtColor(img,cv.COLOR_BGR2RGB))

plt.figure()
plt.imshow(output)

plt.figure()
heatmap = plt.imshow(mask_output,cmap = cMap)

cbar = plt.colorbar(heatmap)
for i in range(label.shape[0]):
    cbar.ax.text(.5, index[i], label[i], ha='left', va='center')
cbar.ax.get_yaxis().labelpad = 15
cbar.ax.get_yaxis().set_ticks([])

plt.show()



cv.imwrite(path+"mask_grey_matter.png",mask_GM/255)
cv.imwrite(path+"mask_activated_grey_matter.png",mask_activation/255)

cv.imwrite(path+"mask_large_vessels.png",mask_large_vessels/255)
cv.imwrite(path+"mask_activated_large_vessels.png",mask_activated_large_vessels/255)

cv.imwrite(path+"mask_capillaries.png",mask_capillaries/255)
cv.imwrite(path+"mask_activated_capillaries.png",mask_activated_capillaries/255)

# cv.imwrite(path+"mask_segmentation.png",mask_output)

# plt.figure()
# plt.imshow(mask_output)
# plt.show()



