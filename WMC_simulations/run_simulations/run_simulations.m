clear
close all

% model_resolution_in_mm = 0;
model_resolution_in_mm = 0.2;

Lambdas = 500;
run_in_cluster = 0;
nb_repeat = 1;
nb_photons = 1e2;% 1e6;

out_path = 'output/';
% in_img_path = '../images/Patient1/';
in_img_path = '';


% Add path
addpath('../functions');
if run_in_cluster == 1
    addpath('/pbs/home/c/ccaredda/private/mcx/utils');
    addpath('/pbs/home/c/ccaredda/private/mcxlab');
else
    addpath('/home/caredda/Soft/mcx/utils');
    addpath('/home/caredda/Soft/mcxlab')
end



% Create output directory
if ~ isfolder(out_path)
    mkdir(out_path);
end


%Process model info
info_model = process_model_info(nb_photons,nb_repeat,in_img_path,model_resolution_in_mm);

save(strcat(out_path,'cst.mat'),'info_model');
f = fopen(strcat(out_path,'cst.txt'),'w');
fprintf(f,'%s %d\n','nb_photons ',nb_photons);
fprintf(f,'%s %d\n','repetitions ',nb_repeat);
fprintf(f,'%s %f\n','unitinmm ',info_model.cfg.unitinmm);
fprintf(f,'%s %d\n','vol_rows ',size(info_model.cfg.vol,1));
fprintf(f,'%s %d\n','vol_cols ',size(info_model.cfg.vol,2));
fclose(f);

%Process optical properties
Optical_prop = process_optical_properties(Lambdas);

% process simulations
for l=1:length(Lambdas)
    disp(strcat("Similation lambda ",num2str(Lambdas(l))))
    output_det = process_simulations(squeeze(Optical_prop(l,:,:)),info_model.cfg);

    % %  % detector output
    % % output_det.ppath = detphoton.ppath; % cummulative path lengths in each medium (partial pathlength) one need to multiply cfg.unitinmm with ppath to convert it to mm.
    % % output_det.p = detphoton.p; % exit position when cfg.issaveexit=1
    % % output_det.v = detphoton.v; % exit direction, when cfg.issaveexit=1
    % % output_det.prop = detphoton.prop;
    % 
    % 
    % save output
    disp('Save results')
    %writematrix(output_det.nscat,strcat(out_path,'nscat_',num2str(Lambdas(l)),'.txt'),'Delimiter',' ');
    writematrix(output_det.ppath,strcat(out_path,'ppath_',num2str(Lambdas(l)),'.txt'),'Delimiter',' ');
    writematrix(output_det.p,strcat(out_path,'p_',num2str(Lambdas(l)),'.txt'),'Delimiter',' ');
    writematrix(output_det.v,strcat(out_path,'v_',num2str(Lambdas(l)),'.txt'),'Delimiter',' ');
    writematrix(output_det.prop,strcat(out_path,'prop_',num2str(Lambdas(l)),'.txt'),'Delimiter',' ');


    % clear output
    clear output_det flux;

    % Zip files
    disp('Zip results')
    cd(out_path);
    zip(strcat(num2str(Lambdas(l)),'.zip'),{ ...
    %strcat('nscat_',num2str(Lambdas(l)),'.txt'), ...
    strcat('ppath_',num2str(Lambdas(l)),'.txt'), ...
    strcat('p_',num2str(Lambdas(l)),'.txt'), ...
    strcat('v_',num2str(Lambdas(l)),'.txt'), ...
    strcat('prop_',num2str(Lambdas(l)),'.txt')});

    % remove txt files
    disp('Delete temp files')
    % delete(strcat('nscat_',num2str(Lambdas(l)),'.txt'));
    delete(strcat('ppath_',num2str(Lambdas(l)),'.txt'));
    delete(strcat('p_',num2str(Lambdas(l)),'.txt'));
    delete(strcat('v_',num2str(Lambdas(l)),'.txt'));
    delete(strcat('prop_',num2str(Lambdas(l)),'.txt'));

    cd ..
end
