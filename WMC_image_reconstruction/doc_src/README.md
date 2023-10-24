\mainpage
 
 \section intro_sec Introduction
 
This software allows to reconstruct images of mean path length and diffuse reflectance from simulations obtained with a White Monte Carlo model.
Images can be reconstructed at the tissue surface or using a lens to reconstruct the image on a camera sensor.

This software has been developed for the European project Hyperprobe which aims at transforming neuronavigation during glioma resection using novel
hyperspectral imaging technology: 
- https://hyperprobe.eu/
- https://cordis.europa.eu/project/id/101071040

Author: Charly Caredda
Contact: caredda.c@gmail.com
 
 \section install_sec Installation
This program has be tested under Fedora 38 and Ubuntu. Problem may occur under other operating system.
This program is coded in C++ with the framework Qt and the compiler g++.

First Qt should be installed.
- Download the Qt online installer : https://www.qt.io/download-qt-installer?hsCtaTracking=99d9dd4f-5681-48d2-b096-470725510d34%7C074ddad0-fdef-4e53-8aa8-5e8a876d6ab4
- Install the proper Qt version : >5 and <6.

Different libraries and framework should be installed in order to use the softwares properly. 

\subsection Details

This program uses open sources libraries such as OpenCV and Boost.

In order to compile this program using Qt, theses libraries has to be installed.

- Opencv (latest version): sudo dnf install opencv opencv-contrib opencv-doc python3-opencv python3-matplotlib python3-numpy

- Boost (latest version): sudo dnf install boost boost-devel
To install Boost from the sources, follow the guide here: https://www.boost.org/doc/libs/1_63_0/more/getting_started/unix-variants.html

- sudo dnf install python3-pip python3-pyqt5;

Then install python libraries:

- pip install opencv-python numpy matplotlib


\section sec_guide User guide

\subsection sec_optical_changes 1) Model optical changes
This software aims to reconstruct hypercubes : images of diffuse reflectance and mean path length for N wavelengths.
It is also possible to generate T hypercubes for modeling optical changes over time such as:
- Hemodynamic and metabolic responses following cerebral activity
- Hemodynamic changes due to heartbeat and respiratory

Optical changes are indicated in directory 'optical_changes'.
In this directory, six txt files contain the optical changes of six modeled classes:
- activated_capillaries.txt
- activated_large_blood_vessels.txt
- grey_matter.txt
- activated_grey_matter.txt
- capillaries.txt
- large_blood_vessels.txt

For these six files, each line correspond to the temporal evolution of each chromophore:
- Line 1 Water content in % (0-1)
- Line 2 Fat content in % (0-1)
- Line 3 C_HbO2 in (Mol)
- Line 4 C_Hb in (Mol)
- Line 5 C_oxCCO in (Mol)
- Line 6 C_redCCO in (Mol)

The columns represent chromophore changes over time (Delimiters have to be space). The matlab script "compute_optical_changes.m" can be used to automatically generate the txt files.


\subsection sec_Qt 1) Data reconstruction using the C++ software

a) Open the Qt project (open project file "Process_WMC_reconstruction.pro")

b) Compile using Release mode

c) Use the software for data reconstruction

- If the box "Display reconstruction (1 wavelength)" is checked, only one wavelength will be reconstructed (choose the wavelength)
- If the box is unchecked, several wavelengths will be reconstructed (choose the wavelengths)
- Choose the binning, tick the box "Lens and sensor" if you want to model optics. Otherwise, data will be reconstructed at the surface of the tissue volume.
- Load the optical changes files
- Load the directory that contains the simulation results (.zip files)

Results will be written in txt files in a folder "results". For each wavelength, two files will be created (mean path and diffuse reflectance).

d) Use the python script "create_Hypercubes_from_txt.py" to compute the Hypercubes and save it in .npz file


 


 






