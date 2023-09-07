function [mask_segmentation,resolution_xyz] = Load_img_segmentation(path)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here


    %Resolution in x,y and z axes
     if ~ isfile(strcat(path,'resolution.txt'))
         display 'resolution.txt is missing';
         exit
     end
    
     resolution_xyz = dlmread(strcat(path,'resolution.txt')); %20 pixels = 2mm (must be changed according to the image)


    if ~ isfile(strcat(path,'mask_large_vessels.png'))
         display 'mask_large_vessels.png is missing';
         exit
    end

    mask_segmentation.large_vessels = imread(strcat(path,'mask_large_vessels.png'));


    if isfile(strcat(path,'mask_activated_large_vessels.png'))
        mask_segmentation.activated_large_vessels = imread(strcat(path,'mask_activated_large_vessels.png'));
    else
        mask_segmentation.activated_large_vessels = zeros(size(mask_segmentation.large_vessels));
    end


    if isfile(strcat(path,'mask_grey_matter.png'))
        mask_segmentation.grey_matter = imread(strcat(path,'mask_grey_matter.png'));
    else
        mask_segmentation.grey_matter = zeros(size(mask_segmentation.large_vessels));
    end


    if isfile(strcat(path,'mask_activated_grey_matter.png'))
        mask_segmentation.activated_grey_matter = imread(strcat(path,'mask_activated_grey_matter.png'));
    else
        mask_segmentation.activated_grey_matter = zeros(size(mask_segmentation.large_vessels));
    end


    if isfile(strcat(path,'mask_capillaries.png'))
        mask_segmentation.capillaries = imread(strcat(path,'mask_capillaries.png'));
    else
        mask_segmentation.capillaries = zeros(size(mask_segmentation.large_vessels));
    end


    if isfile(strcat(path,'mask_activated_capillaries.png'))
        mask_segmentation.activated_capillaries = imread(strcat(path,'mask_activated_capillaries.png'));
    else
        mask_segmentation.activated_capillaries = zeros(size(mask_segmentation.large_vessels));
    end


end