function [out_vol] = create_volume(img,resolution_xyz,save_diffuse_reflectance)



    % Create image of large blood vessel and add grey matter around
    img_large_vessel = zeros(size(img.large_vessels,1)+round(size(img.large_vessels,1)/8),size(img.large_vessels,2)+round(size(img.large_vessels,2)/8));
    img_large_vessel(round(size(img.large_vessels,1)/16):size(img.large_vessels,1)+round(size(img.large_vessels,1)/16)-1,round(size(img.large_vessels,2)/16):size(img.large_vessels,2)+round(size(img.large_vessels,2)/16)-1) = img.large_vessels;

    % Create image of activated large blood vessel
    img_act_large_vessel = zeros(size(img_large_vessel));
    img_act_large_vessel(round(size(img.large_vessels,1)/16):size(img.large_vessels,1)+round(size(img.large_vessels,1)/16)-1,round(size(img.large_vessels,2)/16):size(img.large_vessels,2)+round(size(img.large_vessels,2)/16)-1) = img.activated_large_vessels;

    % Create image of activated grey matter
    img_act_grey_matter = zeros(size(img_large_vessel));
    img_act_grey_matter(round(size(img.large_vessels,1)/16):size(img.large_vessels,1)+round(size(img.large_vessels,1)/16)-1,round(size(img.large_vessels,2)/16):size(img.large_vessels,2)+round(size(img.large_vessels,2)/16)-1) = img.activated_grey_matter;

    % Create image of capilalries
    img_capilaries = zeros(size(img_large_vessel));
    img_capilaries(round(size(img.large_vessels,1)/16):size(img.large_vessels,1)+round(size(img.large_vessels,1)/16)-1,round(size(img.large_vessels,2)/16):size(img.large_vessels,2)+round(size(img.large_vessels,2)/16)-1) = img.capillaries;

    % Create image of activated capilalries
    img_act_capilaries = zeros(size(img_large_vessel));
    img_act_capilaries(round(size(img.large_vessels,1)/16):size(img.large_vessels,1)+round(size(img.large_vessels,1)/16)-1,round(size(img.large_vessels,2)/16):size(img.large_vessels,2)+round(size(img.large_vessels,2)/16)-1) = img.activated_capillaries;


    z = round(20/resolution_xyz); %20 mm 

    % Expand the 2D binary mask of the surface of the exposed cortex along z direction to get a 3D volume:
    vol_large_vessel=repmat(img_large_vessel,1,1,z); 
    vol_act_large_vessel=repmat(img_act_large_vessel,1,1,z); 
    vol_capilaries=repmat(img_capilaries,1,1,z); 
    vol_act_capilaries=repmat(img_act_capilaries,1,1,z); 
    vol_act_grey_matter=repmat(img_act_grey_matter,1,1,z);

 
    % 1: Grey matter
    % 2: Large blood vessel
    % 3: Capillaries
    % 4: Activated grey matter
    % 5: Activated large vessel
    % 6: Activated capillaries
    out_vol = ones(size(vol_act_grey_matter));

    % z start id for erosion
    start_z = 2;
    
    if save_diffuse_reflectance == 1
        out_vol(:,:,1) = 0;
        start_z = 3;
    end

    % 2: Large blood vessel
    if(sum(vol_large_vessel(:))>0)
        vol_large_vessel = Create_binary_blobs(vol_large_vessel,start_z);
        out_vol(vol_large_vessel == 1) = 2;
    end

    % 3: Capilaries
    if(sum(vol_capilaries(:))>0)
        vol_capilaries = Create_binary_blobs(vol_capilaries,start_z);
        out_vol(vol_capilaries == 1) = 3;
    end

    % 4: Activated grey matter
    if(sum(vol_act_grey_matter(:))>0)
        vol_act_grey_matter = Create_binary_blobs(vol_act_grey_matter,start_z);
        out_vol(vol_act_grey_matter == 1) = 4;
    end

    % 5: Activated large vessel
    if(sum(vol_act_large_vessel(:))>0)
        vol_act_large_vessel = Create_binary_blobs(vol_act_large_vessel,start_z);
        out_vol(vol_act_large_vessel == 1) = 5;
    end

    % 6: Activated large vessel
    if(sum(vol_act_capilaries(:))>0)
        vol_act_capilaries = Create_binary_blobs(vol_act_capilaries,start_z);
        out_vol(vol_act_capilaries == 1) = 5;
    end

    out_vol = uint8(out_vol);


    % figure; imagesc(squeeze(out_vol(:,200,:))), set(gca,'dataAspectRatio',[1 1 1])

end