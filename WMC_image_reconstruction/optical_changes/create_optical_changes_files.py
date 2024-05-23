
import numpy as np


class component_mua:
    def __init__(self, F = np.array([]),
                    W = np.array([]),
                    HbO2 = np.array([]),
                    Hb = np.array([]),
                    oxCCO = np.array([]),
                    redCCO = np.array([]),
                    oxCytb = np.array([]),
                    redCytb = np.array([]),
                    oxCytc = np.array([]),
                    redCytc = np.array([]),):
        self.F = F
        self.W = W
        self.HbO2 = HbO2
        self.Hb = Hb
        self.oxCCO = oxCCO
        self.redCCO = redCCO
        self.oxCytb = oxCytb
        self.redCytb = redCytb
        self.oxCytc = oxCytc
        self.redCytc = redCytc


def add_Element(mua,F,W,HbO2,Hb,oxCCO,redCCO,oxCytb,redCytb,oxCytc,redCytc):
    mua.F = np.append(mua.F,F)
    mua.W = np.append(mua.W,W)
    mua.HbO2 = np.append(mua.HbO2,HbO2)
    mua.Hb = np.append(mua.Hb,Hb)
    mua.oxCCO = np.append(mua.oxCCO,oxCCO)
    mua.redCCO = np.append(mua.redCCO,redCCO)
    mua.oxCytb = np.append(mua.oxCytb,oxCytb)
    mua.redCytb = np.append(mua.redCytb,redCytb)
    mua.oxCytc = np.append(mua.oxCytc,oxCytc)
    mua.redCytc = np.append(mua.redCytc,redCytc)
    return mua


def add_Perturbation_compared_to_ref(mua,ref,
                                     HbO2=0,Hb=0,
                                     oxCCO=0,redCCO=0,
                                     oxCytb=0,redCytb=0,
                                     oxCytc=0,redCytc=0,
                                     F=0,W=0):
    #Check size of the input
    max_size = np.max(np.array([np.size(HbO2),np.size(Hb),np.size(oxCCO),np.size(redCCO),np.size(oxCytb), np.size(redCytb),np.size(oxCytc),np.size(redCytc),np.size(F),np.size(W)]))

    #replace by a vector of 0

    if np.size(HbO2) == 1:
        HbO2 = np.array([HbO2])
        if HbO2 == 0:
            HbO2 = np.zeros((max_size,))

    if np.size(Hb) == 1:
        Hb = np.array([Hb])
        if Hb == 0:
            Hb = np.zeros((max_size,))

    if np.size(oxCCO) == 1:
        oxCCO = np.array([oxCCO])
        if oxCCO == 0:
            oxCCO = np.zeros((max_size,))


    if np.size(redCCO) == 1:
        redCCO = np.array([redCCO])
        if redCCO == 0:
            redCCO = np.zeros((max_size,))


    if np.size(oxCytb) == 1:
        oxCytb = np.array([oxCytb])
        if oxCytb == 0:
            oxCytb = np.zeros((max_size,))

    if np.size(redCytb) == 1:
        redCytb = np.array([redCytb])
        if redCytb == 0:
            redCytb = np.zeros((max_size,))

    if np.size(oxCytc) == 1:
        oxCytc = np.array([oxCytc])
        if oxCytc == 0:
            oxCytc = np.zeros((max_size,))


    if np.size(redCytc) == 1:
        redCytc = np.array([redCytc])
        if redCytc == 0:
            redCytc = np.zeros((max_size,))


    if np.size(F) == 1:
        F = np.array([F])
        if F == 0:
            F = np.zeros((max_size,))


    if np.size(W) == 1:
        W = np.array([W])
        if W == 0:
            W = np.zeros((max_size,))

    for i in range(max_size):
        mua =  add_Element(mua,
                            mua.F[ref] + F[i],
                            mua.W[ref] + W[i],
                            mua.HbO2[ref] + HbO2[i],
                            mua.Hb[ref] + Hb[i],
                            mua.oxCCO[ref] + oxCCO[i],
                            mua.redCCO[ref] + redCCO[i],
                            mua.oxCytb[ref] + oxCytb[i],
                            mua.redCytb[ref] + redCytb[i],
                            mua.oxCytc[ref] + oxCytc[i],
                            mua.redCytc[ref] + redCytc[i])
    return mua



def copy_mua(mua):
    new_mua = component_mua()
    new_mua.F = mua.F
    new_mua.W = mua.W
    new_mua.HbO2 = mua.HbO2
    new_mua.Hb = mua.Hb
    new_mua.oxCCO = mua.oxCCO
    new_mua.redCCO = mua.redCCO
    new_mua.oxCytb = mua.oxCytb
    new_mua.redCytb = mua.redCytb
    new_mua.oxCytc = mua.oxCytc
    new_mua.redCytc = mua.redCytc

    return new_mua





def save_txt(path,mua):

    output = np.zeros((10,mua.W.shape[0]))
    # 1 Water content in % (0-1)
    output[0,:] = mua.W

    # 2 Fat content in µ (0-1)
    output[1,:] = mua.F

    # 3 C_HbO2 in (Mol)
    output[2,:] = mua.HbO2

    # 4 C_Hb in (Mol)
    output[3,:] = mua.Hb

    # 5 C_oxCCO in (Mol)
    output[4,:] = mua.oxCCO

    # 6 C_redCCO in (Mol)
    output[5,:] = mua.redCCO

    # 7 C_oxCytb in (Mol)
    output[6,:] = mua.oxCytb

    # 8 C_redCytb in (Mol)
    output[7,:] = mua.redCytb

    # 9 C_oxCytc in (Mol)
    output[8,:] = mua.oxCytc

    # 10 C_redCytc in (Mol)
    output[9,:] = mua.redCytc

    np.savetxt(path,output)



## Set nominal values

#Grey matter
mua_GM = component_mua()

mua_GM = add_Element(mua_GM,F=0.1, W=0.76, HbO2=6.5325e-05, Hb=2.1775e-05, oxCCO=6.4*1e-6, redCCO=1.6*1e-6, oxCytb=2.37*1e-6, redCytb=0.89*1e-6, oxCytc=1.36*1e-6, redCytc=0.68*1e-6 )

mua_GM_activated = copy_mua(mua_GM)

# Large blood vessel
HbT_vessels = 2324*1e-6
# SatO2_LBV = 0.98 #arteries
SatO2_LBV = 0.60 #veins


mua_LBV = component_mua()
mua_LBV = add_Element(mua_LBV,F=0.01, W=0.55, HbO2=HbT_vessels*SatO2_LBV, Hb=HbT_vessels*(1-SatO2_LBV), oxCCO=0, redCCO=0, oxCytb=0, redCytb=0, oxCytc=0, redCytc=0 )

mua_LBV_activated = copy_mua(mua_LBV)

# Capillaries
HbT_vessels = 2324*1e-6
# SatO2_small_vessels = 0.74
# SatO2_small_vessels = 0.98 # same as arteries
SatO2_small_vessels = 0.60 # same as veins


mua_cap = component_mua()
mua_cap = add_Element(mua_cap,F=0.01, W=0.55, HbO2=HbT_vessels*SatO2_small_vessels, Hb=HbT_vessels*(1-SatO2_small_vessels), oxCCO=0, redCCO=0, oxCytb=0, redCytb=0, oxCytc=0, redCytc=0 )

mua_cap_activated = copy_mua(mua_cap)




## Add perturbation

# 0: Nominal values for all compartments
# 1: functional activity in GM only (HbO2 +5µM, Hb -3.75µM, Cyt +0.5µM ox, -0.5µM red)
# 2: same functional activity in GM and blood vessel
# 3: functional activity in GM and larger change in blood vessel (+25µM HbO2, -2.5µM Hb, see Wide-field optical mapping of neural activity and brain haemodynamics: considerations and novel approaches)
# 4: functional activity in blood vessel only (+25µM HbO2, -2.5µM Hb)


#Perturbation in activated GM
Delta_C_HbO2 = np.array([5e-6,5e-6,5e-6,0])
Delta_C_Hb = np.array([-3.75e-6,-3.75e-6,-3.75e-6,0])
Delta_Cyt = np.array([0.5e-6,0.5e-6,0.5e-6,0])


#Mirrored changes in ox and red cytochromes
mua_GM_activated = add_Perturbation_compared_to_ref(mua_GM_activated, 0, HbO2=Delta_C_HbO2, Hb=Delta_C_Hb, oxCCO=Delta_Cyt, redCCO=-Delta_Cyt, oxCytb=Delta_Cyt, redCytb=-Delta_Cyt, oxCytc=Delta_Cyt, redCytc=-Delta_Cyt)

mua_GM = add_Perturbation_compared_to_ref(mua_GM,0,HbO2=np.zeros(Delta_C_HbO2.shape))


#Perturabation in vessel (large and capillaries)
Delta_C_HbO2 = np.array([0,5e-6,25e-6,25e-6])
Delta_C_Hb = np.array([0,-3.75e-6,-2.5e-6,-2.5e-6])

mua_LBV_activated = add_Perturbation_compared_to_ref(mua_LBV_activated,0, HbO2=Delta_C_HbO2, Hb=Delta_C_Hb)
mua_LBV = add_Perturbation_compared_to_ref(mua_LBV,0, HbO2=Delta_C_HbO2, Hb=Delta_C_Hb)

mua_cap = add_Perturbation_compared_to_ref(mua_cap,0, HbO2=Delta_C_HbO2, Hb=Delta_C_Hb)
mua_cap_activated = add_Perturbation_compared_to_ref(mua_cap_activated,0, HbO2=Delta_C_HbO2, Hb=Delta_C_Hb)


## Write txt
path = "/home/caredda/temp/"
save_txt(path+"grey_matter.txt",mua_GM)
save_txt(path+"activated_grey_matter.txt",mua_GM_activated)

save_txt(path+"large_blood_vessels.txt",mua_LBV)
save_txt(path+"activated_large_blood_vessels.txt",mua_LBV_activated)

save_txt(path+"capillaries.txt",mua_cap)
save_txt(path+"activated_capillaries.txt",mua_cap_activated)



