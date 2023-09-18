function [output_det] = process_simulations(Lambdas,cfg)
    %%-----------------------------------------------------------------
    %% create the common parameters for all simulations
    %%-----------------------------------------------------------------
    %Inputs:
    %Lambdas: Wavelength (in nm)
    %run_in_cluster: (0: run in local, 1: run on computation grid)
    %in_img_path: path of the input image
    %model_resolution_in_mm: desired voxel resolution in mm, if not
    %indicated, use the input image resolution
    %Output
    %output_det: Detector output
    %info_model: info_model
    
    disp('Init parameters');


    
    
    
    

    
    %%-----------------------------------------------------------------
    %% Compute optical properties Grey matter (GM)
    %%-----------------------------------------------------------------
    
    % Anisoptropy coeff: 
    g_GM    = 0.85; % Ref: Optical properties of selected native and coagulated human brain tissues in vitro in the visible and near infrared spectral range
    % Refractive index
    n_GM    = 1.36; % Ref: Brain refractive index measured in vivo with high-NA defocus-corrected full-field OCT and consequences for two-photon microscopy.
    
    %Scattering coefficient % Optical properties of biological tissues: a review (Steven L Jacques) %cm-1
    musP = (40.8 * (Lambdas/500).^(-3.089));
    mus_GM  = 0.1*(musP/(1-g_GM)); %Convert in mm-1

    %Absorption coefficient (in mm-1) (Zerors: White Monte Carlo)
    mua_GM = zeros(size(mus_GM)); %White Monte Carlo
        
    
    %%-----------------------------------------------------------------
    %% Compute optical properties Large Blood vessels (LBV)
    %%-----------------------------------------------------------------
    
    % Anisoptropy coeff
    g_LBV    = 0.935; % Ref: Optical properties of human whole blood : changes due to slow heating
    % Refractive index
    n_LBV    = 1.4;  % Ref: Optical properties of human whole blood : changes due to slow heating
    
    %Scattering coefficient % Optical properties of biological tissues: a review (Steven L Jacques) %cm-1
    musP = (22 * (Lambdas/500).^(-0.66));
    mus_LBV  = 0.1*(musP / (1-g_LBV)); %Convert in mm-1
    
    %Absorption coefficient (in mm-1) (Zerors: White Monte Carlo)
    mua_LBV = zeros(size(mus_LBV)); %White Monte Carlo
    
    
    %%-----------------------------------------------------------------
    %% Compute optical properties Capillaries (Cap)
    %%-----------------------------------------------------------------
    
    % Anisoptropy coeff: 
    g_Cap  = g_GM;
    % Refractive index
    n_Cap = n_GM;
    %Scattering coefficient
    mus_Cap = mus_GM;
    %Absorption coefficient (in mm-1) (Zeros: White Monte Carlo)
    mua_Cap = zeros(size(mus_Cap)); %White Monte Carlo
    
    
    %%-----------------------------------------------------------------
    %% Compute optical properties Activated grey matter (act_GM)
    %%-----------------------------------------------------------------
    
    % Anisoptropy coeff: 
    g_act_GM  = g_GM;
    % Refractive index
    n_act_GM = n_GM;
    %Scattering coefficient
    mus_act_GM = mus_GM;
    %Absorption coefficient (in mm-1) (Zeros: White Monte Carlo)
    mua_act_GM = zeros(size(mus_act_GM)); %White Monte Carlo
    
    
    %%-----------------------------------------------------------------
    %% Compute optical properties Activated large blood vessels (act_LBV)
    %%-----------------------------------------------------------------
    
    % Anisoptropy coeff
    g_act_LBV = g_LBV;
    % Refractive index
    n_act_LBV = n_LBV;
    %Scattering coefficient
    mus_act_LBV = mus_LBV;
    %Absorption coefficient (in mm-1) (Zeros: White Monte Carlo)
    mua_act_LBV = zeros(size(mus_act_LBV)); %White Monte Carlo
    
    
    %%-----------------------------------------------------------------
    %% Compute optical properties Activated Capillaries (act_Cap)
    %%-----------------------------------------------------------------
    
    % Anisoptropy coeff: 
    g_act_Cap = g_Cap;
    % Refractive index
    n_act_Cap = n_Cap;
    %Scattering coefficient
    mus_act_Cap = mus_Cap;
    %Absorption coefficient (in mm-1) (Zeros: White Monte Carlo)
    mua_act_Cap = zeros(size(mus_act_Cap)); %White Monte Carlo
    
    
    clear musP
    
    

    
    
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
    cfg.prop=[0 0 1 1; ...
    mua_GM         mus_GM         g_GM       n_GM ; ...
    mua_LBV        mus_LBV        g_LBV      n_LBV ; ...
    mua_Cap        mus_Cap        g_Cap      n_Cap ; ...
    mua_act_GM     mus_act_GM     g_act_GM   n_act_GM ; ...
    mua_act_LBV    mus_act_LBV    g_act_LBV  n_act_LBV ; ...
    mua_act_Cap    mus_act_Cap    g_act_Cap  n_act_Cap];

    
    % calculate the fluence and partial path lengths
    [flux,output_det]=mcxlab(cfg); 
    
    
    
     
end