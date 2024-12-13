# -*- coding: utf-8 -*-
"""
Created on Mon Oct 28 12:06:17 2024

@author: angel
"""

import pmcx
import numpy as np

def process_simulations(optical_properties, cfg):
    """
    Create the common parameters for all simulations

    Parameters:
    optical_properties: numpy array of shape (7, 4) - 7 tissues, 4 properties [mua, mus, n, g]
    cfg: configuration dictionary

    Returns:
    output_det: Detector output
    """
    
    print('Start simulations')
    
    # Set optical properties [mua, mus, g, n]
    # 0: Air
    # 1: Grey matter
    # 2: Large blood vessel
    # 3: Capillaries
    # 4: Activated grey matter
    # 5: Activated large vessel
    # 6: Activated capillaries
    cfg['prop'] = optical_properties
    
    # Random seed to obtain different results when running multiple simulations for the same input parameters
    cfg['seed'] = np.random.randint(0, 100000)
    
    # Calculate the fluence and partial path lengths
    res = pmcx.mcxlab(cfg)
    res['detp'].keys()
    # output_det = res['detp']
    
    return res

# # Example usage
# cfg = {
#     'nphoton': 1000000,
#     'vol': np.ones([60, 60, 60], dtype='uint8'),
#     'tstart': 0,
#     'tend': 5e-9,
#     'tstep': 5e-9,
#     'srcpos': [30, 30, 0],
#     'srcdir': [0, 0, 1],
#     'prop': [[0, 0, 1, 1], [0.005, 1, 0.01, 1.37]]
# }
# optical_properties = np.array([
#     [0, 0, 1, 1],
#     [0.005, 1, 0.01, 1.37],
#     # Add other tissue properties here
# ])

# output_det = process_simulations(optical_properties, cfg)
