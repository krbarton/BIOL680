function events = detectSWR(csc,varargin)
%--------------------------------------------------------------------------
%detectSWT(csc, varargin)
%
%Warning: extremely processor intensive on large samples!
%
%Inputs:
%   CSC: [1 x 1] TSD containing an LFP signal
%
%Optional:
%   ripple_band: [2 x 1] low and high for filter (default: [140 180])
%   threshold: z-score threshold for signal detection (default: 5)
%   restrict_range: [2 x 1]  time window (default: [6000 6025])
%   Fs: integer indicating sampling frequency (default: 2000)
%
%--------------------------------------------------------------------------

ripple_band = [140 180];
threshold = 5;
restrict_range = [6000 6025]; 
Fs = 2000; % Could have been taken from header, but this was not implemented due to ease of testing
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

%%Start filtering signal for SWR detection
%A little hacky, but centers on the mean of the SWR
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
