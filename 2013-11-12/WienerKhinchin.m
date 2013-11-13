%% Diversion: The Wiener-Khinchin theorem
%Demonstrates how changing the phase shift alters the autocorrelation

%Default Font Modding
set(0,'defaulttextfontname','MinionPro-regular'); 
set(0,'defaulttextfontsize',16);

%Basic signal characteristics
Fs = 500; dt = 1./Fs;
t = [0 2]; tvec = t(1):dt:t(2)-dt;

%Signal 1
f1 = 8;
data1 = sin(2*pi*f1*tvec)+0.1*randn(size(tvec));

%Start of signal 2. Each signal will be shifted by pi/x. The larger the
%phase shift, the lighter the line on the plot.
f2 = 8;
figure;
hold on;
phases = 32;
cs = 1.0 / phases;
for ps = 0:phases    
    if (ps == 0)
        data2 = data1;
    else
        data2 = sin(2*pi*f2*tvec+pi/ps)+0.1*randn(size(tvec)); % phase-shifted version of data1
    end
    [ccf,lags] = xcorr(data1,data2,100,'coeff'); % now a cross-correlation
    lags = lags.*(1./Fs); % convert samples to time
    if (ps == 0)
        plot(lags,ccf,'color',[0 0 0],'linewidth',2);
    else
        plot(lags,ccf,'color',[cs*abs(ps-phases) cs*abs(ps-phases) cs*abs(ps-phases)],'linestyle','--');
    end
end
set(gca,'ylim',[-1 1]);
title('Phase Shift Versus Autocorrelation','fontname','MinionPro-bold','fontsize',24);
ylabel('Correlation','fontname','MinionPro-regular','fontsize',18);
hold off;
grid on;