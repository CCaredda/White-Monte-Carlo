
%%-----------------------------------------------------------------
%% create the common parameters for all simulations
%%-----------------------------------------------------------------
clear

run_in_cluster = 0;

% Wavelength (nm)
Lambdas = 500:10:900; %500:900;

addpath('./functions/Optical_coefficients');
addpath('./functions');

if run_in_cluster == 1
    addpath('/pbs/home/c/ccaredda/private/mcxlab');
    cfg.nphoton=3e9; % Number of photons
else
    addpath('/home/caredda/Soft/mcxlab');
    cfg.nphoton=1e2; % Number of photons
end

% GPU processing
cfg.gpuid=1; 

 % Save diffuse reflectance
cfg.issaveref = 0;

% Seed for the random number generator
%cfg.seed=1648335518; 
                                    
%Acquisition time
cfg.tstart=0; % Starting time of the simulation (in seconds)
cfg.tend=33e-3; % Ending time of the simulation (in seconds)
cfg.tstep=33e-3; % Time-gate width of the simulation (in seconds)

% Calculate specular reflection if source is outside        
cfg.isspecular = 1; 
cfg.autopilot = 1;



%%-----------------------------------------------------------------
%% Load image segmentation and compute volume
%%-----------------------------------------------------------------

% path = 'images/Mouse/';
path = 'images/Patient1/';

%Load image and segmentation
% 1: Grey matter
% 2: Large blood vessel
% 3: Capillaries
% 4: Activated grey matter
% 5: Activated large vessel
% 6: Activated capillaries
[img,resolution_xyz] = Load_img_segmentation(path);

% Voxel size in mm
cfg.unitinmm = resolution_xyz; % Units in mm


%Create mesh (elem_pro: 1: brain tissue, 2: Blood vessel
cfg.vol = create_volume(img,resolution_xyz,cfg.issaveref);

%%-----------------------------------------------------------------
%% Generate wide-field detector
%%-----------------------------------------------------------------

% Per-face boundary condition (BC), a strig of 6 letters (case insensitive) for
% bounding box faces at -x,-y,-z,+x,+y,+z axes;
%    overwrite cfg.isreflect if given.
% each letter can be one of the following:
% '_': undefined, fallback to cfg.isreflect
% 'r': like cfg.isreflect=1, Fresnel reflection BC
% 'a': like cfg.isreflect=0, total absorption BC
% 'm': mirror or total reflection BC
% 'c': cyclic BC, enter from opposite face
% 
% in addition, cfg.bc can contain up to 12 characters,
% with the 7-12 characters indicating bounding box
% facets -x,-y,-z,+x,+y,+z are used as a detector. The 
% acceptable characters for digits 7-12 include
% '0': this face is not used to detector photons
% '1': this face is used to capture photons

% Boundary conditions
if cfg.issaveref == 0
    cfg.bc='ccrccr001000';
    % ccrccc: Cyclic BC except for the top and bottom face (Fresnel reflection)
    % 001000: Only capture photons from face z=z_min

    % Detector output
    cfg.savedetflag = 'dspxvw';
end

% a string (case insensitive) controlling the output detected photon data fields
% 1 d  output detector ID (1)
% 2 s  output partial scat. even counts (#media)
% 4 p  output partial path-lengths (#media)
% 8 m  output momentum transfer (#media)
% 16 x  output exit position (3)
% 32 v  output exit direction (3)
% 64 w  output initial weight (1)
% combine multiple items by using a string, or add selected numbers together
% by default, mcx only saves detector ID (d) and partial-path data (p)


%%-----------------------------------------------------------------
%% Generate planar light source
%%-----------------------------------------------------------------

% a uniform planar source outside the volume
%Source type (homogeneous) a 3D quadrilateral uniform planar source, with three corners specified by srcpos, srcpos+srcparam1(1:3) and srcpos+srcparam2(1:3)
cfg.srctype='planar';
cfg.srcpos=[0 0 0];
cfg.srcparam1=[size(cfg.vol,1) 0 0 0];
cfg.srcparam2=[0 size(cfg.vol,2) 0 0];
cfg.issrcfrom0=1;
cfg.srcdir=[0 0 1];


%%-----------------------------------------------------------------
%% Compute optical properties Grey matter (GM)
%%-----------------------------------------------------------------

% Anisoptropy coeff: 
opt_prop.g_GM    = 0.85; % Ref: Optical properties of selected native and coagulated human brain tissues in vitro in the visible and near infrared spectral range
% Refractive index
opt_prop.n_GM    = 1.36; % Ref: Brain refractive index measured in vivo with high-NA defocus-corrected full-field OCT and consequences for two-photon microscopy.

%Scattering coefficient % Optical properties of biological tissues: a review (Steven L Jacques) %cm-1
musP = (40.8 * (Lambdas/500).^(-3.089));
opt_prop.mus_GM  = musP/(1-opt_prop.g_GM); 

%Absorption coefficient (in mm-1) (Zerors: White Monte Carlo)
opt_prop.mua_GM = zeros(size(opt_prop.mus_GM)); %White Monte Carlo

%convert into mm-1
opt_prop.mus_GM  = 0.1*opt_prop.mus_GM;


%%-----------------------------------------------------------------
%% Compute optical properties Large Blood vessels (LBV)
%%-----------------------------------------------------------------

% Anisoptropy coeff
opt_prop.g_LBV    = 0.935; % Ref: Optical properties of human whole blood : changes due to slow heating
% Refractive index
opt_prop.n_LBV    = 1.4;  % Ref: Optical properties of human whole blood : changes due to slow heating

%Scattering coefficient % Optical properties of biological tissues: a review (Steven L Jacques) %cm-1
musP = (22 * (Lambdas/500).^(-0.66));
opt_prop.mus_LBV  = musP / (1-opt_prop.g_LBV); 

%Absorption coefficient (in mm-1) (Zerors: White Monte Carlo)
opt_prop.mua_LBV = zeros(size(opt_prop.mus_LBV)); %White Monte Carlo

%convert into mm-1
opt_prop.mus_LBV  = 0.1*opt_prop.mus_LBV;

%%-----------------------------------------------------------------
%% Compute optical properties Capillaries (Cap)
%%-----------------------------------------------------------------

% Anisoptropy coeff: 
opt_prop.g_Cap  = opt_prop.g_GM;
% Refractive index
opt_prop.n_Cap = opt_prop.n_GM;
%Scattering coefficient
opt_prop.mus_Cap = opt_prop.mus_GM;
%Absorption coefficient (in mm-1) (Zeros: White Monte Carlo)
opt_prop.mua_Cap = zeros(size(opt_prop.mus_Cap)); %White Monte Carlo


%%-----------------------------------------------------------------
%% Compute optical properties Activated grey matter (act_GM)
%%-----------------------------------------------------------------

% Anisoptropy coeff: 
opt_prop.g_act_GM  = opt_prop.g_GM;
% Refractive index
opt_prop.n_act_GM = opt_prop.n_GM;
%Scattering coefficient
opt_prop.mus_act_GM = opt_prop.mus_GM;
%Absorption coefficient (in mm-1) (Zeros: White Monte Carlo)
opt_prop.mua_act_GM = zeros(size(opt_prop.mus_act_GM)); %White Monte Carlo


%%-----------------------------------------------------------------
%% Compute optical properties Activated large blood vessels (act_LBV)
%%-----------------------------------------------------------------

% Anisoptropy coeff
opt_prop.g_act_LBV = opt_prop.g_LBV;
% Refractive index
opt_prop.n_act_LBV = opt_prop.n_LBV;
%Scattering coefficient
opt_prop.mus_act_LBV = opt_prop.mus_LBV;
%Absorption coefficient (in mm-1) (Zeros: White Monte Carlo)
opt_prop.mua_act_LBV = zeros(size(opt_prop.mus_act_LBV)); %White Monte Carlo


%%-----------------------------------------------------------------
%% Compute optical properties Activated Capillaries (act_Cap)
%%-----------------------------------------------------------------

% Anisoptropy coeff: 
opt_prop.g_act_Cap = opt_prop.g_Cap;
% Refractive index
opt_prop.n_act_Cap = opt_prop.n_Cap;
%Scattering coefficient
opt_prop.mus_act_Cap = opt_prop.mus_Cap;
%Absorption coefficient (in mm-1) (Zeros: White Monte Carlo)
opt_prop.mua_act_Cap = zeros(size(opt_prop.mus_act_Cap)); %White Monte Carlo


clear musP

%%-----------------------------------------------------------------
%% Store model parameters
%%-----------------------------------------------------------------

%Store info into structure
info_model.cfg = cfg;
info_model.resolution_xyz = resolution_xyz;
info_model.img = img;
info_model.opt_prop = opt_prop;


%%-----------------------------------------------------------------
%% Start simulations
%%-----------------------------------------------------------------

% Create output directory
if ~ isfolder('output')
    mkdir('output');
end

% Save constants
save('output/cst.mat','info_model','Lambdas');



for l = 1:length(Lambdas)
    % Set optical properties % [mua,mus,g,n]
    % 0: Air
    % 1: Grey matter
    % 2: Large blood vessel
    % 3: Capillaries
    % 4: Activated grey matter
    % 5: Activated large vessel
    % 6: Activated capillaries
    cfg.prop=[0 0 1 1; ...
    info_model.opt_prop.mua_GM(l) info_model.opt_prop.mus_GM(l) info_model.opt_prop.g_GM info_model.opt_prop.n_GM ; ...
    info_model.opt_prop.mua_LBV(l) info_model.opt_prop.mus_LBV(l) info_model.opt_prop.g_LBV info_model.opt_prop.n_LBV ; ...
    info_model.opt_prop.mua_Cap(l) info_model.opt_prop.mus_Cap(l) info_model.opt_prop.g_Cap info_model.opt_prop.n_Cap ; ...
    info_model.opt_prop.mua_act_GM(l) info_model.opt_prop.mus_act_GM(l) info_model.opt_prop.g_act_GM info_model.opt_prop.n_act_GM ; ...
    info_model.opt_prop.mua_act_LBV(l) info_model.opt_prop.mus_act_LBV(l) info_model.opt_prop.g_act_LBV info_model.opt_prop.n_act_LBV ; ...
    info_model.opt_prop.mua_act_Cap(l) info_model.opt_prop.mus_act_Cap(l) info_model.opt_prop.g_act_Cap info_model.opt_prop.n_act_Cap];

    % calculate the fluence and partial path lengths
    [flux,output_det]=mcxlab(cfg); 
    
    
    
    % % detector output
    % output_det.ppath = detphoton.ppath; % cummulative path lengths in each medium (partial pathlength) one need to multiply cfg.unitinmm with ppath to convert it to mm.
    % output_det.p = detphoton.p; % exit position when cfg.issaveexit=1
    % output_det.v = detphoton.v; % exit direction, when cfg.issaveexit=1
    % output_det.prop = detphoton.prop;
    
    if cfg.issaveref
        dref = flux.dref(:,:,1);
        save(strcat('output/out_',num2str(Lambdas(l)),'nm.mat'),'output_det','dref');
    else
        save(strcat('output/out_',num2str(Lambdas(l)),'nm.mat'),'output_det');
    end

end

