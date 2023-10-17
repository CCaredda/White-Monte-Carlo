clear
close all



resolution_in_mm = 0;

Lambdas = 500:10:900;
nb_repeat = 60;
binning = 1;
out_path = 'output/';

% Add path
addpath('../functions');
addpath('/home/caredda/Soft/mcx/utils');
addpath('/home/caredda/Soft/mcxlab')

% Create output directory
if ~ isfolder(out_path)
    mkdir(out_path);
end

%Process model info
info_model = process_model_info(1e6,nb_repeat,'../images/Patient1/',resolution_in_mm);

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
