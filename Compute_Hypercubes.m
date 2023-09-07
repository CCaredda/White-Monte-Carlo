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
path = '../output_mcxlab/output_patient1/'; 
% path = '../output_mcxlab/'; 


% Load model info
load(strcat(path,'cst.mat')) % Load constants
% load(strcat(path,'cst_500_600.mat')) % Load constants
Lambdas = 500;

% Compute mu_a values for brain tissue and blood vessel (in mm-1)
mua_GM = get_mua_values(Lambdas,22.1e-6,65.1e-6,0.7,0.1,5e-6,1e-6);
mua_BV = get_mua_values(Lambdas,125.1e-6,2375.1e-6,0,0,0,0);


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
    output_det.prop(2,1) = mua_GM(i);
    output_det.prop(3,1) = mua_BV(i);
   
    %Compute Image intensity and mean path length for wavelenth i
    [Hypercube(:,:,i),Mean_path_length(:,:,i)] = reconstruct_Image(output_det,nb_pixels_x,nb_pixels_y,info_model.cfg.nphoton,info_model.cfg.unitinmm);

end


min_H = min(Hypercube(:));
max_H = max(Hypercube(:));

min_mp = min(Mean_path_length(:));
max_mp = max(Mean_path_length(:));

% min_mp = 0;
% max_mp = 20;

close all;
for i = 1:length(Lambdas)
    figure(i); subplot(131),imagesc(info_model.img/max(info_model.img(:))), colorbar, title('Input model','fontsize',24),
    subplot(132), imagesc(Hypercube(:,:,i),[min_H max_H]), colorbar, title(strcat('Reconstructed diffuse reflectance ',num2str(Lambdas(i)),'nm'),'fontsize',24),
    subplot(133),   imagesc(Mean_path_length(:,:,i),[min_mp max_mp]), colorbar,title(strcat('Mean path length ',num2str(Lambdas(i)),'nm'),'fontsize',24)
end
