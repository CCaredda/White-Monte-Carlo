function [Intensity,Mean_path_length] = reconstruct_Image(output_det,nb_pixels_x,nb_pixels_y,nphotons,unitinmm,binning)
    % This function calculates 2D images from the detected photons info
    % obtained via the MMC simulation. It also 
    % calculates the average photon pathlength (PPL) hyperspectral maps of the 
    % detected photons in each pixel of the desired spectral images (as well as
    % a photon weights-corrected version of PPL).
    
    % % Inputs:
    % output_det: a structure that concatenated detector results [detid nscat ppath mom p v w0]
    % nb_pixels_x: number of pixels in x axis
    % nb_pixels_y: number of pixels in y axis

    % nb_pixel_x and nb_pixel_y are calculated with
    % the node of the mesh and the resolution_pixel parameters
    
    %unitinmm: size of the pixels
    %binning: binning to rectonstruct images
    
    % % Outputs:
    % Intensity: intensity image of detected exiting photons (size nb_pixel_x.nb_pixels_y), 
    % Mean_path_length: Image of mean path length of detected photons (in mm) (size nb_pixel_x.nb_pixels_y)


    % Load partial path length
    ppath = output_det.ppath;

    % Compute detector weights
    weights = mcxdetweight(output_det,output_det.prop,unitinmm);
    


    
    %Init outputs
    Intensity=zeros(nb_pixels_x,nb_pixels_y); % Preallocate output intensity image
    Mean_path_length=zeros(nb_pixels_x,nb_pixels_y); % Mean path length (in mm)

    % Position of photons in image
    row_id = ceil(output_det.p(:,1)/binning);
    col_id = ceil(output_det.p(:,2)/binning);
    index_photons = row_id + (col_id-1)*nb_pixels_x;

    % Loop over detectors
    parfor i=1:nb_pixels_x*nb_pixels_y

        %Select the packet of photons that reach the detector i
        id = find(index_photons==i);
        if isempty(id)
            Intensity(i) = 0;
            Mean_path_length(i) = 0;
        else
            %Compute intensity for pixel i
            Intensity(i) = mcxcwdref(weights(id),nphotons,unitinmm);

            %Avg pathlength summed for the media
            Mean_path_length(i) = average_path_length(ppath(id,:),weights(id),unitinmm);
        end
    end

