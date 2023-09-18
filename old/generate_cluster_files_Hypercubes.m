% Generate files for cluster

clear

% Wavelength
Lambdas = 500:10:900;

% Create directory that contain processing files
if ~exist('cluster_processing', 'dir')
   mkdir('cluster_processing')
end

% out path
out_path = '''output/'';';
% Binning
binning = 1;







% Matlab file
code = sprintf('clear\naddpath(''../functions'');\naddpath(''../functions/Optical_coefficients'');');
code = strcat(code,sprintf(strcat('\nout_path = ',out_path)));
code = strcat(code,sprintf(strcat('\nbinning = ',num2str(binning),';')));


% Read sh file
f_in = fopen('bash_templates/Compute_Hypercubes.sh', 'r');
txt_sh=fread(f_in,'*char')';
fclose(f_in);

%Create script shell
f_script = fopen('cluster_processing/process_images.sh', 'w');
fprintf(f_script,'%s\n','#!/bin/bash');



for l=1:length(Lambdas)

    % Generate matlab code
    f_m = fopen(strcat('cluster_processing/proc_',num2str(Lambdas(l)),'.m'), 'w');
    code_temp = strcat(code,sprintf(strcat('\nLambdas = ',num2str(Lambdas(l)),';')));
    code_temp = strcat(code_temp,sprintf('\nprocess_Diffuse_Reflectance_Mean_path_Images(Lambdas,1,1,out_path,binning);'));
    fprintf(f_m,code_temp);


    %Modify sh file
    txt_out=strrep(txt_sh,'#SBATCH --job-name=Hypercubes',strcat('#SBATCH --job-name=',num2str(Lambdas(l))));
    txt_out=strrep(txt_out,'#SBATCH --output=Hypercubes%j.log',strcat('#SBATCH --output=',num2str(Lambdas(l)),'%j.log'));
    txt_out=strrep(txt_out,'Compute_Hypercubes.m',strcat('proc_',num2str(Lambdas(l)),'.m'));
    
    
    f_out  = fopen(strcat('cluster_processing/proc_',num2str(Lambdas(l)),'.sh'),'w');
    fprintf(f_out,'%s',txt_out);
    fclose(f_out);



    %Add sbatch in script
    fprintf(f_script,'%s%s\n','sbatch proc_',strcat(num2str(Lambdas(l)),'.sh'));

end

fclose(f_script);