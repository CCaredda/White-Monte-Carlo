\mainpage
 
 \section intro_sec Introduction
 
This software allows the propagation of light within brain tissue and the modeling of the acquisition of retro-diffused light.

This software is a digital phantom that can be used as an instrument simulator (DIS). The main objective of this simulator is to develop a computational tool able to simulate brain tissue optical parameters and incorporate realistic instrument specifications, in order to (i) assist the development of the hyperspectral imaging prototypes, and (ii) generate synthetic data to help the development of the machine learning algorithm.
 

This software has been developed for the European project Hyperprobe which aims at transforming neuronavigation during glioma resection using novel
hyperspectral imaging technology: 
- https://hyperprobe.eu/
- https://cordis.europa.eu/project/id/101071040

Author: Charly Caredda
Contact: caredda.c@gmail.com


 
 \section install_sec Installation
This program has be tested under Fedora 38 and Ubuntu. Problem may occur under other operating system.
This program is coded in Python and Matlab. Matlab and Python need to be installed.

The matlab software MCXLab need to be downloaded: https://mcx.space/wiki/?Get
Please download the latest version.

For Python, several libraries need to be installed: 

- sudo dnf install python3-pip python3-pyqt5
- pip install opencv-python numpy matplotlib



\section sec_guide User guide


The software is separated in two parts:
- Image segmentation
- White Monte Carlo simulations


\subsection img_seg 1) Image segmentation

To simulate the light propagation within the brain tissue, a model of brain tissue needs to be created.
A real RGB image of brain exposed cortex is taken as the input. This image is then segmented into six classes using the python script: "manual_segmentation.py":
- Non activated grey matter
- Non activated large blood vessels
- Non activated capillaries
- Activated grey matter
- Activated large blood vessels
- Activated capillaries

The results of this segmentation step are written in the folder "images/Patientx".
A folder Patientx needs to created prior to the execution of the python script. It must contains:
- the input image "initial_img.png"
- the mask of the surgical window "mask.png"
- if you want to model activated areas, a mask need to be created. For this copy the input image "initial_img.png" into "mask_activity.png" and color the activated area in black.

Some variables in the script need to be changed (data path and other variables)

\subsection sec_simu 2) Simulations

In the folder "run_simulations" several scripts can be used to process white Monte Carlo simulations:

a) "run_simulations.m"
This script is used to compute White Monte Carlo simulations.
This script can be executed on a cluster. For this purpose, the bash script "run_simulations.sh" need to be used.

The input that need to be indicated in the matlab script are:

- The resolution of the volume in mm (parameter model_resolution_in_mm). If 0, the resolution is the same as the input image.
- Wavelength to be simulated, array or scalar (parameter Lambdas)
- Parameter run_in_cluster, set 0 to process locally and set 1 to use a cluster
- Number of Monte Carlo repetitions. Used to increase the SNR (parameter nb_repeat)
- Number of packets of photons launched on the tissue (parameter nb_photons)
- Path for outputs (parameter out_path)
- Input image path that contain images creates at step 1) (parameter in_img_path)

The outputs are:
- zip file for each simulated wavelength. A zip file contain 4 txt files (partial path length, position of exiting photons, angle of exiting photons, tissue optical properties at the considered wavelength).
- mat and txt file that contain simulation information

b) "process_Hypercubes.m"

This script can be used to reconstruct hypercubes (diffuse reflectance and mean path length images) after the execution of script a) "run_simulations.m"
!!!! Caution !!!! This script can only be executed when using a small number of photons. Otherwise please use the C++ software.

c) "run_simu_and_process_Hypercubes.m"

This script can be used to simulate light propagation in tissue and reconstruct hypercubes (diffuse reflectance and mean path length images).
!!!! Caution !!!! This script can only be executed when using a small number of photons. Otherwise please use the C++ software.
 






