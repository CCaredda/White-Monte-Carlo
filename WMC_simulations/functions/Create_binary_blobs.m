function [binary_vol_in] = Create_binary_blobs(binary_vol_in,start_z)

    id = 1;
    for i=start_z:size(binary_vol_in,3)

        % SE = strel("disk",id);
        % binary_vol_in(:,:,i)=imerode(binary_vol_in(:,:,i),SE);
        binary_vol_in(:,:,i)=bwmorph(binary_vol_in(:,:,i),'erode',id);
        id = id+1;
    end

end