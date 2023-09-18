function [dref] = mcxcwdref(detweight, nphoton,unitinmm,binning)

% function [dref] = mcxcwdref(detp, cfg)
%
%  [dref] = mcxcwdref(detp, cfg)
%
%  Compute CW diffuse reflectance from MC detected photon profiles
% 
%  author: Shijie Yan (yan.shiji <at> northeastern.edu)
%
%  input:
%    detp: profiles of detected photons
%    cfg:  a struct, or struct array. Each element of cfg defines 
%         the parameters associated with a MC simulation.
%
%  output:
%    dref: CW diffuse reflectance at detectors
%
%    this file is part of Monte Carlo eXtreme (MCX)
%    License: GPLv3, see http://mcx.sf.net for details
%    see Yao2018
%


    % detweight = mcxdetweight(detp, cfg.prop);
    % detnum = length(unique(detp.detid));
    % detweightsum = zeros(detnum, 1);
    
    % for i = 1 : length(detp.detid)
    %     detweightsum(detp.detid(i)) = detweightsum(detp.detid(i)) + detweight(i);
    % end
    % 
    % area = pi * (cfg.detpos(:,4)*unitinmm).^2;
    % dref = detweightsum ./ area / cfg.nphoton; % Eq.12 of photon replay paper[Yao2018]

    detweightsum = sum(detweight); % Use scalar since the fonction is computed for each pixel
    area = (binning*unitinmm).^2; % 1 pixel per detector
    dref = detweightsum ./ area / nphoton; % Eq.12 of photon replay paper[Yao2018] https://doi.org/10.1364/BOE.9.004588
    
end