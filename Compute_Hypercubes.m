%% MCXLab HYPERSPECTRAL DATA PROCESSING CODE:
% DESCRIPTION: This code reads and processes data simulated with MMCLab, in order 
% to generate 3D hyperspectral data cubes at different wavelength bands

clear;

output_is_zip = 1;

tic
% Reconstruct diffuse reflectance with exiting photons

% Add path for using functions
addpath('/home/caredda/Soft/mcx/utils');
addpath('./functions');
addpath('./functions/Optical_coefficients');


% Path that contains results
% path = '../output_mcxlab/output_patient1/'; 
% path = '../output_mcxlab/test/'; 
path = 'output/'; 


% Load model info
load(strcat(path,'cst.mat')) % Load constants
Lambdas = 500;


% Define pixel resolution
binning = 5;
resolution_pixel = binning*info_model.cfg.unitinmm;


% Compute mu_a values (in mm-1)
% 1: Grey matter
% 2: Large blood vessel
% 3: Capillaries
% 4: Activated grey matter
% 5: Activated large vessel
% 6: Activated capillaries
mua_GM = get_mua_values(Lambdas,22.1e-6,65.1e-6,0.7,0.1,5e-6,1e-6); %1  
mua_BV = get_mua_values(Lambdas,125.1e-6,2375.1e-6,0,0,0,0); %2
mua_capilaries = mua_GM; %3
mua_act_GM = mua_GM; %4
mua_act_BV = mua_BV; %5
mua_act_capilaries = mua_GM; %6




% Compute binning: number of pixels along x and y axis according desired resolution
if (binning == 1)
    nb_pixels_x = size(info_model.cfg.vol,1);
    nb_pixels_y = size(info_model.cfg.vol,2);
else
    nb_pixels_x = floor(size(info_model.cfg.vol,1)/binning);
    nb_pixels_y = floor(size(info_model.cfg.vol,2)/binning);
end


%Init Hyperspectral image and mean path length image
Hypercube = zeros(nb_pixels_x,nb_pixels_y,length(Lambdas));
Mean_path_length = zeros(nb_pixels_x,nb_pixels_y,length(Lambdas));

for i=1:length(Lambdas)
    
    clear output_det;


    % Load detector output
    if output_is_zip == 1
        %Unzip file
        unzip(strcat(path,num2str(Lambdas(i)),'.zip'),path);
        
        %Read txt file
        output_det.prop = readmatrix(strcat(path,'prop_',num2str(Lambdas(i)),'.txt'));
        output_det.nscat = readmatrix(strcat(path,'nscat_',num2str(Lambdas(i)),'.txt'));
        output_det.ppath = readmatrix(strcat(path,'ppath_',num2str(Lambdas(i)),'.txt'));
        output_det.p = readmatrix(strcat(path,'p_',num2str(Lambdas(i)),'.txt'));
        output_det.v = readmatrix(strcat(path,'v_',num2str(Lambdas(i)),'.txt'));

        % remove txt files
        delete(strcat(path,'nscat_',num2str(Lambdas(i)),'.txt'));
        delete(strcat(path,'ppath_',num2str(Lambdas(i)),'.txt'));
        delete(strcat(path,'p_',num2str(Lambdas(i)),'.txt'));
        delete(strcat(path,'v_',num2str(Lambdas(i)),'.txt'));
        delete(strcat(path,'prop_',num2str(Lambdas(i)),'.txt'));

    else
        load(strcat(path,'out_',num2str(Lambdas(i)),'nm.mat'))
    end




    

    % Change mua with the correct value (White Monte Carlo)
    % 1: Grey matter
    % 2: Large blood vessel
    % 3: Capillaries
    % 4: Activated grey matter
    % 5: Activated large vessel
    % 6: Activated capillaries
    output_det.prop(2,1) = mua_GM(i); %1
    output_det.prop(3,1) = mua_BV(i); %2
    output_det.prop(4,1) = mua_capilaries(i); %3
    output_det.prop(5,1) = mua_act_GM(i); %4
    output_det.prop(6,1) = mua_act_BV(i); %5
    output_det.prop(7,1) = mua_act_capilaries(i); %6
   
    %Compute Image intensity and mean path length for wavelenth i
    [Hypercube(:,:,i),Mean_path_length(:,:,i)] = reconstruct_Image(output_det,nb_pixels_x,nb_pixels_y,info_model.cfg.nphoton,info_model.cfg.unitinmm,binning);

end

toc

min_H = min(Hypercube(:));
max_H = max(Hypercube(:));

min_mp = min(Mean_path_length(:));
max_mp = max(Mean_path_length(:));

% min_mp = 0;
% max_mp = 20;

close all;
for i = 1:length(Lambdas)
    figure(i); subplot(131),imagesc(info_model.cfg.vol(:,:,1)), colorbar, title('Input model','fontsize',24),
    subplot(132), imagesc(Hypercube(:,:,i),[min_H max_H]), colorbar, title(strcat('Reconstructed diffuse reflectance ',num2str(Lambdas(i)),'nm'),'fontsize',24),
    subplot(133),   imagesc(Mean_path_length(:,:,i),[min_mp max_mp]), colorbar,title(strcat('Mean path length ',num2str(Lambdas(i)),'nm'),'fontsize',24)
end


%% Save results
save(strcat(path,'results_binnin_',num2str(binning),'.mat'),'Hypercube','Mean_path_length','binning','resolution_pixel');

