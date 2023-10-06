clear
close all



% Lambdas = 500:10:900;
% run_in_cluster = 1;
Lambdas = 500;
run_in_cluster = 0;

binning = 1;
data_path = 'output_repeat_30/';
use_parfor = 1;

% Add path
addpath('../functions');
addpath('../functions/Optical_coefficients');
if run_in_cluster == 1
    addpath('/pbs/home/c/ccaredda/private/mcx/utils');
else
    addpath('/home/caredda/Soft/mcx/utils');
end

% Load info model
load(strcat(data_path,'cst.mat'));   


% process simulations
for l=1:length(Lambdas)

    %Load data
    disp(strcat('Load data lambda ',num2str(Lambdas(l))));
    
    %Unzip file
    disp('Unzip files');
    unzip(strcat(data_path,num2str(Lambdas(l)),'.zip'),data_path);
       
    tic
    disp('Read files');
    %Read txt file
    output_det.prop = readmatrix(strcat(data_path,'prop_',num2str(Lambdas(l)),'.txt'));
    %output_det.nscat = readmatrix(strcat(data_path,'nscat_',num2str(Lambdas(l)),'.txt'));
    output_det.ppath = readmatrix(strcat(data_path,'ppath_',num2str(Lambdas(l)),'.txt'));
    output_det.p = readmatrix(strcat(data_path,'p_',num2str(Lambdas(l)),'.txt'));
    %output_det.v = readmatrix(strcat(data_path,'v_',num2str(Lambdas(l)),'.txt'));

    % disp('Remove temporary files');
    % % remove txt files
    % delete(strcat(data_path,'nscat_',num2str(Lambdas(l)),'.txt'));
    % delete(strcat(data_path,'ppath_',num2str(Lambdas(l)),'.txt'));
    % delete(strcat(data_path,'p_',num2str(Lambdas(l)),'.txt'));
    % delete(strcat(data_path,'v_',num2str(Lambdas(l)),'.txt'));
    % delete(strcat(data_path,'prop_',num2str(Lambdas(l)),'.txt'));




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
    save(strcat(data_path,'results_',num2str(Lambdas(l)),'_binning_',num2str(binning),'.mat'),'Diffuse_reflectance','Mean_path','binning','resolution_pixel');
    toc
end
