# -*- coding: utf-8 -*-
"""
Created on Thu Oct 24 15:42:19 2024

@author: angel
"""

import numpy as np

def closest_lambda(arr, wavelength):
    idx = np.abs(arr - wavelength).argmin()
    return arr[idx]

def get_mua_values(lambda_vals, C_Hb, C_HbO2, W, F, C_oxCCO, C_redCCO):
    """
    Calculate the absorption coefficient of the tissue [mm^-1].

    Parameters:
    lambda_vals : array-like
        Wavelength of light [nm]
    C_Hb : float
        Concentration of Hb [mol.L-1]
    C_HbO2 : float
        Concentration of HbO2 [mol.L-1]
    W : float
        Water content in the tissue
    F : float
        Fat content in the tissue
    C_oxCCO : float
        Concentration of oxidized cytochrome c-oxidase (oxCCO) in the tissue [mol.L-1]
    C_redCCO : float
        Concentration of reduced cytochrome c-oxidase (redCCO) in the tissue [mol.L-1]

    Returns:
    mu_a : array-like
        Absorption coefficient of the tissue [mm^-1]
    """
    
    # Read the extinction coefficients of water from external file
    w = np.loadtxt('../../spectra/lambda.txt')
    idx_w = np.isin(w, lambda_vals)
    
    mua_H2O = np.loadtxt('../../spectra/mua_H2O.txt')[idx_w]
    
    # Read the absorption coefficients of fat from external file
    mua_fat = np.loadtxt('../../spectra/mua_Fat.txt')[idx_w]
    
    # Get extinction coefficients (in cm^-1.mol^-1.L)
    eps_hb = np.loadtxt('../../spectra/eps_Hb.txt')[idx_w]
    eps_hbO2 = np.loadtxt('../../spectra/eps_HbO2.txt')[idx_w]
    eps_oxCCO = np.loadtxt('../../spectra/eps_oxCCO.txt')[idx_w]
    eps_redCCO = np.loadtxt('../../spectra/eps_redCCO.txt')[idx_w]
    
    # Calculate the absorption coefficient [cm^-1] of the tissue for the given wavelength
    mu_a = (W * mua_H2O +
            F * mua_fat +
            np.log(10) * C_Hb * eps_hb +
            np.log(10) * C_HbO2 * eps_hbO2 +
            np.log(10) * C_oxCCO * eps_oxCCO +
            np.log(10) * C_redCCO * eps_redCCO)
    
    mu_a = 0.1 * mu_a  # Convert into mm^-1
    
    return mu_a

# def find_closest(arr, val):
#     idx = np.abs(arr - val).argmin()
#     return arr[idx]

# Above function is backup in case isin doesn't work. Uses less memory but is slightly slower.

# Example usage
# lambda_vals = np.array([500])  # Example wavelength array
# C_Hb = 0.01
# C_HbO2 = 0.01
# W = 0.8
# F = 0.1
# C_oxCCO = 0.001
# C_redCCO = 0.001
# mu_a = get_mua_values(lambda_vals, C_Hb, C_HbO2, W, F, C_oxCCO, C_redCCO)
# print(mu_a)
