%% Modified Example

Fs = 500; dt = 1./Fs;
t = [0 2]; tvec = t(1):dt:t(2)-dt;
f1 = 8;
data1 = sin(2*pi*f1*tvec)+0.1*randn(size(tvec));
f2 = 8;
data2 = 2*sin(2*pi*f2*tvec+pi/4)+0.1*randn(size(tvec));
%data2 = sin(2*pi*f1*tvec)+0.1*randn(size(tvec));

figure(1);clf;
subplot(221);
plot(tvec,data1,'r',tvec,data2,'b'); legend({'signal 1','signal 2'});
title('raw signals');
 
[Pxx,F] = pwelch(data1,hanning(250),125,length(data1),Fs);
[Pyy,F] = pwelch(data2,hanning(250),125,length(data1),Fs);
subplot(222)
plot(F,abs(Pxx),'r',F,abs(Pyy),'b'); xlim([0 100]);
xlabel('Frequency (Hz)'); ylabel('power'); title('PSD');
 
[Pxy,F] = cpsd(data1,data2,hanning(250),125,length(data1),Fs);
subplot(223)
C = (abs(Pxy).^2)./(Pxx.*Pyy);
%plot(F,abs(Pxy)); xlim([0 100]);
%hold on;
plot(F,C,'r');
xlabel('Frequency (Hz)'); ylabel('power'); title('cross-spectrum');
 
[acf,lags] = xcorr(data1,data2,100,'coeff');
lags = lags.*(1./Fs); % convert samples to time
 
subplot(224)
plot(lags,acf); grid on;
xlabel('time lag (s)'); ylabel('correlation ({\itr})'); title('xcorr');

%% Questions

%1. As per code above, the cross-spectrum increases as a function of the difference in amplitude
%between the two signals.

%2. Done and verified.

%3. When the signal's amplitude is reduced proportional to the noise, the
%coherence suffers (i.e., signal below 0.90 when Gaussian noise has a sigma
%of 0.1). The critical cut-off has been labeled in red on the following
%figure:

windowSize = 250;
s1 = sin(2*pi*f1*tvec)+0.1*randn(size(tvec));
figure(2);clf;
hold on;
trials = 18.0;
cs = 1.0 / trials;
leg = zeros(1,trials);
for trial = 1:trials
    s2 = (trial/trials)*sin(2*pi*f1*tvec) + +0.1*randn(size(tvec));
    [C,F] = mscohere(s1,s2,hanning(windowSize),windowSize/2,length(data1),Fs);
    CFS(trial) = C(16);
    if (trial == trials)
        leg(trial) = plot(F,C,'color',[0 0 0],'linewidth',2,'DisplayName', sprintf('Scale = %1.2f', 1.00));
    else
        leg(trial) = plot(F,C,'color',[cs*abs(trials-trial) cs*abs(trials-trial) cs*abs(trials-trial)],'linewidth',0.5,'DisplayName', sprintf('Scale = %1.2f', trial/trials));
    end
end
zscores = find((CFS-mean(CFS))./std(CFS) > 2.5 | (CFS-mean(CFS))./std(CFS) < -2.5);
if length(zscores)
    sig = zscores(length(zscores))
    objs = get(gca,'children');
    set(objs(3),'color',[1.0 0 0],'linewidth',3);
end
title('Coherence vs Noise','fontname','MinionPro-bold','fontsize',24);
ylabel('Power','fontname','MinionPro-regular','fontsize',18);
xlabel('Frequency(Hz)','fontname','MinionPro-regular','fontsize',18);
legend(leg);
