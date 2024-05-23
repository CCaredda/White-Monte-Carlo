clear
close all

% Divide the size of the pixel (increase the resolution)
division_factor = 1;

% model rectangle blood vessel
model_rect_blood_vessel = 0; % if 0, a pyramidal blood vessel is computed

% inverse volume for display
inverse_volume_for_display = 1;

Lambdas = 400:10:1000;
run_in_cluster = 0;
nb_repeat = 50; %Nb of repetitions used in MCX
simu_repeat = 1; %Larger number of repeat (avoid Matlab crash due to large txt files)
nb_photons = 1e6;

out_path = 'output/';
% in_img_path = '../images/Synthetic_img/';
% in_img_path = '../images/Patient2/';
in_img_path = '../images/centered_blood_vessel/';


% Add path
addpath('../functions');
addpath('/home/caredda/Soft/mcx/utils');
addpath('/home/caredda/Soft/mcxlab');
addpath('/home/caredda/Soft/iso2mesh');



% Create output directory
if ~ isfolder(out_path)
    mkdir(out_path);
end


%Process model info
info_model = process_model_info(nb_photons,nb_repeat,in_img_path,division_factor,model_rect_blood_vessel,inverse_volume_for_display);

%Process optical properties
Optical_prop = process_optical_properties(Lambdas);


% process cfg
for l=1:length(Lambdas)

    cfg = info_model.cfg;
   
    % Set optical properties % [mua,mus,g,n]
    cfg.prop=squeeze(Optical_prop(l,:,:));

    %Save cfg
    save(strcat('output/cfg_WMC_',num2str(Lambdas(l)),'.mat'),'cfg');

end

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

save('output/mua_WMC.mat','mua_GM','mua_BV','mua_capilaries',...
    'mua_act_GM','mua_act_BV','mua_act_capilaries');

% %Remove blood vessel
% info_model.cfg.vol(info_model.cfg.vol==2) = 1;

mcxpreview(info_model.cfg)
