function [mu_s] = get_mus_values(lambda,g,a,b)

% Calculation of the scattering coefficient of the tissue:
mu_s_reduced=a*((lambda./500).^(-b)); % Reduced scattering coefficient of the tissue [cm^-1];
mu_s=mu_s_reduced./(1-g); % Scattering coefficient of the tissue [cm^-1];

end