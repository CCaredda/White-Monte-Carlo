function [optical_prop] = process_optical_properties(Lambdas)
    %Compute optical properties for the different classes
    %INPUT:
    %Lambda: wavelength (nm)
    %Output:
    %optical_prop: vector of optical properties size(length(Lambdas),7,4))

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

    %% Create output
    optical_prop = zeros(length(Lambdas),7,4);
    for l=1:length(Lambdas)
        %Air
        optical_prop(l,1,:) = [0 0 1 1];
        %Grey matter
        optical_prop(l,2,:) = [mua_GM(l) mus_GM(l) g_GM n_GM];
        %Large blood vessels
        optical_prop(l,3,:) = [mua_LBV(l) mus_LBV(l) g_LBV n_LBV];
        %Capillaries
        optical_prop(l,4,:) = [mua_Cap(l) mus_Cap(l) g_Cap n_Cap];
        %Activated grey matter
        optical_prop(l,5,:) = [mua_act_GM(l) mus_act_GM(l) g_act_GM n_act_GM];
        %Activated Large blood vessels
        optical_prop(l,6,:) = [mua_act_LBV(l) mus_act_LBV(l) g_act_LBV n_act_LBV];
        %Activated Capillaries
        optical_prop(l,7,:) = [mua_act_Cap(l) mus_act_Cap(l) g_act_Cap n_act_Cap];

    end  
    
end