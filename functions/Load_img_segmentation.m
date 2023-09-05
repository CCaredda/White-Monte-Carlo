function [mask_segmentation,resolution_xyz] = Load_img_segmentation(path)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here


    %Resolution in x,y and z axes
     if ~ isfile(strcat(path,'resolution.txt'))
         display 'resolution.txt is missing';
         exit
     end
    
     resolution_xyz = dlmread(strcat(path,'resolution.txt')); %20 pixels = 2mm (must be changed according to the image)



    

    if ~ isfile(strcat(path,'mask_segmentation.png'))
         display 'mask_segmentation.png is missing';
         exit
    end

    mask_segmentation = imread(strcat(path,'mask_segmentation.png'));

end