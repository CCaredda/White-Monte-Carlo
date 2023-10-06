%%

## @brief test

%% get Hypercube

clear

% Path that contains results
% path = '/home/caredda/DVP/simulation/output_mcxlab/output_reso_1mm_repeat_1/';
% binning = 1;
% Lambdas = 500:10:530;

path = '/home/caredda/DVP/simulation/output_mcxlab/output_high_reso_repeat_50/'; 
binning = 7;
Lambdas = 500:10:900;


% Init output
dr = readmatrix(strcat(path,'results/dr_surface_',num2str(Lambdas(1)),'_binning_',num2str(binning),'.txt'));

Hypercube = zeros(size(dr,1),size(dr,2),length(Lambdas));
Mean_path_length = zeros(size(Hypercube));


for l=1:length(Lambdas)
    dr = readmatrix(strcat(path,'results/dr_surface_',num2str(Lambdas(l)),'_binning_',num2str(binning),'.txt'));
    mp = readmatrix(strcat(path,'results/mp_surface_',num2str(Lambdas(l)),'_binning_',num2str(binning),'.txt'));
    
    Hypercube(:,:,l) = dr;
    Mean_path_length(:,:,l) = mp;
end

save(strcat(path,'results_surface_binning_',num2str(binning),'.mat'),'Hypercube','Mean_path_length','Lambdas');


%%
clear

% path = '/home/caredda/DVP/simulation/output_mcxlab/output_reso_1mm_repeat_1/';
% binning = 1;
% Lambdas = 500:10:530;

path = '/home/caredda/DVP/simulation/output_mcxlab/output_high_reso_repeat_50/'; 
binning = 7;
Lambdas = 500:10:900;


load(strcat(path,'results_surface_binning_',num2str(binning),'.mat'));
load(strcat(path,'cst.mat'));



% Get input model
in_img = info_model.cfg.vol(:,:,1);
in_img = imresize(in_img,[size(Hypercube,1) size(Hypercube,2)]);

id_l = 1;

min_dr = min(Hypercube(:));
max_dr = max(Hypercube(:));
min_mp = min(Mean_path_length(:));
max_mp = max(Mean_path_length(:));


figure()
subplot(221)
imagesc(Hypercube(:,:,id_l),[min_dr,max_dr]),impixelinfo
h = colorbar;
h.Label.String = "mm-2";
h.Label.Rotation = 270;
h.Label.VerticalAlignment = "bottom";
title(strcat('Diffuse reflectance at ',num2str(Lambdas(id_l)),' nm'))

subplot(222)
imagesc(Mean_path_length(:,:,id_l),[min_mp,max_mp])
h = colorbar;
h.Label.String = "mm";
h.Label.Rotation = 270;
h.Label.VerticalAlignment = "bottom";
title(strcat('Mean path length at ',num2str(Lambdas(id_l)),' nm'))

id_l = 21;

subplot(223)
imagesc(Hypercube(:,:,id_l),[min_dr,max_dr])
h = colorbar;
h.Label.String = "mm-2";
h.Label.Rotation = 270;
h.Label.VerticalAlignment = "bottom";
title(strcat('Diffuse reflectance at ',num2str(Lambdas(id_l)),' nm'))

subplot(224)
imagesc(Mean_path_length(:,:,id_l),[min_mp,max_mp])
h = colorbar;
h.Label.String = "mm";
h.Label.Rotation = 270;
h.Label.VerticalAlignment = "bottom";
title(strcat('Mean path length at ',num2str(Lambdas(id_l)),' nm'))



%%
LBV = [42 56];
GM = [100 80];


close all
ft = 22;
lw = 3;


figure()
subplot(1,2,1)
title('Diffuse reflectance')
hold on,
plot(Lambdas,squeeze(Hypercube(GM(1),GM(2),:)),'g','LineWidth',lw)
plot(Lambdas,squeeze(Hypercube(LBV(1),LBV(2),:)),'r','LineWidth',lw)
legend('Grey matter','Large blood vessel')
xlabel('Wavelength (nm)')
ylabel('Diffuse reflectance (mm-2)')
grid()
xlim([Lambdas(1),Lambdas(end)])

subplot(1,2,2)
title('Mean path length')
hold on,
plot(Lambdas,squeeze(Mean_path_length(GM(1),GM(2),:)),'g','LineWidth',lw)
plot(Lambdas,squeeze(Mean_path_length(LBV(1),LBV(2),:)),'r','LineWidth',lw)
legend('Grey matter','Large blood vessel')
xlabel('Wavelength (nm)')
ylabel('Mean path length (mm)')
grid()
xlim([Lambdas(1),Lambdas(end)])


set(findall(gcf,'-property','FontSize'),'FontSize',ft)


% figure()
% imagesc(in_img)


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

binning = 7;
dr_500 = readmatrix(strcat(path,'results/dr_surface_500_binning_',num2str(binning),'.txt'));
mp_500 = readmatrix(strcat(path,'/results/mp_surface_500_binning_',num2str(binning),'.txt'));
dr_700 = readmatrix(strcat(path,'results/dr_surface_700_binning_',num2str(binning),'.txt'));
mp_700 = readmatrix(strcat(path,'/results/mp_surface_700_binning_',num2str(binning),'.txt'));
dr_900 = readmatrix(strcat(path,'results/dr_surface_900_binning_',num2str(binning),'.txt'));
mp_900 = readmatrix(strcat(path,'/results/mp_surface_900_binning_',num2str(binning),'.txt'));


min_dr = min([min(dr_500(:)) min(dr_700(:)) min(dr_900(:))]);
max_dr = max([max(dr_500(:)) max(dr_700(:)) max(dr_900(:))]);
min_mp = min([min(mp_500(:)) min(mp_700(:)) min(mp_900(:))]);
max_mp = max([max(mp_500(:)) max(mp_700(:)) max(mp_900(:))]);

ft = 20;

close all
figure
subplot(321)
imagesc(dr_500,[min_dr,max_dr])
h = colorbar;
h.Label.String = "mm-2";
h.Label.Rotation = 270;
h.Label.VerticalAlignment = "bottom";
title('Diffuse reflectance at 500 nm','FontSize',ft)

subplot(322)
imagesc(mp_500,[min_mp,max_mp])
h = colorbar;
h.Label.String = "mm";
h.Label.Rotation = 270;
h.Label.VerticalAlignment = "bottom";
title('Mean path length at 500 nm','FontSize',ft)

subplot(323)
imagesc(dr_700,[min_dr,max_dr])
h = colorbar;
h.Label.String = "mm-2";
h.Label.Rotation = 270;
h.Label.VerticalAlignment = "bottom";
title('Diffuse reflectance at 700 nm','FontSize',ft)

subplot(324)
imagesc(mp_700,[min_mp,max_mp])
h = colorbar;
h.Label.String = "mm";
h.Label.Rotation = 270;
h.Label.VerticalAlignment = "bottom";
title('Mean path length at 700 nm','FontSize',ft)

subplot(325)
imagesc(dr_900,[min_dr,max_dr])
h = colorbar;
h.Label.String = "mm-2";
h.Label.Rotation = 270;
h.Label.VerticalAlignment = "bottom";
title('Diffuse reflectance at 900 nm','FontSize',ft)

subplot(326)
imagesc(mp_900,[min_mp,max_mp])
h = colorbar;
h.Label.String = "mm";
h.Label.Rotation = 270;
h.Label.VerticalAlignment = "bottom";
title('Mean path length at 900 nm','FontSize',ft)

