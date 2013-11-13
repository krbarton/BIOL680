%%Answer: Coherence becomes cleaner as a function of data size.

%% just verify some cases where we break the phase relationship
Fs = 500; dt = 1./Fs;
t = [0 2]; tvec = t(1):dt:t(2)-dt;
data1 = sin(2*pi*8*tvec)+0.1*randn(size(tvec));
data2 = sin(2*pi*8*tvec+pi/4)+0.1*randn(size(tvec));

f = 2; % freq modulation (Hz) 
f2 = 8;
m = 2; % freq modulation strength
wsz = 200; % window size 

figure(1);clf;

subplot(421)
s2 = data2;
plot(tvec,s2,tvec,data1); title('signal 1 - constant phase');
 
subplot(422)
s3 = sin(2*pi*f2*tvec + m.*sin(2*pi*f*tvec - pi/2)) + 0.1*randn(size(tvec));
plot(tvec,s3,tvec,data1); title('signal 2 - varying phase');
 
subplot(423)
[Ps2,F] = pwelch(s2,hanning(wsz),wsz/2,length(data2),Fs);
plot(F,abs(Ps2)); title('PSD');
 
subplot(424)
[Ps3,F] = pwelch(s3,hanning(wsz),wsz/2,length(data2),Fs);
plot(F,abs(Ps3)); title('PSD');
 
subplot(425)
[C,F] = mscohere(data1,s2,hanning(wsz),wsz/2,length(data1),Fs); % shortcut to obtain coherence
plot(F,C); title('coherence'); xlabel('Frequency (Hz)');
 
subplot(426)
[C,F] = mscohere(data1,s3,hanning(wsz),wsz/2,length(data1),Fs);
plot(F,C); title('coherence'); xlabel('Frequency (Hz)');
 
[acf,lags] = xcorr(data1,s2,100,'coeff');
lags = lags.*(1./Fs); % convert samples to time
 
subplot(427)
plot(lags,acf); grid on;
xlabel('time lag (s)'); ylabel('correlation ({\itr})'); title('xcorr');
 
[acf,lags] = xcorr(data1,s3,100,'coeff');
lags = lags.*(1./Fs); % convert samples to time
 
subplot(428)
plot(lags,acf); grid on;
xlabel('time lag (s)'); ylabel('correlation ({\itr})'); title('xcorr');

figure(2);clf;

t = [0 10]; tvec = t(1):dt:t(2)-dt;
data1 = sin(2*pi*8*tvec)+0.1*randn(size(tvec));
data2 = sin(2*pi*8*tvec+pi/4)+0.1*randn(size(tvec));

subplot(421)
s2 = data2;
plot(tvec,s2,tvec,data1); title('signal 1 - constant phase');
 
subplot(422)
s3 = sin(2*pi*f2*tvec + m.*sin(2*pi*f*tvec - pi/2)) + 0.1*randn(size(tvec));
plot(tvec,s3,tvec,data1); title('signal 2 - varying phase');
 
subplot(423)
[Ps2,F] = pwelch(s2,hanning(wsz),wsz/2,length(data2),Fs);
plot(F,abs(Ps2)); title('PSD');
 
subplot(424)
[Ps3,F] = pwelch(s3,hanning(wsz),wsz/2,length(data2),Fs);
plot(F,abs(Ps3)); title('PSD');
 
subplot(425)
[C,F] = mscohere(data1,s2,hanning(wsz),wsz/2,length(data1),Fs); % shortcut to obtain coherence
plot(F,C); title('coherence'); xlabel('Frequency (Hz)');
 
subplot(426)
[C,F] = mscohere(data1,s3,hanning(wsz),wsz/2,length(data1),Fs);
plot(F,C); title('coherence'); xlabel('Frequency (Hz)');
 
[acf,lags] = xcorr(data1,s2,100,'coeff');
lags = lags.*(1./Fs); % convert samples to time
 
subplot(427)
plot(lags,acf); grid on;
xlabel('time lag (s)'); ylabel('correlation ({\itr})'); title('xcorr');
 
[acf,lags] = xcorr(data1,s3,100,'coeff');
lags = lags.*(1./Fs); % convert samples to time
 
subplot(428)
plot(lags,acf); grid on;
xlabel('time lag (s)'); ylabel('correlation ({\itr})'); title('xcorr');