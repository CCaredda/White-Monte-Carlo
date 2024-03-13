function [mask_segmentation,resolution_xyz] = Load_img_segmentation(path,division_factor)
%Load image segmentation and pixel resolution
%Input:
%path: img path
%division_factor: change the resolution (increase the resolution, decrease
%the pixel size)


    %Resolution in x,y and z axes
    if ~ isfile(strcat(path,'resolution.txt'))
        disp('resolution.txt is missing');
        exit
    end
    
     % Load resolution
     resolution_xyz = dlmread(strcat(path,'resolution.txt')); 
     
     

    if ~ isfile(strcat(path,'mask_large_vessels.png'))
         disp('mask_large_vessels.png is missing');
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


    % Change the resolution
    if division_factor ~= 1
        resolution_xyz = resolution_xyz/division_factor;

        rows = size(mask_segmentation.large_vessels,1)*division_factor;
        cols = size(mask_segmentation.large_vessels,2)*division_factor;

        % Resize segmentation masks
        mask_segmentation.large_vessels = imresize(mask_segmentation.large_vessels,[rows,cols]);
        mask_segmentation.activated_large_vessels = imresize(mask_segmentation.activated_large_vessels,[rows,cols]);
        mask_segmentation.grey_matter = imresize(mask_segmentation.grey_matter,[rows,cols]);
        mask_segmentation.activated_grey_matter = imresize(mask_segmentation.activated_grey_matter,[rows,cols]);
        mask_segmentation.capillaries = imresize(mask_segmentation.capillaries,[rows,cols]);
        mask_segmentation.activated_capillaries = imresize(mask_segmentation.activated_capillaries,[rows,cols]);

    end
end