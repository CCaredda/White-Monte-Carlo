function [output_det] = process_simulations(Optical_properties,cfg)
    %%-----------------------------------------------------------------
    %% create the common parameters for all simulations
    %%-----------------------------------------------------------------
    %Inputs:
    %Optical_properties: vector of size (7,4): 7 nb of tissues, 4: [mua mus
    %n g]
    %run_in_cluster: (0: run in local, 1: run on computation grid)
    %in_img_path: path of the input image
    %model_resolution_in_mm: desired voxel resolution in mm, if not
    %indicated, use the input image resolution
    %Output
    %output_det: Detector output
    %info_model: info_model
    
    %%-----------------------------------------------------------------
    %% Start simulations
    %%-----------------------------------------------------------------
    
    
    disp('Start simulations');
    
    
    % Set optical properties % [mua,mus,g,n]
    % 0: Air
    % 1: Grey matter
    % 2: Large blood vessel
    % 3: Capillaries
    % 4: Activated grey matter
    % 5: Activated large vessel
    % 6: Activated capillaries
    cfg.prop = Optical_properties;
    cfg.prop
    % cfg.prop=[0 0 1 1; ...
    % mua_GM         mus_GM         g_GM       n_GM ; ...
    % mua_LBV        mus_LBV        g_LBV      n_LBV ; ...
    % mua_Cap        mus_Cap        g_Cap      n_Cap ; ...
    % mua_act_GM     mus_act_GM     g_act_GM   n_act_GM ; ...
    % mua_act_LBV    mus_act_LBV    g_act_LBV  n_act_LBV ; ...
    % mua_act_Cap    mus_act_Cap    g_act_Cap  n_act_Cap];

    
    % calculate the fluence and partial path lengths
    [flux,output_det]=mcxlab(cfg); 
    
    
    
     
end