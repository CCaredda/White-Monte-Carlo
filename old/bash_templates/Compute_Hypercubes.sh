#!/bin/sh


# SLURM options:

#SBATCH --job-name=Hypercubes
#SBATCH --output=Hypercubes%j.log
#SBATCH --licenses=sps
#SBATCH --ntasks=1
#SBATCH --licenses=matlab
#SBATCH --mem=15000
#SBATCH --time=0-02:00:00


#SBATCH --mail-user=charly.caredda@creatis.insa-lyon.fr
#SBATCH --mail-type=ALL


module load Programming_Languages/matlab/R2022b
matlab -nojvm -nodisplay < Compute_Hypercubes.m



