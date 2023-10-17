%% Compute optical changes
clear
path = '';

Nb_paradigm_cycle = 3;

SatO2 = 0.75;
C_HbT = 87.1*1e-6;


%Load phase Oxy vs Deoxy
Phase_OD = dlmread('files/phase_O_D.txt');
[xData, yData] = prepareCurveData( Phase_OD(:,1),Phase_OD(:,2));
[fitresult, gof] = fit( xData, yData, 'linearinterp', 'Normalize', 'on' );



% Bold signal
Bold = dlmread('files/Bold_Signal.txt');

% Time vector of BOLD signal 
t_bold   = 0: 20/(length(Bold)-1) : 20 ;

%Frame rate
Fs = 10;

% Define new Bold signal
t_bold_interp = 0 : 1/Fs : 20;
bold_interp = spline(t_bold,Bold,t_bold_interp);

%H cytochrome
H_cyt = t_bold_interp.^2.*exp(-t_bold_interp);

% Define time and paradigm
t_paradigm = 0 : 1/Fs : (20*Nb_paradigm_cycle+10);
paradigm = zeros(size(t_paradigm));

%Frequencies
F = (0:length(t_paradigm)-1)*Fs/length(t_paradigm);


for i=1:Nb_paradigm_cycle
    id = floor((i-1)*10*Fs);
    paradigm(id+floor(10*i*Fs):id+floor(10*(i+1)*Fs)) = 1;
end



%Convolution
Bold_convolved = conv(paradigm,bold_interp);
Bold_convolved = Bold_convolved(1:length(paradigm));
Bold_convolved = Bold_convolved/max(Bold_convolved);
H_cyt_convolved = conv(paradigm,H_cyt);
H_cyt_convolved = H_cyt_convolved(1:length(paradigm));
H_cyt_convolved = H_cyt_convolved/max(H_cyt_convolved);


%Concentration changes due to cerebral activity
Activation_Delta_HbO2_response = 5e-6*Bold_convolved;
Activation_Delta_Hb_response = -3.75e-6*Bold_convolved;



%Heart pulsations
%[HbO2] = 10 x [Hb] (Wobst et al. Linear Aspects of Changes in Deoxygenated
%Hemoglobin Concentration and Cytochrome Oxidase Oxidation during Brain Activation)
% Amplitude HbO2 : approx 0.25 µMol/L (Wobst et al.)
% oxCCO : No cardiac frequencies observed on the spectra (Wobst et al.)
% Cardiac_HbO2 = sin(2*pi*t_paradigm)*0.25e-6;
% Cardiac_Hb = sin(2*pi*t_paradigm)*0.025e-6;

% Experimentaly measured (amplitude HbO2 : 1.35µMol/M, amplitude Hb : 0.51µMol/L 
Cardiac_HbO2 = sin(2*pi*t_paradigm)*(1.35/4)*1e-6;
Cardiac_Hb = sin(2*pi*t_paradigm - pi)*(0.51/4)*1e-6;


%respiratory oscillations
F_resp = 0.2;
Resp_HbO2 = sin(2*pi*F_resp*t_paradigm)*(1.35/2)*1e-6;
Resp_Hb = sin(2*pi*F_resp*t_paradigm - pi)*(0.51/2)*1e-6;









% Ref Fourier series :  Identifying the Default Mode Network Structure Using Dynamic Causal Modeling on Resting-state Functional Magnetic Resonance Imaging
% Amplitude rs HbO2/Hb: 4/1 (Mesquita)
% Amplitude rs HbO2/Hb: 0.1 (Use of fNIRS to assess resting state functional connectivity) 
% Amplitude rs HbO2/Hb: 1/0.5 (Near-infrared study of fluctuations in
% cerebral hemodynamics during rest and motor stimulation: temporal analysis and spatial mapping)




F_rs = [0.01 0.02 0.04 0.08];
% Phase_OD=deg2rad(feval(fitresult,F_rs));

Phase_OD=[pi pi pi pi];

rs_HbO2 = zeros(1,length(t_paradigm));
rs_Hb = zeros(1,length(t_paradigm));

for i=1:length(F_rs)
    a = 0;%-1;
    b = 1;
    C_cos = 1e-6*(a + (b-a).*rand()); %interval [a;b]
    C_sin = 1e-6*(a + (b-a).*rand());
    rs_HbO2 = rs_HbO2 + C_cos*cos(F_rs(i)*2*pi*t_paradigm) + C_sin*sin(F_rs(i)*2*pi*t_paradigm);
  
    a = 0;%-1;
    b = 0.5;
    C_cos = 1e-6*(a + (b-a).*rand()); %interval [a;b]
    C_sin = 1e-6*(a + (b-a).*rand());
    rs_Hb = rs_Hb + C_cos*cos(F_rs(i)*2*pi*t_paradigm - Phase_OD(i)) + C_sin*sin(F_rs(i)*2*pi*t_paradigm- Phase_OD(i)); 
end

% %HbO2
% a = 0;%-1;
% b = 1;
% C_cos = 1e-6*(a + (b-a).*rand(4,1)); %interval [a;b]
% C_sin = 1e-6*(a + (b-a).*rand(4,1));
% rs_HbO2 = C_cos(1)*cos(0.01*2*pi*t_paradigm) + C_sin(1)*sin(0.01*2*pi*t_paradigm) + ...
% C_cos(2)*cos(0.02*2*pi*t_paradigm) + C_sin(2)*sin(0.02*2*pi*t_paradigm) + ...
% C_cos(3)*cos(0.04*2*pi*t_paradigm) + C_sin(3)*sin(0.04*2*pi*t_paradigm) + ...
% C_cos(4)*cos(0.08*2*pi*t_paradigm) + C_sin(4)*sin(0.08*2*pi*t_paradigm);
% 
% %Hb
% a = 0;%-0.5;
% b = 0.5;
% C_cos = 1e-6*(a + (b-a).*rand(4,1)); %interval [a;b]
% C_sin = 1e-6*(a + (b-a).*rand(4,1));
% display(C_cos)
% display(C_sin)
% rs_Hb = C_cos(1)*cos(0.01*2*pi*t_paradigm -pi) + C_sin(1)*sin(0.01*2*pi*t_paradigm-pi) + ...
% C_cos(2)*cos(0.02*2*pi*t_paradigm-pi) + C_sin(2)*sin(0.02*2*pi*t_paradigm-pi) + ...
% C_cos(3)*cos(0.04*2*pi*t_paradigm-pi) + C_sin(3)*sin(0.04*2*pi*t_paradigm-pi) + ...
% C_cos(4)*cos(0.08*2*pi*t_paradigm-pi) + C_sin(4)*sin(0.08*2*pi*t_paradigm-pi);

% Response in grey matter
% Add heartbeat, respiratory and resting state oscillations to Hb and HbO2 responses
Delta_HbO2_response_activated_area = rs_HbO2 + Activation_Delta_HbO2_response + Cardiac_HbO2 + Resp_HbO2;
Delta_Hb_response_activated_area = rs_Hb + Activation_Delta_Hb_response + Cardiac_Hb + Resp_Hb;
Delta_oxCCO_response_activated_area = 0.5e-6*H_cyt_convolved;

Delta_HbO2_response_non_activated_area = rs_HbO2 + Cardiac_HbO2 + Resp_HbO2;
Delta_Hb_response_non_activated_area = rs_Hb + Cardiac_Hb + Resp_Hb;
Delta_oxCCO_response_non_activated_area = zeros(size(Delta_oxCCO_response_activated_area));


%Responses in large blood vessels
Delta_HbO2_response_LBV_activated_area = Activation_Delta_HbO2_response + Cardiac_HbO2 + Resp_HbO2;
Delta_Hb_response_LBV_activated_area = Activation_Delta_Hb_response + Cardiac_Hb + Resp_Hb;

Delta_HbO2_response_LBV_non_activated_area = Cardiac_HbO2 + Resp_HbO2;
Delta_Hb_response_LBV_non_activated_area = Cardiac_Hb + Resp_Hb;



%Absolute Concentration and proportion Non activated Grey matter
C_Hb_GM_non_act     = (1-SatO2)*C_HbT + Delta_Hb_response_non_activated_area;
C_HbO2_GM_non_act   = SatO2*C_HbT + Delta_HbO2_response_non_activated_area;
C_oxCCO_GM_non_act  = 5.3*1e-6 + Delta_oxCCO_response_non_activated_area;
C_redCCO_GM_non_act = zeros(size(C_Hb_GM_non_act));
prop_H2O_GM_non_act = 0.73*ones(size(C_Hb_GM_non_act));
prop_Fat_GM_non_act = 0.1*ones(size(C_Hb_GM_non_act));

%Absolute Concentration and proportion activated Grey matter
C_Hb_GM_act         = (1-SatO2)*C_HbT + Delta_Hb_response_activated_area;
C_HbO2_GM_act       = SatO2*C_HbT + Delta_HbO2_response_activated_area;
C_oxCCO_GM_act      = 5.3*1e-6 + Delta_oxCCO_response_activated_area;
C_redCCO_GM_act     = zeros(size(C_Hb_GM_non_act));
prop_H2O_GM_act     = prop_H2O_GM_non_act;
prop_Fat_GM_act     = prop_Fat_GM_non_act;


C_HbO2_LBV = 2375e-6;
C_Hb_LBV = 125e-6;
%Absolute Concentration and proportion Non activated Large blood vessels
C_Hb_LBV_non_act     = C_Hb_LBV + Delta_Hb_response_LBV_non_activated_area;
C_HbO2_LBV_non_act   = C_HbO2_LBV + Delta_HbO2_response_LBV_non_activated_area;
C_oxCCO_LBV_non_act  = zeros(size(C_Hb_GM_act));
C_redCCO_LBV_non_act = zeros(size(C_Hb_GM_act));
prop_H2O_LBV_non_act = zeros(size(C_Hb_GM_act));
prop_Fat_LBV_non_act = zeros(size(C_Hb_GM_act));

%Absolute Concentration and proportion activated Large blood vessels
C_Hb_LBV_act         = C_Hb_LBV + Delta_Hb_response_LBV_activated_area;
C_HbO2_LBV_act       = C_HbO2_LBV + Delta_HbO2_response_LBV_activated_area;
C_oxCCO_LBV_act      = zeros(size(C_Hb_GM_act));
C_redCCO_LBV_act     = zeros(size(C_Hb_GM_act));
prop_H2O_LBV_act     = zeros(size(C_Hb_GM_act));
prop_Fat_LBV_act     = zeros(size(C_Hb_GM_act));


%Absolute Concentration and proportion capillaries
% For now same properties as grey matter
C_Hb_cap_non_act     = C_Hb_GM_non_act;
C_HbO2_cap_non_act   = C_HbO2_GM_non_act;
C_oxCCO_cap_non_act  = C_oxCCO_GM_non_act;
C_redCCO_cap_non_act = C_redCCO_GM_non_act;
prop_H2O_cap_non_act = prop_H2O_GM_non_act;
prop_Fat_cap_non_act = prop_Fat_GM_non_act;

%Absolute Concentration and proportion activated capillaries
C_Hb_cap_act         = C_Hb_GM_act;
C_HbO2_cap_act       = C_HbO2_GM_act;
C_oxCCO_cap_act      = C_oxCCO_GM_act;
C_redCCO_cap_act     = C_redCCO_GM_act;
prop_H2O_cap_act     = prop_H2O_GM_act;
prop_Fat_cap_act     = prop_Fat_GM_act;



% % MG
% g_MG    = 0.85; % Anisoptropy coeff
% n_MG    = 1.36; % Refractive index

% %Scattering coefficient % Optical properties of biological tissues: a review (Steven L Jacques) %cm-1
% %musP_MG = (40.8 * (lambda/500).^(-3.089));
% musP_MG_non_activated = (24.2 * (lambda/500).^(-1.611));
% %convert into mm-1
% mus_MG_non_activated  = musP_MG_non_activated/(1-g_MG); 
% mus_MG_non_activated  = 0.1*mus_MG_non_activated;


% Delta_mus_activated = 0.004*H_cyt_convolved; %0.4 % Delta mus change (The fast optical signal—Robust or elusive when non-invasively measured in the human adult?)
% mus_MG_activated = zeros(length(t_paradigm),length(lambda));
% 
% for t=1:length(t_paradigm)
%     mus_MG_activated(t,:) =  mus_MG_non_activated*(1 + Delta_mus_activated(t));
% end







figure()
subplot(231)
hold on
title("Concentration changes due to cerebral activity")
plot(t_paradigm,paradigm*max(Activation_Delta_HbO2_response),'k')
plot(t_paradigm,Activation_Delta_HbO2_response,'r')
plot(t_paradigm,Activation_Delta_Hb_response,'b')
plot(t_paradigm,Activation_Delta_HbO2_response+Activation_Delta_Hb_response,'k')
plot(t_paradigm,Delta_oxCCO_response_activated_area,'g')

subplot(232)
title("Concentration changes in activated area")
hold on
plot(t_paradigm,paradigm*max(Activation_Delta_HbO2_response),'k')
plot(t_paradigm,Delta_HbO2_response_activated_area,'r')
plot(t_paradigm,Delta_Hb_response_activated_area,'b')
plot(t_paradigm,Delta_oxCCO_response_activated_area,'g')

subplot(233)
title("Hemodynamic spectra in activated area")
hold on
plot(F,abs(fft(Delta_HbO2_response_activated_area)),'r')
plot(F,abs(fft(Delta_Hb_response_activated_area)),'b')
xlim([0,3])

subplot(234)
title("Concentration changes resting state")
hold on
plot(t_paradigm,rs_HbO2,'r')
plot(t_paradigm,rs_Hb,'b')



subplot(235)
title("Concentration changes in non activated area")
hold on
plot(t_paradigm,Delta_HbO2_response_non_activated_area,'r')
plot(t_paradigm,Delta_Hb_response_non_activated_area,'b')
plot(t_paradigm,Delta_oxCCO_response_non_activated_area,'g')

subplot(236)
title("Hemodynamic spectra in non activated area")
hold on
plot(F,abs(fft(Delta_HbO2_response_non_activated_area)),'r')
plot(F,abs(fft(Delta_Hb_response_non_activated_area)),'b')
xlim([0,3])


figure()
subplot(321)
title('Activated GM')
hold on
plot(t_paradigm,C_HbO2_GM_act,'r')
plot(t_paradigm,C_Hb_GM_act,'b')
plot(t_paradigm,C_oxCCO_GM_act,'g')

subplot(322)
title('Non activated GM')
hold on
plot(t_paradigm,C_HbO2_GM_non_act,'r')
plot(t_paradigm,C_Hb_GM_non_act,'b')
plot(t_paradigm,C_oxCCO_GM_non_act,'g')

subplot(323)
title('Activated Large vessels')
hold on
plot(t_paradigm,C_HbO2_LBV_act,'r')
plot(t_paradigm,C_Hb_LBV_act,'b')
plot(t_paradigm,C_oxCCO_LBV_act,'g')

subplot(324)
title('Non activated Large vessels')
hold on
plot(t_paradigm,C_HbO2_LBV_non_act,'r')
plot(t_paradigm,C_Hb_LBV_non_act,'b')
plot(t_paradigm,C_oxCCO_LBV_non_act,'g')

subplot(325)
title('Activated capillaries')
hold on
plot(t_paradigm,C_HbO2_cap_act,'r')
plot(t_paradigm,C_Hb_cap_act,'b')
plot(t_paradigm,C_oxCCO_cap_act,'g')

subplot(326)
title('Non activated capillaries')
hold on
plot(t_paradigm,C_HbO2_cap_non_act,'r')
plot(t_paradigm,C_Hb_cap_non_act,'b')
plot(t_paradigm,C_oxCCO_cap_non_act,'g')


% figure()
% title("Scattering changes due to cerebral activity")
% hold on
% plot(t_paradigm,100*Delta_mus_activated)
% plot(t_paradigm,100*paradigm*max(Delta_mus_activated),'k')
% ylabel("Delta mus (%)")


% Write results


%activated capillaries
temp = zeros(6,length(t_paradigm));
temp(1,:) = prop_H2O_cap_act;
temp(2,:) = prop_Fat_cap_act;
temp(3,:) = C_HbO2_cap_act;
temp(4,:) = C_Hb_cap_act;
temp(5,:) = C_oxCCO_cap_act;
temp(6,:) = C_redCCO_cap_act;
writematrix(temp,'activated_capillaries.txt','Delimiter',' ');

%Non activated capillaries
temp = zeros(6,length(t_paradigm));
temp(1,:) = prop_H2O_cap_non_act;
temp(2,:) = prop_Fat_cap_non_act;
temp(3,:) = C_HbO2_cap_non_act;
temp(4,:) = C_Hb_cap_non_act;
temp(5,:) = C_oxCCO_cap_non_act;
temp(6,:) = C_redCCO_cap_non_act;
writematrix(temp,'capillaries.txt','Delimiter',' ');

%activated grey matter
temp = zeros(6,length(t_paradigm));
temp(1,:) = prop_H2O_GM_act;
temp(2,:) = prop_Fat_GM_act;
temp(3,:) = C_HbO2_GM_act;
temp(4,:) = C_Hb_GM_act;
temp(5,:) = C_oxCCO_GM_act;
temp(6,:) = C_redCCO_GM_act;
writematrix(temp,'activated_grey_matter.txt','Delimiter',' ');

%Non activated grey matter
temp = zeros(6,length(t_paradigm));
temp(1,:) = prop_H2O_GM_non_act;
temp(2,:) = prop_Fat_GM_non_act;
temp(3,:) = C_HbO2_GM_non_act;
temp(4,:) = C_Hb_GM_non_act;
temp(5,:) = C_oxCCO_GM_non_act;
temp(6,:) = C_redCCO_GM_non_act;
writematrix(temp,'grey_matter.txt','Delimiter',' ');

%activated large blood vessels
temp = zeros(6,length(t_paradigm));
temp(1,:) = prop_H2O_LBV_act;
temp(2,:) = prop_Fat_LBV_act;
temp(3,:) = C_HbO2_LBV_act;
temp(4,:) = C_Hb_LBV_act;
temp(5,:) = C_oxCCO_LBV_act;
temp(6,:) = C_redCCO_LBV_act;
writematrix(temp,'activated_large_blood_vessels.txt','Delimiter',' ');

%Non activated grey matter
temp = zeros(6,length(t_paradigm));
temp(1,:) = prop_H2O_LBV_non_act;
temp(2,:) = prop_Fat_LBV_non_act;
temp(3,:) = C_HbO2_LBV_non_act;
temp(4,:) = C_Hb_LBV_non_act;
temp(5,:) = C_oxCCO_LBV_non_act;
temp(6,:) = C_redCCO_LBV_non_act;
writematrix(temp,'large_blood_vessels.txt','Delimiter',' ');



         

