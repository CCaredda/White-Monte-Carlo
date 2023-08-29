%% TISSUE OPTICAL PROPERTIES CALCULATOR:
% Author: Luca Giannoni, C. Caredda
% Version: 6
% Date of the current version: 2nd May 2019
% Biomedical Optics Research Laboratory (BORL),
% Department of Medical Physics and Biomedical Engineering,
% University College London (UCL), London, UK

function [mu_s,mu_a] = get_mua_mus_values(lambda,g,a,b,Hb,B,S,W,F,C_oxCCO,C_redCCO)

% DESCRIPTION: The following function calculates the optical scattering and the total absorption coefficients of a
% specific biological tissue, given the inputs related to such tissue and to the selected wavelenght of light. The
% equations used in the function are mostly based on the following paper: Steven L. Jacques, "Optical properties of
% biological tissues: a review", Phys. Med. Biol. 58 (2013), pp. 37-61.
% OUTPUTS: 
% 1) mu_s = Scattering coefficient of the tissue [cm^-1];
% 2) mu_a = Absorption coefficient of the tissue [cm^-1];
% INPUTS: 
% 1) lambda = Wavelength of light [nm];
% 2) g = Anisotropy;
% 3) a = Tissue-dependent scaling factor for the scattering coefficient equation [cm^-1];
% 4) b = Tissue-dependent scattering power for the scattering coefficient equation;
% 5) Hb = Hemoglobin molar concentration in the blood of the tissue [M];
% 6) B = Blood volume fraction in the tissue;
% 7) S = Oxygen saturation in the blood of the tissue;
% 8) W = Water content in the tissue;
% 9) F = Fat content in the tissue;
% 10) C_oxCCO = Concentration of oxidized cytochrome c-oxidase (oxCCO) in the tissue [uM];
% 11) C_redCCO = Concentration of reduced cytochrome c-oxidase (redCCO) in the tissue [uM];

%% Calculation of the scattering coefficient of the tissue:
mu_s_reduced=a*((lambda./500).^(-b)); % Reduced scattering coefficient of the tissue [cm^-1];
mu_s=mu_s_reduced./(1-g); % Scattering coefficient of the tissue [cm^-1];

%% Calculation of the total absorption coefficient of the tissue:


%% Read the extinction coefficients [cm^-1] of water from external file:
filename='Extinction coeff water.txt'; % Name of the text file containing the extinction coefficients of water;
mu_a_H2O=dlmread(filename,'\t',2,0); % Read the file containing the extinction coefficients of water into a matrix;
mu_a_H2O(:,2)=log(10)*mu_a_H2O(:,2); % Conversion of the the extinction coefficients of water into absorption coefficients;

%interpolate mua values to the given Lambda range
[xData, yData] = prepareCurveData(mu_a_H2O(:,1),mu_a_H2O(:,2));
ft = 'linearinterp';
[fitresult, gof] = fit( xData, yData, ft, 'Normalize', 'on' );
mu_a_H2O=feval(fitresult,lambda);%cm-1


%% Read the absorption coefficients [cm^-1] of fat from external file:
filename='Absorption coeff fat.txt'; % Name of the text file containing the absorption coefficients of fat [m^-1];
mu_a_fat=dlmread(filename,'\t',2,0); % Read the file containing the absorption coefficients of fat [m^-1] into a matrix;
mu_a_fat(:,2)=mu_a_fat(:,2)./100; % Unit conversion of the matrix of absorption coefficients of fat, from [m^-1] to [cm^-1];

%interpolate mua values to the given Lambda range
[xData, yData] = prepareCurveData(mu_a_fat(:,1),mu_a_fat(:,2));
ft = 'linearinterp';
[fitresult, gof] = fit( xData, yData, ft, 'Normalize', 'on' );
mu_a_fat=feval(fitresult,lambda);%cm-1


%% Read the molar absorption coefficients [uM^-1*mm^-1] of HbO2 and HHb from external file:
filename='Molar absorption coeff HbO2.txt'; % Name of the text file containing the molar absorption coefficients of HbO2;
abs_HbO2=dlmread(filename,'\t',2,0); % Read the file containing the molar absorption coefficients of HbO2 into a matrix;
abs_HbO2(:,2)=abs_HbO2(:,2)./1E-7; % Unit conversion of the molar absorption coefficients of HbO2, from [uM^-1*mm^-1] to [M^-1*cm^-1];
filename='Molar absorption coeff HHb.txt'; % Name of the text file containing the molar absorption coefficients of HHb;
abs_HHb=dlmread(filename,'\t',2,0); % Read the file containing the molar absorption coefficients of HHb into a matrix;
abs_HHb(:,2)=abs_HHb(:,2)./1E-7; % Unit conversion of the molar absorption coefficients of HHb, from [uM^-1*mm^-1] to [M^-1*cm^-1];

%interpolate mua values to the given Lambda range
[xData, yData] = prepareCurveData(abs_HbO2(:,1),abs_HbO2(:,2));
ft = 'linearinterp';
[fitresult, gof] = fit( xData, yData, ft, 'Normalize', 'on' );
mu_a_HbO2=feval(fitresult,lambda);%cm-1


[xData, yData] = prepareCurveData(abs_HHb(:,1),abs_HHb(:,2));
ft = 'linearinterp';
[fitresult, gof] = fit( xData, yData, ft, 'Normalize', 'on' );
mu_a_HHb=feval(fitresult,lambda);%cm-1

%% Read the molar extinction coefficients [mM^-1*cm^-1] of oxidized and reduced CCO from external file:
filename='Molar extinction coeff oxCCO.txt'; % Name of the text file containing the molar extinction coefficients of oxidized CCO;
eps_oxCCO=dlmread(filename,'\t',2,0); % Read the file containing the molar extinction coefficients of oxidized CCO into a matrix;
eps_oxCCO(:,2)=eps_oxCCO(:,2)./1000; % Unit conversion of the molar absorption coefficients of oxidized CCO, from [mM^-1*cm^-1] in [uM^-1*cm^-1];
filename='Molar extinction coeff redCCO.txt'; % Name of the text file containing the molar extinction coefficients of reduced CCO;
eps_redCCO=dlmread(filename,'\t',2,0); % Read the file containing the molar extinction coefficients of reduced CCO into a matrix;
eps_redCCO(:,2)=eps_redCCO(:,2)./1000; % Unit conversion of the molar absorption coefficients of reduced CCO, from [mM^-1*cm^-1] in [uM^-1*cm^-1];


%interpolate mua values to the given Lambda range
[xData, yData] = prepareCurveData(eps_oxCCO(:,1),eps_oxCCO(:,2));
ft = 'linearinterp';
[fitresult, gof] = fit( xData, yData, ft, 'Normalize', 'on' );
eps_oxCCO=feval(fitresult,lambda);%cm-1

[xData, yData] = prepareCurveData(eps_redCCO(:,1),eps_redCCO(:,2));
ft = 'linearinterp';
[fitresult, gof] = fit( xData, yData, ft, 'Normalize', 'on' );
eps_redCCO=feval(fitresult,lambda);%cm-1


%% Calculate the absorption coefficient [cm^-1] of the tissue for the given wavelength:
mu_a=Hb*B*S*mu_a_HbO2+Hb*B*(1-S)*mu_a_HHb+W*mu_a_H2O+F*mu_a_fat+log(10)*C_oxCCO*eps_oxCCO+log(10)*C_redCCO*eps_redCCO; % Absorption coefficient of the tissue [cm^-1];

end % [END OF FUNCTION]