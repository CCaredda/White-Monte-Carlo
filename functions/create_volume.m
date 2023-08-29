function [vol] = create_volume(img,resolution_xyz,save_diffuse_reflectance)

    %Add grey matter around
    img2 = zeros(size(img,1)+round(size(img,1)/8),size(img,2)+round(size(img,2)/8));
    img2(round(size(img,1)/16):size(img,1)+round(size(img,1)/16)-1,round(size(img,2)/16):size(img,2)+round(size(img,2)/16)-1) = img;


    z = round(20/resolution_xyz); %20 mm 
    % z = 32;
    % Expand the 2D binary mask of the surface of the exposed cortex along z direction to get a 3D volume:
    vol=repmat(img2,1,1,z); % Expand the 2D binary mask along z direction;
    

    if save_diffuse_reflectance == 1
        % Refine the 3D volume by eroding the vasculature structure along z;   
        id = 1;
        for i=2:size(vol,3)
            vol(:,:,i)=bwmorph(vol(:,:,i),'erode',id);
            id = id + 1;
        end
        % vol Add 1 to match brain tissue id with 1 and blood vessel with 2
        vol = vol+1;
        % pad a layer of 0s to get diffuse reflectance
        vol(:,:,1)=0;   

    else
        % Refine the 3D volume by eroding the vasculature structure along z;   
        for i=1:size(vol,3)
            vol(:,:,i)=bwmorph(vol(:,:,i),'erode',i);
        end
    
        % vol Add 1 to match brain tissue id with 1 and blood vessel with 2
        vol = vol+1;
    end

    %convert into uint8
    vol = uint8(vol);

    % figure; imagesc(squeeze(vol(:,200,:))), set(gca,'dataAspectRatio',[1 1 1])

end