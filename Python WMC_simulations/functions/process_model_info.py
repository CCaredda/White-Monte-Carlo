# -*- coding: utf-8 -*-
"""
Created on Thu Oct 24 15:17:58 2024

@author: angel
"""

# import pmcx
import numpy as np

def process_model_info(nb_photons, nb_repeat, in_img_path, division_factor, model_rect_blood_vessel, inverse_volume_for_display):
    cfg = {}
    
    # Number of photons
    cfg['nphoton'] = nb_photons
    
    # Repeat the simulation x times
    cfg['respin'] = nb_repeat
    
    # Maximum number of photons that can be detected
    cfg['maxdetphoton'] = nb_photons  # SHouldn't it be the same as nb_photons?
    
    # GPU processing
    cfg['gpuid'] = 1
    
    # Save diffuse reflectance
    cfg['issaveref'] = 0
    
    # Seed for the random number generator
    # cfg['seed'] = 1648335518
    
    # Acquisition time
    cfg['tstart'] = 0  # Starting time of the simulation (in seconds)
    cfg['tend'] = 5e-9  # Ending time of the simulation (in seconds)
    cfg['tstep'] = 5e-9  # Time-gate width of the simulation (in seconds)
    
    # Calculate specular reflection if source is outside
    cfg['isspecular'] = 1
    cfg['autopilot'] = 1
    
    if in_img_path == "Simple shape" or not in_img_path:
        print('Compute simple shape')
        
        # Voxel size in mm
        cfg['unitinmm'] = 1
        resolution_xyz = 1
        
        # Create volume
        radius = 4
        cfg['vol'] = np.ones((32, 32, 30))  # grey matter
        cfg['vol'][16-radius:16+radius, 16-radius:16+radius, 0:radius] = 4  # activated grey matter
    
    # else:
    #     print('Get segmentation')
        
    #     # Load image and segmentation
    #     # img, resolution_xyz = Load_img_segmentation(in_img_path, division_factor)
        
    #     # Voxel size in mm
    #     cfg['unitinmm'] = resolution_xyz  # Units in mm
        
    #     print('Create volume')
    #     # Create volume
    #     # 1: Grey matter
    #     # 2: Large blood vessel
    #     # 3: Capillaries
    #     # 4: Activated grey matter
    #     # 5: Activated large vessel
    #     # 6: Activated capillaries
    #     # cfg['vol'] = create_volume(img, resolution_xyz, cfg['issaveref'], model_rect_blood_vessel)
        
    #     if inverse_volume_for_display:
    #         cfg['vol'] = np.flip(cfg['vol'], axis=2)
    
    if cfg['issaveref'] == 0:
        cfg['bc']='ccrccr001000';
    # ccrccc: Cyclic BC except for the top and bottom face (Fresnel reflection)
    # 001000: Only capture photons from face z=z_min

    # Detector output
        cfg['savedetflag'] = 'spxv';
        
    print("Creating light source")

    cfg['srctype']='planar'
    cfg['srcpos']=[0, 0, 0]
    cfg['srcparam1']=[np.size(cfg['vol'],1), 0, 0, 0]
    cfg['srcparam2']=[0, np.size( cfg['vol'],2), 0, 0]
    cfg['issrcfrom0']=1
    cfg['srcdir']=[0, 0, 1]
    
    return cfg
    

# Example usage
# cfg = process_model_info(1e5, 10, 'Simple shape', 2, [0, 0, 0, 0], 1)
# print(cfg)
