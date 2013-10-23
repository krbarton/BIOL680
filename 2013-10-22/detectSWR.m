function events = detectSWR(csc,varargin)

ripple_band = [140 180];
threshold = 5;
%%Added to make manageable. Large windows seem to kill the CPU. You have been
%%warned!
restrict_range = [6000 6025]; 
Fs = 2000;
extract_varargin;

csc_active = Restrict(csc, restrict_range(1), restrict_range(2));
csc_active = csc
x = Data(csc_active);
tvec = Range(csc_active);

Wpass = ripple_band * 2 / Fs;
Wstop = [ripple_band(1)-3 ripple_band(2)+3] * 2 / Fs;
[N, Wn] = ellipord(Wpass,Wstop,3,20);
[b,a] = ellip(N,0.005,15,Wn);
y = filtfilt(b,a,x);
filter_SWR_power = y.^2;
filtered_SWR = medfilt1(filter_SWR_power,100);
mean_signal = nanmean(filtered_SWR);
sd_signal = nanstd(filtered_SWR);
zScores = (filtered_SWR-mean_signal)/sd_signal; 

%%Hacky centering of z-scores. My brain isn't working right now.
startT = 0;cnt = 0;
times = [];powers=[];
for ii = 1:length(zScores)
    if (abs(zScores(ii)) >= threshold && startT == 0)
        startT = ii;    
    end
    if (startT > 0 && abs(zScores(ii)) < threshold)
        cnt = cnt + 1;
        finishT = ii;
        loc = int32(startT + (finishT - startT)/2);
        times(cnt) = tvec(loc);
        powers(cnt) = zScores(loc);
        startT = 0;
    end
end

events.t = times;
events.pwr = powers;

%%Optional comments:

%Presumably, we're using z-scores to standardize the results. This helps 
%reduce the risk of false positives in signal detection. But in doing so,
%we assume signal events occur on a normal distribution. This could
%occasionally be problematic.
%
%You could improve the accuracy of the SWR function by accounting for noise
%both in instrumentation and physical (e.g. thermal noise, axonal jitter, ion
%channel fluctuations, etc. This could simply be done pretty simply without smoothing
%
%A custom digital filter would probably be superior at identifying specific SWR events
%since their response characteristics seem to be somewhat unique and variable 
%(to some degree in their temporal valence and magnitude)
