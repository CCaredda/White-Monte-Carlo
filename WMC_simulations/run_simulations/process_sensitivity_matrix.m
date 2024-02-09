clear
close all

run_in_cluster = 1; % run in cluster or locally
Lambdas = 780; % wavelength


% Add path
addpath('../functions');
if run_in_cluster == 1
    addpath('/pbs/home/c/ccaredda/private/mcx/utils');
    addpath('/pbs/home/c/ccaredda/private/mcxlab');
else
    addpath('/home/caredda/Soft/mcx/utils');
    addpath('/home/caredda/Soft/mcxlab')
end



cfg.nphoton=1e6;  % Number of photons
cfg.respin=50;     % Repeat the simulation x times
% cfg.maxdetphoton = 1e6; % Maximum number of photons that can be detected 
cfg.gpuid=1;     % GPU processing
cfg.issaveref = 0;      % Save diffuse reflectance
cfg.tstart=0; % Starting time of the simulation (in seconds)
cfg.tend=33e-3; % Ending time of the simulation (in seconds)
cfg.tstep=33e-3; % Time-gate width of the simulation (in seconds)
cfg.isspecular = 1; % Calculate specular reflection if source is outside        
cfg.autopilot = 1;
cfg.unitinmm = 1; %unit in mm

%Boundary condition
%cfg.bc='ccrccr001000';
% ccrccc: Cyclic BC except for the top and bottom face (Fresnel reflection)
% 001000: Only capture photons from face z=z_min

%Volume
vol_square_size = 60;
cfg.vol = ones(vol_square_size,vol_square_size,vol_square_size); %grey matter
% cfg.vol(:,:,1) = 0; %Air

% Source type
% a uniform planar source outside the volume
%Source type (homogeneous) a 3D quadrilateral uniform planar source, with three corners specified by srcpos, srcpos+srcparam1(1:3) and srcpos+srcparam2(1:3)
cfg.srctype='planar';
cfg.srcpos=[0 0 0];
cfg.srcparam1=[size(cfg.vol,1) 0 0 0];
cfg.srcparam2=[0 size(cfg.vol,2) 0 0];
cfg.issrcfrom0=1;
cfg.srcdir=[0 0 1];


% Detector output
%cfg.savedetflag = 'spxv';
det_pos = [30 30 0 1]; % radius: 1 mm
% cfg.savedetflag = 'dp'; %Save detector id and partial path length




%Process optical properties
cfg.prop = process_optical_properties(Lambdas,false);

 % Random seed to obtain different results when running multiple simulations for the same input parameters
cfg.seed = randi([0,99999],1);


% calculate the fluence and partial path lengths
[flux, detp, vol, seeds]=mcxlab(cfg);


%Replay 
newcfg=cfg;
newcfg.seed=seeds.data;
newcfg.outputtype='jacobian';
newcfg.detphotons=detp.data;
[flux2, detp2, vol2, seeds2]=mcxlab(newcfg);
jac=sum(flux2.data,4);


save('out_sensitivity.mat',"jac","cfg");

