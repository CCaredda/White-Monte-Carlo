#!/usr/bin/env python
# -*-coding:Utf-8 -*

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.axes_grid1 import make_axes_locatable
import matplotlib.patches as mpatches

from mpl_toolkits.axes_grid1.inset_locator import zoomed_inset_axes
from mpl_toolkits.axes_grid1.inset_locator import mark_inset


## Plot image on the surface
#Patient
Patient = "Patient2"
# Patient = "Synthetic_data"

#Path
# path = "/home/caredda/Videos/Data_simulation/raw/"
# path = "/home/caredda/Videos/Data_simulation/Patient2/results_binning_4/"
# # path = "/home/caredda/Videos/Data_simulation/Patient2/results_no_binning/"
path = "/home/caredda/Videos/Data_simulation/Patient2/output/results_arteries/"
#time
t = 0

#Load data
data = np.load(path+Patient+"_Hypercube_t_"+str(t)+".npz")
Diffuse_reflectance = data['Diffuse_reflectance']

#convert in µm-2
Diffuse_reflectance = Diffuse_reflectance*1e6

Mean_path = data['Mean_path']
Wavelength = data['wavelength']

segmented_tissue = data['Segmented_tissue']
vol = data['volume_modelled']
info = data['info']

x_reso = float(info[np.where(info[:,0] == "Reconstructed_image_reso_x_mm")[0].item(),1])
y_reso = float(info[np.where(info[:,0] == "Reconstructed_image_reso_y_mm")[0].item(),1])
reso_tissue = float(info[np.where(info[:,0] == "Resolution_tissue_mm")[0].item(),1])

x_tissue = np.arange(vol.shape[1])*reso_tissue
y_tissue = np.arange(vol.shape[0])*reso_tissue


x = np.arange(segmented_tissue.shape[1])*x_reso
y = np.arange(segmented_tissue.shape[0])*y_reso


# display data
w = np.array([500,900])


cmap = 'plasma'

plt.rcParams.update({'font.size': 18})


rows_pts = [68,79,68]
cols_pts = [121,117,135]
colors = ['grey','magenta','r']
labels = ['Grey matter','Small blood vessels','Large blood vessels']

plt.close('all')



# id_w = np.where((Wavelength - w[0]) == 0)[0][0]
# plt.figure()
# ax = plt.gca()
# # ax.set_title("Diffuse reflectance ("+str(w[i])+ "nm)")
# im = ax.imshow(Diffuse_reflectance[:,:,id_w],cmap=cmap,extent=[x.min(), x.max(), y.min(), y.max()])#,vmin = 0, vmax = max_dr,)
#
# divider = make_axes_locatable(ax)
# cax = divider.append_axes("right", size="5%", pad=0.05)
# cb = plt.colorbar(im, cax=cax)
# cb.set_label("$\mu m^{-2}$")
# ax.set_xlabel("x (mm)")
# ax.set_ylabel("y (mm)")
# plt.show()
#
#
# plt.figure()
# ax = plt.gca()
# ax = plt.gca()
# # ax.set_title("Mean path ("+str(w[i])+ "nm)")
# im = ax.imshow(Mean_path[:,:,id_w],cmap=cmap,extent=[x.min(), x.max(), y.min(), y.max()])#,vmin = 0, vmax = Mean_path.max())
# divider = make_axes_locatable(ax)
# cax = divider.append_axes("right", size="5%", pad=0.05)
# cb = plt.colorbar(im, cax=cax)
# cb.set_label("mm")
# ax.set_xlabel("x (mm)")
# ax.set_ylabel("y (mm)")
# plt.show()

max_dr = np.array([])
max_mp = np.array([])
for i in range(w.shape[0]):
    id_w = np.where((Wavelength - w[i]) == 0)[0][0]
    max_dr = np.append(max_dr,Diffuse_reflectance[:,:,id_w])
    max_mp = np.append(max_mp,Mean_path[:,:,id_w])

plt.figure()
for i in range(w.shape[0]):
    plt.subplot(w.shape[0],2,i*2+1)
    id_w = np.where((Wavelength - w[i]) == 0)[0][0]

    ax = plt.gca()
    ax.set_title("Diffuse reflectance ("+str(w[i])+ "nm)")
    im = ax.imshow(Diffuse_reflectance[:,:,id_w],vmin = 0, vmax = max_dr.max(),cmap=cmap,extent=[x.min(), x.max(), y.min(), y.max()])

    divider = make_axes_locatable(ax)
    cax = divider.append_axes("right", size="5%", pad=0.05)
    cb = plt.colorbar(im, cax=cax)
    cb.set_label("$\mu m^{-2}$")

    for j in range(len(rows_pts)):
        ax.plot(cols_pts[j]*x_reso,y[-1]-rows_pts[j]*y_reso,color=colors[j],marker='o',markersize=7)

    ax.set_xlabel("x (mm)")
    ax.set_ylabel("y (mm)")

    # ax.axis('off')

    plt.subplot(w.shape[0],2,i*2+2)
    ax = plt.gca()
    ax.set_title("Mean path ("+str(w[i])+ "nm)")
    im = ax.imshow(Mean_path[:,:,id_w], vmin = 0, vmax = max_mp.max(),cmap=cmap,extent=[x.min(), x.max(), y.min(), y.max()])
    divider = make_axes_locatable(ax)
    cax = divider.append_axes("right", size="5%", pad=0.05)
    cb = plt.colorbar(im, cax=cax)
    cb.set_label("mm")

    for j in range(len(rows_pts)):
        ax.plot(cols_pts[j]*x_reso,y[-1]-rows_pts[j]*y_reso,color=colors[j],marker='o',markersize=7)

    # ax.axis('off')
    ax.set_xlabel("x (mm)")
    ax.set_ylabel("y (mm)")
plt.show()



## Plot segmentation map and spectra for arteries and veins

#Patient
Patient = "Patient2"
# Patient = "Synthetic_data"

#Path
array_path = np.array(["/home/caredda/Videos/Data_simulation/Patient2/output/results_arteries/",
                       "/home/caredda/Videos/Data_simulation/Patient2/output/results_veins/"])

#time
t = 0

#Load data
data = np.load(array_path[0]+Patient+"_Hypercube_t_"+str(t)+".npz")
Diffuse_reflectance = data['Diffuse_reflectance']

#convert in µm-2
Diffuse_reflectance = Diffuse_reflectance*1e6

Mean_path = data['Mean_path']
Wavelength = data['wavelength']

segmented_tissue = data['Segmented_tissue']
vol = data['volume_modelled']
info = data['info']

#Load path veins
data = np.load(array_path[1]+Patient+"_Hypercube_t_"+str(t)+".npz")
Diffuse_reflectance_veins = data['Diffuse_reflectance']
#convert in µm-2
Diffuse_reflectance_veins = Diffuse_reflectance_veins*1e6
Mean_path_veins = data['Mean_path']



#Create x and y axes
x_reso = float(info[np.where(info[:,0] == "Reconstructed_image_reso_x_mm")[0].item(),1])
y_reso = float(info[np.where(info[:,0] == "Reconstructed_image_reso_y_mm")[0].item(),1])
reso_tissue = float(info[np.where(info[:,0] == "Resolution_tissue_mm")[0].item(),1])

x_tissue = np.arange(vol.shape[1])*reso_tissue
y_tissue = np.arange(vol.shape[0])*reso_tissue


x = np.arange(segmented_tissue.shape[1])*x_reso
y = np.arange(segmented_tissue.shape[0])*y_reso


cmap = 'plasma'

plt.rcParams.update({'font.size': 18})


rows_pts = [68,79,68]
cols_pts = [121,117,135]
colors = ['grey','magenta','r']
labels = ['Grey matter','Small blood vessels','Large blood vessels']

plt.close('all')

# make a color map of fixed colors
mask_segmenation = vol[:,:,0]
mask_segmenation[mask_segmenation == 4] = 3 # replace 4 by 3
col = ['grey', 'red','magenta']
cmap = plt.cm.colors.ListedColormap(col)


plt.figure()
ax = plt.gca()
# ax.set_title("Segmentation map")
im = ax.imshow(mask_segmenation,cmap=cmap,extent=[x_tissue.min(), x_tissue.max(), y_tissue.min(), y_tissue.max()])

# create a patch (proxy artist) for every color
patches = []
patches.append(mpatches.Patch(color=col[0], label=labels[0]))
patches.append(mpatches.Patch(color=col[1], label=labels[2]))
patches.append(mpatches.Patch(color=col[2], label=labels[1]))
plt.legend(handles=patches, bbox_to_anchor=(0.05, 1), loc=2, borderaxespad=0., fontsize=ft_legend )


# Create a Rectangle
r = [y_tissue[-1]-316*reso_tissue, y_tissue[-1]-410*reso_tissue]
c = [564*reso_tissue, 692*reso_tissue]

axins = zoomed_inset_axes(ax, zoom = 3, loc='lower left',borderpad=2) # zoom = 6
axins.imshow(mask_segmenation,cmap=cmap,extent=[x_tissue.min(), x_tissue.max(), y_tissue.min(), y_tissue.max()])

# sub region of the original image
x1, x2, y1, y2 = c[0], c[1], r[0], r[1]
axins.set_xlim(x1, x2)
axins.set_ylim(y2, y1)


# draw a bbox of the region of the inset axes in the parent axes and
# connecting lines between the bbox and the inset axes area
mark_inset(ax, axins, loc1=2, loc2=4)#,color='k')

for j in range(len(rows_pts)):
    ax.plot(cols_pts[j]*5*reso_tissue,y_tissue[-1]-rows_pts[j]*5*reso_tissue,color='k',marker='o',markersize=10)
    axins.plot(cols_pts[j]*5*reso_tissue,y_tissue[-1]-rows_pts[j]*5*reso_tissue,color='k',marker='o',markersize=10)

# ax.axis('off')
# axins.axis('off')

# plt.xticks(visible=False)
# plt.yticks(visible=False)

# ax.axis('off')

# plt.draw()

ax.set_xlabel("x (mm)")
ax.set_ylabel("y (mm)")
# plt.axis('off')
plt.show()


ft_legend = 14

plt.figure()
plt.subplot(121)
plt.title("Diffuse Reflectance")
for i in range(len(rows_pts)):
    plt.plot(Wavelength,Diffuse_reflectance[rows_pts[i],cols_pts[i],:],linewidth=3,color=colors[i])

for i in range(len(rows_pts)):
    plt.plot(Wavelength,Diffuse_reflectance_veins[rows_pts[i],cols_pts[i],:],linestyle=':',linewidth=3,color=colors[i])


# plt.legend(loc="best")
plt.xlabel("Wavelength (nm)")
plt.ylabel("Diffuse reflectance ($\mu m^{-2}$)")
plt.grid()

# create a patch (proxy artist) for every color
patches = []
patches.append(mpatches.Patch(color=col[0], label=labels[0]))
patches.append(mpatches.Patch(color=col[1], label=labels[2]))
patches.append(mpatches.Patch(color=col[2], label=labels[1]))
# plt.legend(handles=patches, bbox_to_anchor=(0.05, 1), loc=2, borderaxespad=0.,fontsize=ft_legend )
plt.legend(handles=patches, loc="lower right", fontsize=ft_legend )

plt.subplot(122)
plt.title("Mean path length")
for i in range(len(rows_pts)):
    plt.plot(Wavelength,Mean_path[rows_pts[i],cols_pts[i],:],linewidth=3,color=colors[i])

for i in range(len(rows_pts)):
    plt.plot(Wavelength,Mean_path_veins[rows_pts[i],cols_pts[i],:],linestyle=':',linewidth=3,color=colors[i])

# plt.legend(loc="best")
plt.xlabel("Wavelength (nm)")
plt.ylabel("Mean path length (mm)")
plt.grid()

# create a patch (proxy artist) for every color
patches = []
patches.append(mpatches.Patch(color=col[0], label=labels[0]))
patches.append(mpatches.Patch(color=col[1], label=labels[2]))
patches.append(mpatches.Patch(color=col[2], label=labels[1]))
# plt.legend(handles=patches, bbox_to_anchor=(0.05, 1), loc=2, borderaxespad=0.,fontsize=ft_legend )
plt.legend(handles=patches, loc="lower right", fontsize=ft_legend )

plt.show()


## Plot image on sensor

cmap = 'plasma'
plt.rcParams.update({'font.size': 18})


#Patient
Patient = "Patient2"

#Path
path = np.array(["/home/caredda/Videos/Data_simulation/raw/",
                "/home/caredda/Videos/Data_simulation/Patient2/results_sensor_f30_wd_400/",
                "/home/caredda/Videos/Data_simulation/Patient2/results_sensor_f30_wd_402/"])

#time
t = 0

#Load data surface
data = np.load(path[0]+Patient+"_Hypercube_t_"+str(t)+".npz")
Diffuse_reflectance_surface = data['Diffuse_reflectance']
Diffuse_reflectance_surface = Diffuse_reflectance_surface[:,:,np.where(data['wavelength']==500)[0].item()]
info = data['info']

x_reso = float(info[np.where(info[:,0] == "Reconstructed_image_reso_x_mm")[0].item(),1])
y_reso = float(info[np.where(info[:,0] == "Reconstructed_image_reso_y_mm")[0].item(),1])

x_surface = np.arange(Diffuse_reflectance_surface.shape[1])*x_reso
y_surface = np.arange(Diffuse_reflectance_surface.shape[0])*y_reso

#Load data sensor wd 400
data = np.load(path[1]+Patient+"_Hypercube_t_"+str(t)+".npz")
Diffuse_reflectance_wd_400 = data['Diffuse_reflectance']
info_f30 = data['info']
Diffuse_reflectance_wd_400 = Diffuse_reflectance_wd_400[:,:,0]

#Load data sensor wd 402
data = np.load(path[2]+Patient+"_Hypercube_t_"+str(t)+".npz")
Diffuse_reflectance_wd_402 = data['Diffuse_reflectance']
info_f31 = data['info']
Diffuse_reflectance_wd_402 = Diffuse_reflectance_wd_402[:,:,0]




plt.close('all')
plt.figure()

ax = plt.subplot(121)
ax.set_title("Diffuse reflectance at 500 nm (Working distance 400 mm)")
im = ax.imshow(Diffuse_reflectance_wd_400,cmap=cmap)#,extent=[0, 6, 0, 4.8])

divider = make_axes_locatable(ax)
cax = divider.append_axes("right", size="5%", pad=0.05)
cb = plt.colorbar(im, cax=cax)
cb.set_label("$mm^{-2}$")


ax.set_xlabel("x (sensor pixels)")
ax.set_ylabel("y (sensor pixels)")
# ax.axis('off')

ax = plt.subplot(122)
ax.set_title("Diffuse reflectance at 500 nm (Working distance 402 mm)")
im = ax.imshow(Diffuse_reflectance_wd_402,cmap=cmap)#,extent=[0, 6, 0, 4.8])

divider = make_axes_locatable(ax)
cax = divider.append_axes("right", size="5%", pad=0.05)
cb = plt.colorbar(im, cax=cax)
cb.set_label("$mm^{-2}$")


ax.set_xlabel("x (sensor pixels)")
ax.set_ylabel("y (sensor pixels)")
# ax.axis('off')
plt.show()

