function [mp] = average_path_length(ppl,detw,unitinmm)

%   Compute mean path length for detected photons
%   Input
%   ppl: partial path length measured for a detector size(X,N-1) with W the
%   number of photons detected and N the number of tissue type (air, N-1).
%
%   detw: weight of the detector
%   unitinmm: size of the pixel in mm
    

    mp=sum(sum(ppl.*unitinmm.*repmat(detw(:),1,size(ppl,2))) / sum(detw(:)));


end