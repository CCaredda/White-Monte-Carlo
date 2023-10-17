clear
close all



resolution_in_mm = 0;

% Lambdas = 500:10:900;
% run_in_cluster = 1;
Lambdas = 500;
run_in_cluster = 0;
nb_repeat = 6;
binning = 1;
out_path = 'output/';
use_parfor = 1;




% Add path
addpath('../functions/Optical_coefficients');
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
info_model = process_model_info(1e6,nb_repeat,'../images/Patient1/',resolution_in_mm);
save(strcat(out_path,'cst.mat'),'info_model');


% process simulations
for l=1:length(Lambdas)
    tic
    disp(strcat("Simulation lambda ",num2str(Lambdas(l))))
     output_det = process_simulations(Lambdas(l),info_model.cfg);
     % Save info model
    if ~ isfile(strcat(out_path,'cst.mat'))
        save(strcat(out_path,'cst.mat'),'info_model');
    end

    % Define pixel resolution
    resolution_pixel = binning*info_model.cfg.unitinmm;
    
    % Compute binning: number of pixels along x and y axis according desired resolution
    if (binning == 1)
        nb_pixels_x = size(info_model.cfg.vol,1);
        nb_pixels_y = size(info_model.cfg.vol,2);
    else
        nb_pixels_x = floor(size(info_model.cfg.vol,1)/binning);
        nb_pixels_y = floor(size(info_model.cfg.vol,2)/binning);
    end
    
    
    % Compute mu_a values (in mm-1)
    % 1: Grey matter
    % 2: Large blood vessel
    % 3: Capillaries
    % 4: Activated grey matter
    % 5: Activated large vessel
    % 6: Activated capillaries
    mua_GM = get_mua_values(Lambdas(l),22.1e-6,65.1e-6,0.7,0.1,5e-6,1e-6); %1  
    mua_BV = get_mua_values(Lambdas(l),125.1e-6,2375.1e-6,0,0,0,0); %2
    mua_capilaries = mua_GM; %3
    mua_act_GM = mua_GM; %4
    mua_act_BV = mua_BV; %5
    mua_act_capilaries = mua_GM; %6


    % Change mua with the correct value (White Monte Carlo)
    % 1: Grey matter
    % 2: Large blood vessel
    % 3: Capillaries
    % 4: Activated grey matter
    % 5: Activated large vessel
    % 6: Activated capillaries
    output_det.prop(2,1) = mua_GM; %1
    output_det.prop(3,1) = mua_BV; %2
    output_det.prop(4,1) = mua_capilaries; %3
    output_det.prop(5,1) = mua_act_GM; %4
    output_det.prop(6,1) = mua_act_BV; %5
    output_det.prop(7,1) = mua_act_capilaries; %6
   
    disp('Reconstruct images');
    %Compute Image intensity and mean path length for wavelenth i
    [Diffuse_reflectance,Mean_path] = reconstruct_Image(output_det,nb_pixels_x,nb_pixels_y,info_model.cfg.nphoton,info_model.cfg.unitinmm,binning,use_parfor);
    
    % Save results
    save(strcat(out_path,'results_',num2str(Lambdas(l)),'_binning_',num2str(binning),'.mat'),'Diffuse_reflectance','Mean_path','binning','resolution_pixel');
    toc
end


