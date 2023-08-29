function [mu_a] = get_mua_values(lambda,C_Hb,C_HbO2,W,F,C_oxCCO,C_redCCO)
% OUTPUTS: 
% mu_a = Absorption coefficient of the tissue [mm^-1];
% INPUTS: 
% lambda = Wavelength of light [nm];
% C_Hb: Concentration of Hb [mol.L-1]
% C_HbO2: Concentration of Hb [mol.L-1]
% W = Water content in the tissue;
% F = Fat content in the tissue;
% C_oxCCO = Concentration of oxidized cytochrome c-oxidase (oxCCO) in the tissue [mol.L-1];
% C_redCCO = Concentration of reduced cytochrome c-oxidase (redCCO) in the tissue [mol.L-1];

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
hemo    = load('hemoglobine.mat'); %http://omlc.org/spectra/hemoglobin/summary.html
[xData, yData] = prepareCurveData( hemo.lambda,hemo.eps_hb);
ft = 'linearinterp';
[fitresult, gof] = fit( xData, yData, ft, 'Normalize', 'on' );
eps_hb=feval(fitresult,lambda);%cm^-1/(mol.l^-1)


[xData, yData] = prepareCurveData( hemo.lambda,hemo.eps_hb02);
ft = 'linearinterp';
[fitresult, gof] = fit( xData, yData, ft, 'Normalize', 'on' );
eps_hb02=feval(fitresult,lambda);%cm^-1/(mol.l^-1)


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
mu_a = W*mu_a_H2O + ...
F*mu_a_fat + ...
log(10)*C_Hb*eps_hb + ...
log(10)*C_HbO2*eps_hb02 + ...
log(10)*C_oxCCO*eps_oxCCO + ...
log(10)*C_redCCO*eps_redCCO; % Absorption coefficient of the tissue [cm^-1];

mu_a = 0.1*mu_a; % convert into mm-1

end