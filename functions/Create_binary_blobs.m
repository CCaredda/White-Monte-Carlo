function [binary_vol_in] = Create_binary_blobs(binary_vol_in,start_z)

    for i=start_z:size(binary_vol_in,3)
            binary_vol_in(:,:,i)=bwmorph(binary_vol_in(:,:,i),'erode',i);
    end

end