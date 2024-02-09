#!/bin/sh


# SLURM options:

#SBATCH --job-name=sensitivity_matrix
#SBATCH --output=%j.log
#SBATCH --licenses=sps
#SBATCH -n 1
#SBATCH --licenses=matlab
#SBATCH --mem=15000
#SBATCH --time=0-06:00:00


#SBATCH --mail-user=charly.caredda@creatis.insa-lyon.fr   # Where to send mail
#SBATCH --mail-type=ALL          # Mail events (NONE, BEGIN, END, FAIL, ALL)

# Commands to be submitted:
if ! echo ${LD_LIBRARY_PATH} | /bin/grep -q /opt/cuda-11.3/lib64 ; then 
	LD_LIBRARY_PATH=/opt/cuda-11.3/lib64:${LD_LIBRARY_PATH} 
 fi

cd /sps/creatis/ccaredda/simulation/CREATIS-UCL-White-Monte-Carlo-Framework/run_simulations

module load Programming_Languages/matlab/R2022b
matlab -nojvm -nodisplay < process_sensitivity_matrix.m
