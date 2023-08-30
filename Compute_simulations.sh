#!/bin/sh


# SLURM options:

#SBATCH --job-name=main_MCXLab    # Job name
#SBATCH --output=main_MCXLab%j.log   # Standard output and error log
#SBATCH --licenses=sps
#SBATCH -n 1
#SBATCH --licenses=matlab
#SBATCH --gres=gpu:v100:1
#SBATCH --mem=9000                    # Memory in MB per default
#SBATCH --time=1-00:00:00             # Délai max = 7 jours


#SBATCH --mail-user=charly.caredda@creatis.insa-lyon.fr   # Where to send mail
#SBATCH --mail-type=ALL          # Mail events (NONE, BEGIN, END, FAIL, ALL)

# Commands to be submitted:
if ! echo ${LD_LIBRARY_PATH} | /bin/grep -q /opt/cuda-11.3/lib64 ; then 
	LD_LIBRARY_PATH=/opt/cuda-11.3/lib64:${LD_LIBRARY_PATH} 
 fi

cd /sps/creatis/ccaredda/simulation/CREATIS-UCL-White-Monte-Carlo-Framework

module load Programming_Languages/matlab/R2022b
matlab -nojvm -nodisplay -r 'Compute_simulations ; exit'



