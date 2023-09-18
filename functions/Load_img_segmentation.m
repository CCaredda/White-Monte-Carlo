function [mask_segmentation,resolution_xyz] = Load_img_segmentation(path,output_resolution_in_mm)
%Load image segmentation and pixel resolution
%Input:
%path: img path
%output_resolution_in_mm: desired resolution in mm. If 0, use input image
%resolution


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
    if output_resolution_in_mm > 0 && output_resolution_in_mm>resolution_xyz && floor(output_resolution_in_mm/resolution_xyz)>1   

        disp('Resize segmentations');
        %compute new image size
        binning = floor(output_resolution_in_mm/resolution_xyz);

        rows = floor(size(mask_segmentation.large_vessels,1)/binning);
        cols = floor(size(mask_segmentation.large_vessels,2)/binning);

        resolution_xyz = binning*resolution_xyz;


        % Resize segmentation masks
        mask_segmentation.large_vessels = imresize(mask_segmentation.large_vessels,[rows,cols]);
        mask_segmentation.activated_large_vessels = imresize(mask_segmentation.activated_large_vessels,[rows,cols]);
        mask_segmentation.grey_matter = imresize(mask_segmentation.grey_matter,[rows,cols]);
        mask_segmentation.activated_grey_matter = imresize(mask_segmentation.activated_grey_matter,[rows,cols]);
        mask_segmentation.capillaries = imresize(mask_segmentation.capillaries,[rows,cols]);
        mask_segmentation.activated_capillaries = imresize(mask_segmentation.activated_capillaries,[rows,cols]);
    end


end