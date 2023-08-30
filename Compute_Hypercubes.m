%% MCXLab HYPERSPECTRAL DATA PROCESSING CODE:
% DESCRIPTION: This code reads and processes data simulated with MMCLab, in order 
% to generate 3D hyperspectral data cubes at different wavelength bands

clear; 
% Reconstruct diffuse reflectance with exiting photons

% Add path for using functions
addpath('/home/caredda/Soft/mcx/utils');
addpath('./functions');
addpath('./functions/Optical_coefficients');


% Path that contains results
% path = '../output_mcxlab/output_patient1/'; 
path = '../output_mcxlab/output_pp_WMC_1/'; 


% Load model info
load(strcat(path,'cst.mat')) % Load constants


% Compute mu_a values for brain tissue and blood vessel (in mm-1)
mua_GM = get_mua_values(Lambdas,22.1e-6,65.1e-6,0.7,0.1,5e-6,1e-6);
mua_BV = get_mua_values(Lambdas,125,2375,0,0,0,0);


% Define pixel resolution
resolution_pixel = info_model.resolution_xyz;

% Compute the number of pixels along x and y axis according desired
% resolution
nb_pixels_x = size(info_model.cfg.vol,1);
nb_pixels_y = size(info_model.cfg.vol,2);

%Init Hyperspectral image and mean path length image
Hypercube = zeros(nb_pixels_x,nb_pixels_y,length(Lambdas));
Mean_path_length = zeros(nb_pixels_x,nb_pixels_y,length(Lambdas));

% Load ppl
for i=1:length(Lambdas)
    load(strcat(path,'out_',num2str(Lambdas(i)),'nm.mat'))

    % Change mua with the correct value (White Monte Carlo)
    if info_model.white_MC == 1
        output_det.prop(2,1) = mua_GM(i);
        output_det.prop(3,1) = mua_BV(i);
    end
    
    %Compute Image intensity and mean path length for wavelenth i
    [Hypercube(:,:,i),Mean_path_length(:,:,i)] = reconstruct_Image(output_det,nb_pixels_x,nb_pixels_y,info_model.cfg.nphoton,info_model.cfg.unitinmm);

end


min_H = min(Hypercube(:));
max_H = max(Hypercube(:));

min_mp = min(Mean_path_length(:));
max_mp = max(Mean_path_length(:));

close all;
for i = 1:length(Lambdas)
    figure(i); subplot(121), imagesc(Hypercube(:,:,i),[min_H max_H]), colorbar, title(strcat('Reconstructed diffuse reflectance ',num2str(Lambdas(i)),'nm')), subplot(122),   imagesc(Mean_path_length(:,:,i),[min_mp max_mp]), colorbar,title(strcat('Mean path length ',num2str(Lambdas(i)),'nm'))
end
