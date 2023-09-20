clear

% Path that contains results
path = '../output_mcxlab/results_patient1_reso_1mm_binning_1/'; 

% Load model info
load(strcat(path,'cst.mat')) % Load constants
binning = 1;

Lambdas = 500:10:900;

% Init output
load(strcat(path,'results_',num2str(Lambdas(1)),'_binning_',num2str(binning),'.mat'));
Hypercube = zeros(size(Diffuse_reflectance,1),size(Diffuse_reflectance,2),length(Lambdas));
Mean_path_length = zeros(size(Hypercube));


for l=1:length(Lambdas)
    load(strcat(path,'results_',num2str(Lambdas(l)),'_binning_',num2str(binning),'.mat'));
    Hypercube(:,:,l) = Diffuse_reflectance;
    Mean_path_length(:,:,l) = Mean_path;
end




% Get input model
in_img = info_model.cfg.vol(:,:,1);
in_img = imresize(in_img,[size(Hypercube,1) size(Hypercube,2)]);

LBV = [20 30];
GM = [40 40];


close all
ft = 22;


figure()
subplot(2,2,1)
title('Diffuse reflectance')
hold on,
plot(Lambdas,squeeze(Hypercube(GM(1),GM(2),:)),'g')
plot(Lambdas,squeeze(Hypercube(LBV(1),LBV(2),:)),'r')
legend('Grey matter','Large blood vessel')
xlabel('Wavelength (nm)')
ylabel('Diffuse reflectance (mm-2)')

subplot(2,2,2)
title('Mean path length')
hold on,
plot(Lambdas,squeeze(Mean_path_length(GM(1),GM(2),:)),'g')
plot(Lambdas,squeeze(Mean_path_length(LBV(1),LBV(2),:)),'r')
legend('Grey matter','Large blood vessel')
xlabel('Wavelength (nm)')
ylabel('Mean path length (mm)')

subplot(2,2,3)
imagesc(Hypercube(:,:,1))
h = colorbar;
h.Label.String = "mm-2";
h.Label.Rotation = 270;
h.Label.VerticalAlignment = "bottom";
title('Diffuse reflectance at 500 nm')

subplot(2,2,4)
imagesc(Mean_path_length(:,:,1))
h = colorbar;
h.Label.String = "mm";
h.Label.Rotation = 270;
h.Label.VerticalAlignment = "bottom";
title('Mean path length at 500 nm')



set(findall(gcf,'-property','FontSize'),'FontSize',ft)


figure()
imagesc(in_img)


%%
% binning = 10;
% dr_repeat_50 = readmatrix(strcat('../output_mcxlab/output_high_reso_repeat_50/results/dr_500_binning_',num2str(binning),'.txt'));
% dr_repeat_70 = readmatrix(strcat('../output_mcxlab/output_high_reso_repeat_70/results/dr_500_binning_',num2str(binning),'.txt'));
% 
% half_row = round(size(dr_repeat_50,1)/2);
% figure
% subplot(221)
% imagesc(dr_repeat_50)
% subplot(222)
% imagesc(dr_repeat_70)
% subplot(223)
% plot(dr_repeat_50(half_row,:))
% subplot(224)
% plot(dr_repeat_70(half_row,:))

% path = '/home/caredda/DVP/simulation/output_mcxlab/output_reso_0_2mm_repeat_50/';
path = '/home/caredda/DVP/simulation/output_mcxlab/output_high_reso_repeat_50/';

binning = 10;
dr = readmatrix(strcat(path,'results/dr_500_binning_',num2str(binning),'.txt'));
mp = readmatrix(strcat(path,'/results/mp_500_binning_',num2str(binning),'.txt'));

half_row = round(size(dr,1)/2);
close all
figure
subplot(221)
imagesc(dr)
subplot(222)
imagesc(mp)
subplot(223)
plot(dr(half_row,:))
subplot(224)
plot(mp(half_row,:))
