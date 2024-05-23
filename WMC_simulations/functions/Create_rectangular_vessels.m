function [binary_vol_in] = Create_rectangular_vessels(binary_vol_in)

    %change this function
    blood_vessel_section = squeeze(binary_vol_in(floor(size(binary_vol_in,1)/2),:,1));

    vessel_diameter = sum(blood_vessel_section>0);


    binary_vol_in(:,:,vessel_diameter+1:end) = 0;

end