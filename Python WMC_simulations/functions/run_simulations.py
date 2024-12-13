# -*- coding: utf-8 -*-
"""
Created on Mon Oct 28 12:18:08 2024

@author: angel
"""

import os
import numpy as np
import shutil
import pmcx
from process_model_info import process_model_info
from process_optical_properties import compute_optical_properties
from process_simulations import process_simulations
import matplotlib.pyplot as plt
# Divide the size of the pixel (increase the resolution)
division_factor = 1

# Model rectangle blood vessel
model_rect_blood_vessel = 0  # if 0, a pyramidal blood vessel is computed

# Inverse volume for display
inverse_volume_for_display = 0

Lambdas = np.arange(900, 910, 10)
run_in_cluster = 0
nb_repeat = 1  # Number of repetitions used in MCX
simu_repeat = 1  # Larger number of repeats (avoid large txt files)
nb_photons = 1e6

out_path = 'output/'
in_img_path = '../images/Synthetic_img/'

# Add paths
if run_in_cluster == 1:
    os.sys.path.append('/pbs/home/c/ccaredda/private/mcx/utils')
    os.sys.path.append('/pbs/home/c/ccaredda/private/mcxlab')
else:
    pass  # Add local paths if needed

# Create output directory
if not os.path.isdir(out_path):
    os.makedirs(out_path)

# Process model info
info_model = process_model_info(nb_photons, nb_repeat, "Simple shape", division_factor, model_rect_blood_vessel, inverse_volume_for_display)

# Save model info
np.save(os.path.join(out_path, 'cst.npy'), info_model)
# with open(os.path.join(out_path, 'cst.txt'), 'w') as f:
#     f.write(f'nb_photons {nb_photons}\n')
#     f.write(f'repetitions {nb_repeat * simu_repeat}\n')
#     f.write(f'unitinmm {info_model["unitinmm"]}\n')
#     f.write(f'vol_rows {info_model.cfg.vol.shape[0]}\n')
#     f.write(f'vol_cols {info_model.cfg.vol.shape[1]}\n')
#     f.write(f'division_factor {division_factor}\n')
#     f.write(f'model_rect_blood_vessel {model_rect_blood_vessel}\n')

# Process optical properties
Optical_prop = compute_optical_properties(Lambdas, 0)

# Process simulations
for l in range(len(Lambdas)):
    print(f"Simulation lambda {Lambdas[l]}")
    
    for s in range(simu_repeat):
        output_det = process_simulations(Optical_prop[l, :, :], info_model)
        np.squeeze(output_det['flux'])
        
        plt.imshow(np.log10(output_det['flux'][30,:, :]))
        plt.colorbar()
        plt.show()


        # Save output
    #     print('Save results')
    #     if s == 1:
    #         np.savetxt(os.path.join(out_path, f'ppath_{Lambdas[l]}.txt'), output_det.ppath, delimiter=' ')
    #         np.savetxt(os.path.join(out_path, f'p_{Lambdas[l]}.txt'), output_det.p, delimiter=' ')
    #         np.savetxt(os.path.join(out_path, f'v_{Lambdas[l]}.txt'), output_det.v, delimiter=' ')
    #         np.savetxt(os.path.join(out_path, f'prop_{Lambdas[l]}.txt'), output_det.prop, delimiter=' ')
    #     else:
    #         with open(os.path.join(out_path, f'ppath_{Lambdas[l]}.txt'), 'ab') as f:
    #             np.savetxt(f, output_det.ppath, delimiter=' ')
    #         with open(os.path.join(out_path, f'p_{Lambdas[l]}.txt'), 'ab') as f:
    #             np.savetxt(f, output_det.p, delimiter=' ')
    #         with open(os.path.join(out_path, f'v_{Lambdas[l]}.txt'), 'ab') as f:
    #             np.savetxt(f, output_det.v, delimiter=' ')

    #     del output_det

    # # Zip files
    # print('Zip results')
    # shutil.make_archive(os.path.join(out_path, str(Lambdas[l])), 'zip', out_path, base_dir=None, verbose=0, dry_run=False, owner=None, group=None, logger=None)

    # # Remove txt files
    # print('Delete temp files')
    # os.remove(os.path.join(out_path, f'ppath_{Lambdas[l]}.txt'))
    # os.remove(os.path.join(out_path, f'p_{Lambdas[l]}.txt'))
    # os.remove(os.path.join(out_path, f'v_{Lambdas[l]}.txt'))
    # os.remove(os.path.join(out_path, f'prop_{Lambdas[l]}.txt'))
