clear all; clc;
%%Load the data, restrict as per lesson
cd('C:\BIOL680\Data\R016-2012-10-03');
csc = myLoadCSC('R016-2012-10-03-CSC04a.Ncs');
cscRiskOnly = Restrict(csc,2700,3300);
Fs = 500;
cscRiskOnlyd = decimate(Data(cscRiskOnly),4);

%%Filter the data for signals of interest
%Gamma band (~45-65Hz)
lowGammaR = [45 65];
pbGamma = lowGammaR * 2 / Fs;
sbGamma = (lowGammaR + [-2 2]) * 2 / Fs;
[Ng,WnG] = cheb1ord(pbGamma, sbGamma, 3, 20); 
[bGamma,aGamma] = cheby1(Ng,0.5,WnG);
dataGamma = filtfilt(bGamma,aGamma,cscRiskOnlyd);

%Delta band (3-4Hz)
deltaR = [3 4];
pbDelta = deltaR * 2 / Fs;
sbDelta = (deltaR + [-2 2]) * 2 / Fs;
[Nd,WnD] = cheb1ord( pbDelta, sbDelta, 3, 20); 
[bDelta,aDelta] = cheby1(Nd,0.5,WnD);
dataDelta = filtfilt(bDelta,aDelta,cscRiskOnlyd);

%%Start processing
%gPhase = angle(hilbert(dataGamma));
gPower = abs(hilbert(dataGamma));
dPhase = angle(hilbert(dataDelta));
%dPower = abs(hilbert(dataDelta));

phi_edges = -pi:pi/8:pi;
phi_centers = phi_edges(1:end-1)+pi/16; % convert edges to centers
[meanPower, sdPower, binCnt] = averageXbyYbin(gPower,dPhase,phi_edges);
meanPower(end-1) = meanPower(end-1)+meanPower(end);
meanPower = meanPower(1:end-1);
sdPower(end-1) = sdPower(end-1)+sdPower(end);
sdPower = sdPower(1:end-1);
binCnt(end-1) = binCnt(end-1)+binCnt(end);
binCnt = binCnt(1:end-1);


CIUpper_95 = meanPower + ((sdPower./sqrt(binCnt))*1.96);
CILower_95 = meanPower - ((sdPower./sqrt(binCnt))*1.96);
CIUpper_99 = meanPower + ((sdPower./sqrt(binCnt))*2.58);
CILower_99 = meanPower - ((sdPower./sqrt(binCnt))*2.58);

plot(phi_centers,meanPower,'color',[0 0 0],'linewidth',1.5);
hold on;
plot(phi_centers,CIUpper_95,'color',[0.5 0.5 0.5],'linewidth',1.0,'linestyle','--');
plot(phi_centers,CIUpper_99,'color',[0.5 0.5 0.5],'linewidth',1.0,'linestyle',':');
legend('Mean','95% CI','99% CI');
plot(phi_centers,CILower_99,'color',[0.5 0.5 0.5],'linewidth',1.0,'linestyle',':');
plot(phi_centers,CILower_95,'color',[0.5 0.5 0.5],'linewidth',1.0,'linestyle','--');
hold off;
xlabel('Delta Phase','fontname','Calibri','fontsize',18);
ylabel('Mean Gamma Power','fontname','Calibri','fontsize',18);
title('Power/Amplitude Function','fontname','Calibri','fontsize',20);

%errorbar(phi_centers,meanPower,(sdPower./sqrt(binPower)));
