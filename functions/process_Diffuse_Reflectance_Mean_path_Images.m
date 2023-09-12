function process_Diffuse_Reflectance_Mean_path_Images(wavelength,run_in_cluster,output_is_zip,data_path,binning)
    %% MCXLab HYPERSPECTRAL DATA PROCESSING CODE:
    % DESCRIPTION: This code reads and processes data simulated with MMCLab, in order 
    % to generate 3D hyperspectral data cubes at different wavelength bands
    
    % INPUTS
    % wavelength: wavelength in nm
    % run_in_cluster: (0: local, 1: on cluster)
    % Output output_is_zip (0: .mat, 1: .zip)
    % data_path: path that contained data
    % binning: binning used to reconstruct images

    

    % tic
    % Reconstruct diffuse reflectance with exiting photons
    
    % Add path for using functions
    if run_in_cluster == 1
        addpath('/pbs/home/c/ccaredda/private/mcx/utils');
    else
        addpath('/home/caredda/Soft/mcx/utils');
    end
    

        
    % Load model info
    load(strcat(data_path,'/cst.mat')) % Load constants
    
    
    % Define pixel resolution
    resolution_pixel = binning*info_model.cfg.unitinmm;
    
    % Compute binning: number of pixels along x and y axis according desired resolution
    if (binning == 1)
        nb_pixels_x = size(info_model.cfg.vol,1);
        nb_pixels_y = size(info_model.cfg.vol,2);
    else
        nb_pixels_x = floor(size(info_model.cfg.vol,1)/binning);
        nb_pixels_y = floor(size(info_model.cfg.vol,2)/binning);
    end
    
    
    % Compute mu_a values (in mm-1)
    % 1: Grey matter
    % 2: Large blood vessel
    % 3: Capillaries
    % 4: Activated grey matter
    % 5: Activated large vessel
    % 6: Activated capillaries
    mua_GM = get_mua_values(wavelength,22.1e-6,65.1e-6,0.7,0.1,5e-6,1e-6); %1  
    mua_BV = get_mua_values(wavelength,125.1e-6,2375.1e-6,0,0,0,0); %2
    mua_capilaries = mua_GM; %3
    mua_act_GM = mua_GM; %4
    mua_act_BV = mua_BV; %5
    mua_act_capilaries = mua_GM; %6
    
    

    clear output_det;


    % Load detector output
    if output_is_zip == 1
        %Unzip file
        unzip(strcat(data_path,num2str(wavelength),'.zip'),data_path);
        
        %Read txt file
        output_det.prop = readmatrix(strcat(data_path,'prop_',num2str(wavelength),'.txt'));
        output_det.nscat = readmatrix(strcat(data_path,'nscat_',num2str(wavelength),'.txt'));
        output_det.ppath = readmatrix(strcat(data_path,'ppath_',num2str(wavelength),'.txt'));
        output_det.p = readmatrix(strcat(data_path,'p_',num2str(wavelength),'.txt'));
        output_det.v = readmatrix(strcat(data_path,'v_',num2str(wavelength),'.txt'));

        % remove txt files
        delete(strcat(data_path,'nscat_',num2str(wavelength),'.txt'));
        delete(strcat(data_path,'ppath_',num2str(wavelength),'.txt'));
        delete(strcat(data_path,'p_',num2str(wavelength),'.txt'));
        delete(strcat(data_path,'v_',num2str(wavelength),'.txt'));
        delete(strcat(data_path,'prop_',num2str(wavelength),'.txt'));

    else
        load(strcat(data_path,'out_',num2str(wavelength),'nm.mat'))
    end




    

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
   
    %Compute Image intensity and mean path length for wavelenth i
    [Diffuse_reflectance,Mean_path] = reconstruct_Image(output_det,nb_pixels_x,nb_pixels_y,info_model.cfg.nphoton,info_model.cfg.unitinmm,binning);
    
    % Save results
    save(strcat(data_path,'results_',num2str(wavelength),'_binning_',num2str(binning),'.mat'),'Diffuse_reflectance','Mean_path','binning','resolution_pixel');

end