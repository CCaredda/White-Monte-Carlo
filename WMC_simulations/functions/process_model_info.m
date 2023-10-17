function [info_model] = process_model_info(nb_photons,nb_repeat,in_img_path,model_resolution_in_mm)

    % Number of photons
    cfg.nphoton=nb_photons; 

    % Repeat the simulation x times
    cfg.respin=nb_repeat;

    % Maximum number of photons that can be detected 
    cfg.maxdetphoton = 1e6;
    
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
    
    disp('Get segmentation');

    %Load image and segmentation
    [img,resolution_xyz] = Load_img_segmentation(in_img_path,model_resolution_in_mm);

    % img.activated_large_vessels = zeros(size(img.activated_large_vessels)); 
    % img.activated_grey_matter = zeros(size(img.activated_large_vessels)); 
    % img.activated_capillaries = zeros(size(img.activated_large_vessels)); 

    % Voxel size in mm
    cfg.unitinmm = resolution_xyz; % Units in mm
    
    disp('Create volume');
    % Create volume
    % 1: Grey matter
    % 2: Large blood vessel
    % 3: Capillaries
    % 4: Activated grey matter
    % 5: Activated large vessel
    % 6: Activated capillaries
    cfg.vol = create_volume(img,resolution_xyz,cfg.issaveref);
    
    clear img;
    
    
    %%-----------------------------------------------------------------
    %% Generate wide-field detector
    %%-----------------------------------------------------------------
    disp('Create detector');
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
        cfg.savedetflag = 'spxv';
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
    disp('Create light source');
    % a uniform planar source outside the volume
    %Source type (homogeneous) a 3D quadrilateral uniform planar source, with three corners specified by srcpos, srcpos+srcparam1(1:3) and srcpos+srcparam2(1:3)
    cfg.srctype='planar';
    cfg.srcpos=[0 0 0];
    cfg.srcparam1=[size(cfg.vol,1) 0 0 0];
    cfg.srcparam2=[0 size(cfg.vol,2) 0 0];
    cfg.issrcfrom0=1;
    cfg.srcdir=[0 0 1];


    %%-----------------------------------------------------------------
    %% Store model parameters
    %%-----------------------------------------------------------------
    
    %Store info into structure
    info_model.cfg = cfg;
    info_model.resolution_xyz = resolution_xyz;


end