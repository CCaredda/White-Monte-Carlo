#!/usr/bin/env python
# -*-coding:Utf-8 -*

import numpy as np
import matplotlib.pyplot as plt


mp = np.loadtxt("mp.txt")
dr = np.loadtxt("dr.txt")


ft = 20

plt.figure()
plt.subplot(121)
plt.title("Diffuse reflectance",fontsize=ft)
img = plt.imshow(dr)
cb = plt.colorbar(img)
cb.ax.set_ylabel("$mm-2$",fontsize=ft)

plt.subplot(122)
plt.title("Mean path length",fontsize=ft)
img = plt.imshow(mp)
cb = plt.colorbar(img)
cb.ax.set_ylabel("mm",fontsize=ft)
plt.show()

