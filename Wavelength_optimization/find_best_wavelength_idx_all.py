import numpy as np
import matplotlib.pyplot as plt
from scipy import interpolate
from scipy.optimize import OptimizeResult, minimize, Bounds, brute, NonlinearConstraint
import scipy.io
import time


# Change this
main_path = "/home/caredda/DVP/simulation/CREATIS-UCL-White-Monte-Carlo-Framework/Wavelength_optimization/"

class epsilon:
    def __init__(self, eps_Hb = np.array([]),
                    eps_HbO2 = np.array([]),
                    eps_oxCCO = np.array([]),
                    eps_redCCO = np.array([]),
                    eps_oxCytc = np.array([]),
                    eps_redCytc = np.array([]),
                    eps_oxCytb = np.array([]),
                    eps_redCytb = np.array([]),
                    wavelength = np.array([])):
        self.eps_Hb = eps_Hb
        self.eps_HbO2 = eps_HbO2

        self.eps_oxCCO = eps_oxCCO
        self.eps_redCCO = eps_redCCO

        self.eps_oxCytc = eps_oxCytc
        self.eps_redCytc = eps_redCytc

        self.eps_oxCytb = eps_oxCytb
        self.eps_redCytb = eps_redCytb

        self.wavelength = wavelength



lw = 3

def invertMatrix(in_mat):

    # E_RGB_inv_A = inv(E_RGB_detectA'*E_RGB_detectA)*E_RGB_detectA' ;
    # out = np.dot(np.linalg.inv(np.dot(np.transpose(in_mat),in_mat)),np.transpose(in_mat))
    out = np.dot(np.linalg.pinv(np.dot(np.transpose(in_mat),in_mat)),np.transpose(in_mat))

    # tr = np.transpose(in_mat)
    # out = cv.invert(np.dot(tr,in_mat))
    # out = np.dot(out,np.transpose(in_mat))
    return out

def get_MBLL_Matrix(eps_list,mp):
    #MBLL method
    E = np.zeros((eps_list[0].shape[0],len(eps_list)))
    for i in range(len(eps_list)):
        E[:,i] = np.multiply(eps_list[i],mp)

    E_inv = invertMatrix(E)
    return E_inv



def get_epsilon(w):

    epsilon_coefficient = epsilon()
    epsilon_coefficient.wavelength = w

    # unit in cm-1/Mol
    path = main_path+"../spectra/"
    wavelength = np.loadtxt(path+"lambda.txt")
    eps_Hb = np.loadtxt(path+"eps_Hb.txt")
    eps_HbO2 = np.loadtxt(path+"eps_HbO2.txt")

    eps_oxCCO = np.loadtxt(path+"eps_oxCCO.txt")
    eps_redCCO = np.loadtxt(path+"eps_redCCO.txt")

    eps_oxCytb = np.loadtxt(path+"eps_oxCytb.txt")
    eps_redCytb = np.loadtxt(path+"eps_redCytb.txt")

    eps_oxCytc = np.loadtxt(path+"eps_oxCytc.txt")
    eps_redCytc = np.loadtxt(path+"eps_redCytc.txt")

    f = scipy.interpolate.interp1d(wavelength,eps_Hb, kind='cubic')
    epsilon_coefficient.eps_Hb = f(w)
    f = scipy.interpolate.interp1d(wavelength,eps_HbO2, kind='cubic')
    epsilon_coefficient.eps_HbO2 = f(w)

    f = scipy.interpolate.interp1d(wavelength, eps_oxCCO, kind='cubic')
    epsilon_coefficient.eps_oxCCO = f(w)
    f = scipy.interpolate.interp1d(wavelength, eps_redCCO, kind='cubic')
    epsilon_coefficient.eps_redCCO = f(w)

    f = scipy.interpolate.interp1d(wavelength, eps_oxCytb, kind='cubic')
    epsilon_coefficient.eps_oxCytb = f(w)
    f = scipy.interpolate.interp1d(wavelength, eps_redCytb, kind='cubic')
    epsilon_coefficient.eps_redCytb = f(w)


    f = scipy.interpolate.interp1d(wavelength, eps_oxCytc, kind='cubic')
    epsilon_coefficient.eps_oxCytc = f(w)
    f = scipy.interpolate.interp1d(wavelength, eps_redCytc, kind='cubic')
    epsilon_coefficient.eps_redCytc = f(w)


    return epsilon_coefficient





def get_Delta_C(id_w,epsilon_coeff,I,Mean_path,mode):

    #Get extinction  coeff
    # Calculate diff extinction spectra of cytochromes (cytochromes does not change over time)
    eps_list = []
    eps_list.append(epsilon_coeff.eps_HbO2[id_w])
    eps_list.append(epsilon_coeff.eps_Hb[id_w])

    if mode == "oxCCO" or mode == "all":
        eps_list.append(epsilon_coeff.eps_oxCCO[id_w] - epsilon_coeff.eps_redCCO[id_w])
    #if mode == "oxCytb" or mode == "all":
    #    eps_list.append(epsilon_coeff.eps_oxCytb[id_w] - epsilon_coeff.eps_redCytb[id_w])
    #if mode == "oxCytc" or mode == "all":
    #    eps_list.append(epsilon_coeff.eps_oxCytc[id_w] - epsilon_coeff.eps_redCytc[id_w])


    nb_chrom = len(eps_list)
    Delta_C = np.zeros((I.shape[0],nb_chrom,I.shape[1]))

    for i in range(Mean_path.shape[0]):

        Delta_A = np.log10(np.divide(I[0,i,id_w],I[:,i,id_w]))

        E_inv = get_MBLL_Matrix(eps_list,Mean_path[i,id_w])
        dC = Delta_A @ E_inv.T
        Delta_C[:,:,i] = 1e6*dC

    return Delta_C


def minimize_Delta_C(param,SNR,
                     wavelength,
                     mode,
                     epsilon_coeff,
                     I,
                     Mean_path,
                     GT,
                     nb_Chrom,
                     model):
    #param : wavelengths
    #mode : identidy the chromophore to study
    #wavelength: wavelength vector
    #epsilon_coeff: class that contains extinction spectra of chromophores
    #I: Intensity vector
    #Mean_path: mean path length map
    #GT: Ground truth of Delta C
    #nb_Chrom: indexes of the chromophore to minimize

    #Convert param in integer
    _w = np.asarray(param).astype(int)


    id_w = np.zeros(_w.shape[0],dtype=int)
    for i in range(_w.shape[0]):
        id_w[i] = np.where(_w[i] == wavelength)[0].item()



    #noise params
    #sigma_noise = np.divide(np.mean(I[0,:,:],axis=0),SNR)
    #sigma_noise = np.tile(sigma_noise,(I.shape[1],1))
    sigma_noise = np.divide(np.mean(I[0,:,:]),SNR)* np.ones(I[0,:,:].shape)

    nb_noise_itt = 100

    cost = 0

    for i in range(nb_noise_itt):
        # Calculate noisy intensities
        I_noise = I + np.random.normal(0,sigma_noise,size=I.shape)

        #Calculate Delta C with id_w
        Delta_C = get_Delta_C(id_w,epsilon_coeff,I_noise,Mean_path,mode)

        #least square error

        for j in nb_Chrom:
            cost += np.sum((Delta_C[model,j,:]-GT[model,j,:])**2)/nb_noise_itt

    return cost



## Load simulated data

plt.close('all')

path = main_path+"data/"


#In the following data:
#x is the the width of the modelled tissue (only the cross-section of the simulation is contained in the structure data.npz
#T is the number of chromophore changes, nominal (no changes), Activation
#C is the number of chromophore modelled in the simulations: 5 chromophores (HbO2, Hb, oxCCO, oxCytb, oxCytc)

# Load simulation
data = np.load(path+"data.npz")

#Data resolution (pixel size in mm)
reso = data['reso']

#Diffuse reflectance (mm-2) shape (T,x,wavelength)
I = data['I']

#Mean path length (cm) shape (x,wavelength)
Mean_path = data['Mean_path']

#Wavelength (nm)
wavelength = data['wavelength']

#Ground truth for the changes in concentration. Shape (T,C,x)
theo_Delta_C = data["theo_Delta_C"] #in µM



## Find best wavelength idx for Delta C (differential evolution)

# Additional constraints enforcing x[0] < x[1] < x[2] < x[3]
def constraint_2w(x):
    return [x[1] - x[0]]

def constraint_4w(x):
    return [x[1] - x[0], x[2] - x[1], x[3] - x[2]]

def constraint_6w(x):
    return [x[1] - x[0], x[2] - x[1], x[3] - x[2], x[4] - x[3], x[5] - x[4]]

def constraint_8w(x):
    return [x[1] - x[0], x[2] - x[1], x[3] - x[2], x[4] - x[3], x[5] - x[4], x[6] - x[5], x[7] - x[6]]

#Mode
# mode_array = np.array(["HbO2","Hb","Hemodynamic","oxCCO","oxCytb","oxCytc","all"])
mode_array = np.array(["all"])

#Zone controlled
# array_zone = np.array(["Activated grey matter","Large blood vessel","all"])
array_zone = np.array(["Activated grey matter"])


model = 1

#SNR
SNR_vec = np.array([1e3])


#Define idx of different tissues
idx_zone_array = []
idx_zone_array.append(np.where(theo_Delta_C[model,0,:]==5)[0])


#Get extinction coefficients
epsilon_coeff = get_epsilon(wavelength)


wmin = 520
wmax = wavelength[-1]


delta_min_w = 10

for SNR in SNR_vec:

    #nb of wavelength
    for nb_wavelengths in np.array([4,6,8]):


        if nb_wavelengths == 2:
            nonlinear_constraint = NonlinearConstraint(constraint_2w, [delta_min_w], [np.inf])

        if nb_wavelengths == 4:
            nonlinear_constraint = NonlinearConstraint(constraint_4w, [delta_min_w,delta_min_w,delta_min_w], [np.inf,np.inf,np.inf])

        if nb_wavelengths == 6:
            nonlinear_constraint = NonlinearConstraint(constraint_6w, [delta_min_w,delta_min_w,delta_min_w,delta_min_w,delta_min_w], [np.inf,np.inf,np.inf,np.inf,np.inf])

        if nb_wavelengths == 8:
            nonlinear_constraint = NonlinearConstraint(constraint_8w, [delta_min_w,delta_min_w,delta_min_w,delta_min_w,delta_min_w,delta_min_w,delta_min_w], [np.inf,np.inf,np.inf,np.inf,np.inf,np.inf,np.inf])




        for mode in mode_array:

            for id_zone,zone in enumerate(array_zone):

                #Define id chromophore
                if mode == "HbO2":
                    id_Chrom = np.array([0])

                if mode == "Hb":
                    id_Chrom = np.array([1])

                if mode == "Hemodynamic":
                    id_Chrom = np.array([0,1])

                if mode == "oxCCO":
                    id_Chrom = np.array([2])

                if mode == "oxCytb":
                    id_Chrom = np.array([2])

                if mode == "oxCytc":
                    id_Chrom = np.array([2])

                if mode == "all":
                    id_Chrom = np.array([0,1,2])




                #Define the range for the optimization
                bounds = []
                for i in range(nb_wavelengths):
                    bounds.append((wmin, wmax))


                # Args for Activated grey matter optimization
                args = (SNR,wavelength,
                        mode,
                        epsilon_coeff,
                        I[:,idx_zone_array[id_zone],:],
                        Mean_path[idx_zone_array[id_zone],:],
                        theo_Delta_C[:,:,idx_zone_array[id_zone]],
                        id_Chrom,model)




                #Differential evolution
                t = time.process_time()
                DE = scipy.optimize.differential_evolution(minimize_Delta_C,
                                                        bounds,
                                                        args=args,
                                                        constraints=[nonlinear_constraint],
                                                        #mutation = 1.9,
                                                        #strategy='best1bin',
                                                        #maxiter=1000000,
                                                        #popsize=10,
                                                        workers=-1,
                                                        updating='deferred')

                elapsed_time = time.process_time() - t
                print(elapsed_time,"s")


                #Get output
                optim_wavelengths = DE.x.astype(int)

                np.savez(main_path+"DE_Wavelengths_optim_"+mode+"_"+str(nb_wavelengths)+"_wavelengths_"+zone+"_"+str(SNR),
                optim_wavelengths = optim_wavelengths)
