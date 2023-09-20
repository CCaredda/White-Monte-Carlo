%% Prepare photons exiting position and angles
clear
close all

run_in_cluster = 0;
use_parfor = 1;
% Add path
addpath('../functions');
addpath('../functions/Optical_coefficients');
if run_in_cluster == 1
    addpath('/pbs/home/c/ccaredda/private/mcx/utils');
else
    addpath('/home/caredda/Soft/mcx/utils');
end


load('../../output_mcxlab/study_lens/results_surface_binning_10.mat');
Diffuse_reflectance_surface_bin_10 = Diffuse_reflectance;
Mean_path_surface_bin_10 = Mean_path;

load('../../output_mcxlab/study_lens/lens_study.mat')
output_det.p = readmatrix('../../output_mcxlab/study_lens/txt/p_500.txt');
output_det.ppath = readmatrix('../../output_mcxlab/study_lens/txt/ppath_500.txt');
output_det.v = readmatrix('../../output_mcxlab/study_lens/txt/v_500.txt');

Lambdas = 500;

%Change the coordinate (set the optical axis at the center of the surface)
pos = output_det.p;
pos(:,1) = pos(:,1) - size(info_model.cfg.vol,1)/2;
pos(:,2) = pos(:,2) - size(info_model.cfg.vol,2)/2;

%Transpose pos vector, size (3,N photons)
pos = pos';

%Rotation around y axis (to simulate the light propagation, z+ axis was
%from the light to the tissue. We want the opposite so we apply the
%rotation matrix of 180 degrees around y axis.
Ry = [-1 0 0;0 1 0;0 0 -1];
pos = Ry*pos;

% Get angle of exiting photons (in radian)
angle = asin(output_det.v);

%Tranpose angles, size(3,Nphotons)
angle = angle';

%Rotate angles
angle = Ry*angle;


% Convert the position of exiting photons in mm
% not required for angles
pos = pos * info_model.cfg.unitinmm;


%% Definition of the lens system

% Definition lens used and Working distance
do = 400; % working distance in mm
f0 = 30; % focal in mm

% look for image plan
Zs=0;
Zf=200;
dz=0.1;
%Z_est: position in z of the image plan behind the lens (in mm)
[z_est, ~]=Ray_z(do, f0, Zs, Zf, dz); % details page 52 of pdf



%Compute transfer matrix
% S: transfer matrix
[detS, S]=Ray_s(do, f0, z_est); % details page 49 of pdf
%M=(ri(1))/x0(1); % magnification


%% Find position of photons in image plan from exit surface

%Concatenate position and angles
x_pos_angle = [pos(1,:);angle(1,:)];
y_pos_angle = [pos(2,:);angle(2,:)];
z_pos_angle = [pos(3,:);angle(3,:)];

%ri: image ray coordinate (in mm)
x_pos_angle_cam = S*x_pos_angle;
y_pos_angle_cam = S*y_pos_angle;
%z_pos_angle_cam = S*z_pos_angle;

%Concatenate output, size (N detected photons, 2)
out_p_mm = horzcat(x_pos_angle_cam(1,:)', y_pos_angle_cam(1,:)');

%% Define sensor size

% % Dimenson of sensor in mm (Camera Basler ace acA1920-25uc)
% y_sensor_mm = 4.2;
% x_sensor_mm = 2.4;

% % Dimenson of sensor in pixels (Camera Basler ace acA1920-25uc)
% y_sensor = 1920;
% x_sensor = 1080;


% Dimenson of sensor in mm (Camera Basler ace acA1920-25uc)
y_sensor_mm = 6;
x_sensor_mm = 5;

% Dimenson of sensor in pixels (Camera Basler ace acA1920-25uc)
y_sensor = 100;
x_sensor = floor(100*x_sensor_mm/y_sensor_mm);


% Binning 
binning = 1;
y_sensor = floor(y_sensor/binning);
x_sensor = floor(x_sensor/binning);

% Pixel resolution
reso_x = x_sensor_mm/x_sensor;
reso_y = y_sensor_mm/y_sensor;

%% prepare detector position for sensor and process image

%Convert ou_p in pixels
out_p = horzcat(out_p_mm(:,1)/reso_x , out_p_mm(:,2)/reso_y);

%Rotation around y axis of 180 degrees (back in the mcx space)
% out_p(:,1) = -out_p(:,1);
out_p(:,2) = -out_p(:,2);

%Get back in mcx space (space ordinate at at a corner no at the center of
%the surface)
out_p(:,1) = out_p(:,1) + x_sensor/2;
out_p(:,2) = out_p(:,2) + y_sensor/2;



% replace output_det.p by out_p
output_det.p = out_p;


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


% Change mua with the correct value (White Monte Carlo)
% 1: Grey matter
% 2: Large blood vessel
% 3: Capillaries
% 4: Activated grey matter
% 5: Activated large vessel
% 6: Activated capillaries
output_det.prop(2,1) = mua_GM; %1
output_det.prop(3,1) = mua_BV; %2
output_det.prop(4,1) = mua_capilaries; %3
output_det.prop(5,1) = mua_act_GM; %4
output_det.prop(6,1) = mua_act_BV; %5
output_det.prop(7,1) = mua_act_capilaries; %6

disp('Reconstruct images');


%Compute Image intensity and mean path length for wavelenth i
% To change: take into account difference in x and y resolutions

[Diffuse_reflectance,Mean_path] = reconstruct_Image(output_det,x_sensor,y_sensor,info_model.cfg.nphoton,reso_y,1,use_parfor);

%% Plot
close all
ft = 22;
figure()
subplot(221)
imagesc(Diffuse_reflectance_surface_bin_10)
title('Diffuse reflectance reconstructed at the surface','FontSize',ft)

subplot(222)
imagesc(Mean_path_surface_bin_10)
title('Pathlength reconstructed at the surface','FontSize',ft)

subplot(223)
imagesc(Diffuse_reflectance)
title({'Diffuse reflectance reconstructed with a lens', ...
    strcat('working distance: ',num2str(do),'mm, focal length: ',num2str(f0),'mm, Sensor size: ',num2str(x_sensor_mm),' x ',num2str(y_sensor_mm), 'mm')},'FontSize',ft)

subplot(224)
imagesc(Mean_path)
title({'Pathlength reconstructed with a lens', ...
    strcat('working distance: ',num2str(do),'mm, focal length: ',num2str(f0),'mm, Sensor size: ',num2str(x_sensor_mm),' x ',num2str(y_sensor_mm), 'mm')},'FontSize',ft)

