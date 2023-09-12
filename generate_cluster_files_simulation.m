% Generate files for cluster

clear

% Wavelength
% Lambdas = 500:10:900;
Lambdas = 600;

% Create directory that contain processing files
if ~exist('cluster_processing', 'dir')
   mkdir('cluster_processing')
end

%  In/out path
in_img_path = '''../images/Patient1/'';';
out_path = '''output/'';';

% Matlab file
code = sprintf('clear\naddpath(''../functions'');\naddpath(''../functions/Optical_coefficients'');');
code = strcat(code,sprintf(strcat('\nout_path = ',out_path)));
code = strcat(code,sprintf(strcat('\nin_img_path = ',in_img_path)));


% Read sh file
f_in = fopen('bash_templates/Compute_simulations.sh', 'r');
txt_sh=fread(f_in,'*char')';
fclose(f_in);

%Create script shell
f_script = fopen('cluster_processing/launch_simulations.sh', 'w');
fprintf(f_script,'%s\n','#!/bin/bash');



for l=1:length(Lambdas)

    % Generate matlab code
    f_m = fopen(strcat('cluster_processing/',num2str(Lambdas(l)),'.m'), 'w');
    code_temp = strcat(code,sprintf(strcat('\nLambdas = ',num2str(Lambdas(l)),';')));
    code_temp = strcat(code_temp,sprintf('\nprocess_simulations(Lambdas,1,in_img_path,out_path);'));
    fprintf(f_m,code_temp);


    %Modify sh file
    txt_out=strrep(txt_sh,'#SBATCH --job-name=simulations',strcat('#SBATCH --job-name=',num2str(Lambdas(l))));
    txt_out=strrep(txt_out,'#SBATCH --output=%j.log',strcat('#SBATCH --output=',num2str(Lambdas(l)),'%j.log'));
    txt_out=strrep(txt_out,'Compute_simulations.m',strcat(num2str(Lambdas(l)),'.m'));
    
    
    f_out  = fopen(strcat('cluster_processing/',num2str(Lambdas(l)),'.sh'),'w');
    fprintf(f_out,'%s',txt_out);
    fclose(f_out);



    %Add sbatch in script
    fprintf(f_script,'%s %s\n','sbatch',strcat(num2str(Lambdas(l)),'.sh'));

end

fclose(f_script);