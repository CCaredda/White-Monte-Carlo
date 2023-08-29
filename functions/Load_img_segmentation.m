function [blood_vessel_mask,resolution_xyz] = Load_img_segmentation(path)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here


    %Resolution in x,y and z axes
     if ~ isfile(strcat(path,'resolution.txt'))
         display 'resolution.txt is missing';
         exit
     end
    
     resolution_xyz = dlmread(strcat(path,'resolution.txt')); %20 pixels = 2mm (must be changed according to the image)


    if ~ isfile(strcat(path,'blood_vessel_mask.png'))
         display 'blood_vessel_mask.png is missing';
         exit
    end

    blood_vessel_mask = imread(strcat(path,'blood_vessel_mask.png'));

end