% Generate files for cluster

Lambdas = 500:10:900;



% Read matlab file
f_in = fopen('cluster_processing/template.m', 'r');
txt_m=fread(f_in,'*char')';
fclose(f_in);

% Read sh file
f_in = fopen('cluster_processing/template.sh', 'r');
txt_sh=fread(f_in,'*char')';
fclose(f_in);

%Create script shell
f_script = fopen('cluster_processing/launch_simulations.sh', 'w');
fprintf(f_script,'%s\n','#!/bin/bash');


for l=1:length(Lambdas)

    %Modify wavelenth in matlab files
    txt_out=strrep(txt_m,'Lambdas = 500;',strcat('Lambdas = ',num2str(Lambdas(l)),';'));
    f_out  = fopen(strcat('cluster_processing/',num2str(Lambdas(l)),'.m'),'w');
    fprintf(f_out,'%s',txt_out);
    fclose(f_out);

    %Modify sh file
    txt_out=strrep(txt_sh,'#SBATCH --job-name=',strcat('#SBATCH --job-name=',num2str(Lambdas(l))));
    txt_out=strrep(txt_out,'#SBATCH --output=%j.log',strcat('#SBATCH --output=',num2str(Lambdas(l)),'%j.log'));
    txt_out=strrep(txt_out,'Compute_simulations.m',strcat(num2str(Lambdas(l)),'.m'));
    
    
    f_out  = fopen(strcat('cluster_processing/',num2str(Lambdas(l)),'.sh'),'w');
    fprintf(f_out,'%s',txt_out);
    fclose(f_out);



    %Add sbatch in script
    fprintf(f_script,'%s %s\n','sbatch',strcat(num2str(Lambdas(l)),'.sh'));

end

fclose(f_script);