clear
close all
% Path that contains results
path = '../output_mcxlab/output_patient1/'; 

% Load model info
load(strcat(path,'cst.mat')) % Load constants

% Load mean path and hypercubes
load(strcat(path,'results_binnin_5.mat'));

% Get input model
in_img = info_model.cfg.vol(:,:,1);
in_img = imresize(in_img,[size(Hypercube,1) size(Hypercube,2)]);

LBV = [59 79];
GM = [100 112];

figure()
subplot(221)
title("Diffuse reflectance (mm-2)")
hold on,
plot(Lambdas,squeeze(Hypercube(GM(1),GM(2),:)),'g')
plot(Lambdas,squeeze(Hypercube(LBV(1),LBV(2),:)),'r')

subplot(222)
title("Mean path length (mm)")
hold on,
plot(Lambdas,squeeze(Mean_path_length(GM(1),GM(2),:)),'g')
plot(Lambdas,squeeze(Mean_path_length(LBV(1),LBV(2),:)),'r')


subplot(223)
imagesc(Hypercube(:,:,1))
subplot(224)
imagesc(Mean_path_length(:,:,1))

figure()
imagesc(in_img)