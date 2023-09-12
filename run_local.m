%% Run simulation in local computer


clear
close all

% Add path
addpath('functions');
addpath('functions/Optical_coefficients');

Lambdas = 500;
binning = 5;
out_path = 'output/';

% process simulations
process_simulations(Lambdas,0,'images/Patient1/',out_path);

% Display diffuse reflectance and mean path maps
process_Diffuse_Reflectance_Mean_path_Images(Lambdas,0,1,out_path,binning);

% Display results
load(strcat(out_path,'results_',num2str(Lambdas),'_binning_',num2str(binning),'.mat'));
load(strcat(out_path,'cst.mat'));


figure();
subplot(131),imagesc(info_model.cfg.vol(:,:,1)), colorbar, title('Input model','fontsize',24),
subplot(132), imagesc(Diffuse_reflectance), colorbar, title(strcat('Reconstructed diffuse reflectance ',num2str(Lambdas),'nm'),'fontsize',24),
subplot(133),   imagesc(Mean_path), colorbar,title(strcat('Mean path length ',num2str(Lambdas),'nm'),'fontsize',24)


%% Display results

clear
close all


% Add path
addpath('functions');
addpath('functions/Optical_coefficients');


wavelength = 500;
binning = 5;
out_path = '/home/caredda/DVP/simulation/output_mcxlab/test/';

% Display diffuse reflectance and mean path maps
process_Diffuse_Reflectance_Mean_path_Images(wavelength,0,0,out_path,binning);

load(strcat(out_path,'results_',num2str(wavelength),'_binning_',num2str(binning),'.mat'));
load(strcat(out_path,'cst.mat'));


figure();
subplot(131),imagesc(info_model.cfg.vol(:,:,1)), colorbar, title('Input model','fontsize',24),
subplot(132), imagesc(Diffuse_reflectance), colorbar, title(strcat('Reconstructed diffuse reflectance ',num2str(wavelength),'nm'),'fontsize',24),
subplot(133),   imagesc(Mean_path), colorbar,title(strcat('Mean path length ',num2str(wavelength),'nm'),'fontsize',24)


