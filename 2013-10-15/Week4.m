clear all;clc;
cd('C:\BIOL680\Data\R016-2012-10-08');
rndSeed = 99;
%%
%%Question 1

%Comments:
%{
The signal does not fit the 1/F distribution. It has a relatively flat 
power spectrum, with a pronounced, rapidly decaying, low frequency 
component. The flat spectrum is to be expected given the equiprobable 
distribution of the signal, but the low frequency component strikes me
as a bit odd. Maybe a result of the window containing zero?
%}

sample_rate = 2000;
startT = 0;finishT = 10;
windowSize = 1024;
numPoints = 1024;

%Create the signal and time vector
times = startT:1/sample_rate:finishT;
rand('seed',rndSeed);
signal = rand(1,length(times));

%Generate the figure
figure(1);clf;
subplot(2,1,1);
plot(times,signal,'Color',[0.3 0.3 0.3]); %Plot the raw signal
set(gca,'YLim',[-0.2 1.2]); %Offset a little bit to see the signal slightly better
xlabel('Time(S)');
ylabel('Signal');
title('White Noise Signal');

subplot(2,1,2);
[psdEst,freqEst] = pwelch(signal,hamming(windowSize),windowSize/2,numPoints,sample_rate); %Welch spectrum with Hamming window
hold on;
plot(freqEst,10*log10(psdEst),'Color',[0.15 0.15 0.15]); %Plot the power spectrum
pIdeal = 10*log10(1./freqEst)+max(10*log10(psdEst));     
plot(freqEst,pIdeal,'Color',[0.3 0.3 0.3],'LineStyle','-.'); %Plot the 1/F spectrum
legend('Raw PSD','Fitted 1/F');
hold off;
xlabel('Frequency(Hz)'); 
ylabel('Power(dB)');
title('White-Noise PSD');
set(findall(gcf,'-property','FontName'),'FontName','Calibri') 
%%

%%Question 2

%Comments:
%{
Both signals show pretty decent fit for a 1/F distribution, below ~200Hz.

The hippocampal LFP appears to show a pronounced delta, theta, and beta
oscillations, as well as the 60Hz line noise. There is also a pronounced
oscillation at ~175Hz (perhaps ripple events referenced by Buzaki?)

The ventral striatal LFP shows delta, theta, and beta oscillations, but to
a lesser degree than the hippocampal LFP. However, it shows gamma 
oscillations, unlike the hippocampal signal.
%}

R016_2012_10_08_keys;
ontime = ExpKeys.TimeOnTrack(1);
offtime = ExpKeys.TimeOnTrack(2);
cscHi = LoadCSCv2('R016-2012-10-08-CSC02b.ncs');
cscVS = LoadCSCv2('R016-2012-10-08-CSC04d.ncs');
Hi = getHeader(cscHi);
block1cscHi = Restrict(cscHi,ontime,offtime);
block1cscVS = Restrict(cscVS,ontime,offtime);
figure(2);clf;
subplot(4,1,1);
plot(block1cscHi);
title('Hippocampus');
[psdEst,freqEst] = pwelch(Data(block1cscHi),hamming(windowSize),windowSize/2,numPoints*2,sample_rate); %Welch spectrum with Hamming window
subplot(4,1,2);
hold on;
plot(freqEst,10*log10(psdEst),'Color',[0.15 0.15 0.15]); %Plot the power spectrum
pIdeal = 10*log10(1./freqEst)+max(10*log10(psdEst));     
plot(freqEst,pIdeal,'Color',[0.3 0.3 0.3],'LineStyle','-.'); %Plot the 1/F spectrum
legend('Raw PSD','Fitted 1/F');
hold off;
set(gca,'XLim',[0,300]);
xlabel('Frequency(Hz)'); ylabel('Power(dB)');title('Hippocampal PSD');
subplot(4,1,3);
plot(block1cscVS);
title('Ventral Striatum');
[psdEst,freqEst] = pwelch(Data(block1cscVS),hamming(windowSize),windowSize/2,numPoints*2,sample_rate); %Welch spectrum with Hamming window
subplot(4,1,4);
hold on;
plot(freqEst,10*log10(psdEst),'Color',[0.15 0.15 0.15]); %Plot the power spectrum
pIdeal = 10*log10(1./freqEst)+max(10*log10(psdEst));     
plot(freqEst,pIdeal,'Color',[0.3 0.3 0.3],'LineStyle','-.'); %Plot the 1/F spectrum
legend('Raw PSD','Fitted 1/F');
hold off;
set(gca,'XLim',[0,300]);
xlabel('Frequency(Hz)'); ylabel('Power(dB)');title('Hippocampal PSD');
%%

%%Question 3

%Comments:
%{
Window size influences the degree of averaging/smoothing of the power
spectrum. At higher window sizes, amplitude and distinctiveness of each 
frequency band becomes more pronounced. Further, it appears that a window
size of 100 or greater is necessary to start to identify noteworthy 
oscillatory patterns (less pronounced patterns requiring an even higher
window size).
%}

figure(3);clf;
sizes = [2^3,2^5,2^7,2^9,2^11];
block1cscHi_half = Restrict(cscHi,ontime,ontime+(offtime-ontime)/2);
block1cscVS_half = Restrict(cscVS,ontime,ontime+(offtime-ontime)/2);

for ps = 1:5
    windowSize = sizes(ps);
    [psdEst,freqEst] = pwelch(Data(block1cscHi_half),hamming(windowSize),windowSize/2,numPoints,sample_rate); %Welch spectrum with Hamming window
    subplot(5,1,ps);
    plot(freqEst,10*log10(psdEst),'Color',[0.15 0.15 0.15]); %Plot the power spectrum
    if (ps == 1)        
        title(sprintf('Hippocampus\nWindow size: %d', windowSize));
    else
       title(['Window size: ', int2str(windowSize)]);
    end        
    xlabel('Frequency(Hz)'); ylabel('Power(dB)');
end
set(findall(gcf,'-property','FontName'),'FontName','Calibri') 

figure(4);clf;
sizes = [2^3,2^5,2^7,2^9,2^11];
for ps = 1:5
    windowSize = sizes(ps);
    [psdEst,freqEst] = pwelch(Data(block1cscVS_half),hamming(windowSize),windowSize/2,numPoints,sample_rate); %Welch spectrum with Hamming window
    subplot(5,1,ps);
    plot(freqEst,10*log10(psdEst),'Color',[0.15 0.15 0.15]); %Plot the power spectrum
    if (ps == 1)        
        title(sprintf('Striatal\nWindow size: %d', windowSize));
    else
       title(['Window size: ', int2str(windowSize)]);
    end
    xlabel('Frequency(Hz)'); ylabel('Power(dB)');
end
set(findall(gcf,'-property','FontName'),'FontName','Calibri') 
%%

%%Question 4

%Comments:
%{

Downsampling exaggerates the power spectrum, especially in amplitude. As
such, it can give the mistaken impression that certain frequency
bands/oscillations were more pronounced than they actually were. In
contrast, decimation largely retains the same power spectrum, though there
is a slight loss in overall amplitude.

Interestingly, decimation produces an extremely sharp decline in power
above 200 Hz.

%}


dsf = 4;
block1cscHi_halfDE = decimate(Data(block1cscHi_half),dsf);
block1cscHi_halfDS = downsample(Data(block1cscHi_half),dsf);
new_sample_rate = sample_rate./dsf;
windowSize = 1024;
figure(5);clf;
subplot(3,1,1);
[psdEst,freqEst] = pwelch(Data(block1cscHi_half),hamming(windowSize),windowSize/2,numPoints,sample_rate); %Welch spectrum with Hamming window
plot(freqEst,10*log10(psdEst),'Color',[0.15 0.15 0.15]); %Plot the power spectrum
set(gca,'XLim',[0,250]);
xlabel('Frequency(Hz)'); ylabel('Power(dB)');title('Hippocampal PSD (raw)');
[psdEst,freqEst] = pwelch(block1cscHi_halfDE,hamming(windowSize),windowSize/2,numPoints,new_sample_rate); %Welch spectrum with Hamming window
subplot(3,1,2);
plot(freqEst,10*log10(psdEst),'Color',[0.15 0.15 0.15]); %Plot the power spectrum
xlabel('Frequency(Hz)'); ylabel('Power(dB)');title('Hippocampal PSD (decimated)');
[psdEst,freqEst] = pwelch(block1cscHi_halfDS,hamming(windowSize),windowSize/2,numPoints,new_sample_rate); %Welch spectrum with Hamming window
subplot(3,1,3);
plot(freqEst,10*log10(psdEst),'Color',[0.15 0.15 0.15]); %Plot the power spectrum
xlabel('Frequency(Hz)'); ylabel('Power(dB)');title('Hippocampal PSD (downsampled)');


%% Part 4 notes

% 4. Compare the PSD following the use of decimate() as in the above example, to a PSD obtained from downsampling without using decimate(). Are there any differences?
