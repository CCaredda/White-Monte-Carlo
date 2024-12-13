# -*- coding: utf-8 -*-
"""
Created on Thu Oct 24 15:26:39 2024

@author: angel
"""

import numpy as np
from get_epsilon import get_mua_values

def compute_optical_properties(Lambdas, White_MC):
    # Grey matter (GM)
    g_GM = 0.85  # Anisotropy coefficient
    n_GM = 1.36  # Refractive index
    musP = 40.8 * (Lambdas / 500) ** -3.089
    mus_GM = 0.1 * (musP / (1 - g_GM))  # Scattering coefficient in mm-1

    if White_MC:
        mua_GM = np.zeros_like(mus_GM)  # Absorption coefficient for White Monte Carlo
    else:
        mua_GM = get_mua_values(Lambdas, 22.1e-6, 65.1e-6, 0.7, 0.1, 5e-6, 1e-6)

    # Large Blood Vessels (LBV)
    g_LBV = 0.935  # Anisotropy coefficient
    n_LBV = 1.4  # Refractive index
    musP = 22 * (Lambdas / 500) ** -0.66
    mus_LBV = 0.1 * (musP / (1 - g_LBV))  # Scattering coefficient in mm-1

    if White_MC:
        mua_LBV = np.zeros_like(mus_LBV)  # Absorption coefficient for White Monte Carlo
    else:
        mua_LBV = get_mua_values(Lambdas, 125.1e-6, 2375.1e-6, 0, 0, 0, 0)

    # Capillaries (Cap)
    g_Cap = g_GM  # Anisotropy coefficient
    n_Cap = n_GM  # Refractive index
    mus_Cap = mus_GM  # Scattering coefficient

    if White_MC:
        mua_Cap = np.zeros_like(mus_Cap)  # Absorption coefficient for White Monte Carlo
    else:
        mua_Cap = mua_GM

    # Activated Grey Matter (act_GM)
    g_act_GM = g_GM  # Anisotropy coefficient
    n_act_GM = n_GM  # Refractive index
    mus_act_GM = mus_GM  # Scattering coefficient

    if White_MC:
        mua_act_GM = np.zeros_like(mus_act_GM)  # Absorption coefficient for White Monte Carlo
    else:
        mua_act_GM = mua_GM

    # Activated Large Blood Vessels (act_LBV)
    g_act_LBV = g_LBV  # Anisotropy coefficient
    n_act_LBV = n_LBV  # Refractive index
    mus_act_LBV = mus_LBV  # Scattering coefficient

    if White_MC:
        mua_act_LBV = np.zeros_like(mus_act_LBV)  # Absorption coefficient for White Monte Carlo
    else:
        mua_act_LBV = mua_LBV

    # Activated Capillaries (act_Cap)
    g_act_Cap = g_Cap  # Anisotropy coefficient
    n_act_Cap = n_Cap  # Refractive index
    mus_act_Cap = mus_Cap  # Scattering coefficient

    if White_MC:
        mua_act_Cap = np.zeros_like(mus_act_Cap)  # Absorption coefficient for White Monte Carlo
    else:
        mua_act_Cap = mua_Cap
        
    optical_prop = np.zeros((len(Lambdas), 7, 4))
    for l in range(len(Lambdas)):
        optical_prop[l, 0, :] = [0, 0, 1, 1]
        optical_prop[l, 1, :] = [mua_GM[l], mus_GM[l], g_GM, n_GM]
        optical_prop[l, 2, :] = [mua_LBV[l], mus_LBV[l], g_LBV, n_LBV]
        optical_prop[l, 3, :] = [mua_Cap[l], mus_Cap[l], g_Cap, n_Cap]
        optical_prop[l, 4, :] = [mua_act_GM[l], mus_act_GM[l], g_act_GM, n_act_GM]
        optical_prop[l, 5, :] = [mua_act_LBV[l], mus_act_LBV[l], g_act_LBV, n_act_LBV]
        optical_prop[l, 6, :] = [mua_act_Cap[l], mus_act_Cap[l], g_act_Cap, n_act_Cap]

    # return {
    #     'GM': (g_GM, n_GM, mus_GM, mua_GM),
    #     'LBV': (g_LBV, n_LBV, mus_LBV, mua_LBV),
    #     'Cap': (g_Cap, n_Cap, mus_Cap, mua_Cap),
    #     'act_GM': (g_act_GM, n_act_GM, mus_act_GM, mua_act_GM),
    #     'act_LBV': (g_act_LBV, n_act_LBV, mus_act_LBV, mua_act_LBV),
    #     'act_Cap': (g_act_Cap, n_act_Cap, mus_act_Cap, mua_act_Cap)
    # }
    return optical_prop



# Example usage
Lambdas = np.array([500, 600])  # Example wavelength array
White_MC = False  # Example flag for White Monte Carlo
optical_properties = compute_optical_properties(Lambdas, White_MC)
print(optical_properties)
