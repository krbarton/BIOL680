% Answer: Coherence clearly becomes very poor if the window size is not
%an optimal value

wsize = 50;
 
Fs = 500; dt = 1./Fs;
t = [0 2];
 
tvec = t(1):dt:t(2)-dt;
f1 = 40; f2 = 40;
 
% generate some strange sine waves
mod1 = square(2*pi*4*tvec,20); mod1(mod1 < 0) = 0;
mod2 = square(2*pi*4*tvec+pi,20); mod2(mod2 < 0) = 0;
 
data1 = sin(2*pi*f1*tvec); data1 = data1.*mod1 + 0.01*randn(size(tvec));
data2 = sin(2*pi*f2*tvec); data2 = data2.*mod2 + 0.01*randn(size(tvec)) ;
 
subplot(221);
plot(tvec,data1,'r',tvec,data2,'b'); legend({'signal 1','signal 2'});
title('raw signals');
 
[P1,F] = pwelch(data1,hanning(wsize),wsize/2,length(data2),Fs);
[P2,F] = pwelch(data2,hanning(wsize),wsize/2,length(data2),Fs);
[P1x,Fx] = pwelch(data1,hanning(500),wsize/2,length(data2),Fs);
[P2x,Fx] = pwelch(data2,hanning(500),wsize/2,length(data2),Fs);
subplot(222)
hold on;
plot(F,abs(P1),'r',F,abs(P2),'b'); title('PSD');
plot(Fx,abs(P1x),'color',[0.5 0 0]);
plot(Fx,abs(P2x),'color',[0.5 0.5 0.5]);
hold off;
 
subplot(223);
[C,F] = mscohere(data1,data2,hanning(wsize),wsize/2,length(data1),Fs);
[Cx,Fx] = mscohere(data1,data2,hanning(500),500/2,length(data1),Fs);
hold on;
plot(F,C); title('coherence'); xlabel('Frequency (Hz)');
plot(Fx,Cx);
hold off;
 
[ccf,lags] = xcorr(data1,data2,100,'coeff');
lags = lags.*(1./Fs); % convert samples to time
 
subplot(224)
plot(lags,ccf); grid on;
xlabel('time lag (s)'); ylabel('correlation ({\itr})'); title('xcorr');
