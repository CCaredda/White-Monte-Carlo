function [out_vol] = create_volume(img,resolution_xyz,save_diffuse_reflectance)


    z = round(20/resolution_xyz); %20 mm 


    % 1: Grey matter
    % 2: Large blood vessel
    % 3: Capillaries
    % 4: Activated grey matter
    % 5: Activated large vessel
    % 6: Activated capillaries
    out_vol = ones(size(img.large_vessels,1)+round(size(img.large_vessels,1)/8),size(img.large_vessels,2)+round(size(img.large_vessels,2)/8),z);

    % z start id for erosion
    start_z = 2;
    
    if save_diffuse_reflectance == 1
        out_vol(:,:,1) = 0;
        start_z = 3;
    end

    % 2: Large blood vessel
    if(sum(img.large_vessels(:))>0)
        img_temp = zeros(size(out_vol,1),size(out_vol,2));
        img_temp(round(size(img.large_vessels,1)/16):size(img.large_vessels,1)+round(size(img.large_vessels,1)/16)-1,round(size(img.large_vessels,2)/16):size(img.large_vessels,2)+round(size(img.large_vessels,2)/16)-1) = img.large_vessels;
        vol_temp=repmat(img_temp,1,1,z); 
        vol_temp = Create_binary_blobs(vol_temp,start_z);
        
        out_vol(vol_temp == 1) = 2;

    end

    % 3: Capilaries
    if(sum(img.capillaries(:))>0)
        img_temp = zeros(size(out_vol,1),size(out_vol,2));
        img_temp(round(size(img.large_vessels,1)/16):size(img.large_vessels,1)+round(size(img.large_vessels,1)/16)-1,round(size(img.large_vessels,2)/16):size(img.large_vessels,2)+round(size(img.large_vessels,2)/16)-1) = img.capillaries;
        vol_temp=repmat(img_temp,1,1,z); 
        vol_temp = Create_binary_blobs(vol_temp,start_z);

        out_vol(vol_temp == 1) = 3;
    end

    % 4: Activated grey matter
    if(sum(img.activated_grey_matter(:))>0)
        img_temp = zeros(size(out_vol,1),size(out_vol,2));
        img_temp(round(size(img.large_vessels,1)/16):size(img.large_vessels,1)+round(size(img.large_vessels,1)/16)-1,round(size(img.large_vessels,2)/16):size(img.large_vessels,2)+round(size(img.large_vessels,2)/16)-1) = img.activated_grey_matter;
        vol_temp=repmat(img_temp,1,1,z); 
        vol_temp = Create_binary_blobs(vol_temp,start_z);

        out_vol(vol_temp == 1) = 4;
    end

    % 5: Activated large vessel
    if(sum(img.activated_large_vessels(:))>0)
        img_temp = zeros(size(out_vol,1),size(out_vol,2));
        img_temp(round(size(img.large_vessels,1)/16):size(img.large_vessels,1)+round(size(img.large_vessels,1)/16)-1,round(size(img.large_vessels,2)/16):size(img.large_vessels,2)+round(size(img.large_vessels,2)/16)-1) = img.activated_large_vessels;
        vol_temp=repmat(img_temp,1,1,z); 
        vol_temp = Create_binary_blobs(vol_temp,start_z);

        out_vol(vol_temp == 1) = 5;
    end

    % 6: Activated large vessel
    if(sum(img.activated_capillaries(:))>0)
        img_temp = zeros(size(out_vol,1),size(out_vol,2));
        img_temp(round(size(img.large_vessels,1)/16):size(img.large_vessels,1)+round(size(img.large_vessels,1)/16)-1,round(size(img.large_vessels,2)/16):size(img.large_vessels,2)+round(size(img.large_vessels,2)/16)-1) = img.activated_capillaries;
        vol_temp=repmat(img_temp,1,1,z); 
        vol_temp = Create_binary_blobs(vol_temp,start_z);

        out_vol(vol_temp == 1) = 6;
    end

    out_vol = uint8(out_vol);

    clear img_temp vol_temp;


    % figure; imagesc(squeeze(out_vol(:,200,:))), set(gca,'dataAspectRatio',[1 1 1])

end