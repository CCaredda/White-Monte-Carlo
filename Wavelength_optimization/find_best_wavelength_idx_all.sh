#!/bin/sh


# SLURM options:

#SBATCH --job-name=all
#SBATCH --output=%j.log
#SBATCH --licenses=sps
#SBATCH --partition=hpc #for multi-core
#SBATCH -n 10
#SBATCH --mem=15000
#SBATCH --time=0-15:00:00


#SBATCH --mail-user=charly.caredda@creatis.insa-lyon.fr   # Where to send mail
#SBATCH --mail-type=ALL          # Mail events (NONE, BEGIN, END, FAIL, ALL)



source /pbs/home/c/ccaredda/private/python_env/bin/activate
module load python

python find_best_wavelength_idx_all.py
