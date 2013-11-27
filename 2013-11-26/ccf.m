function [cc,xbin] = ccf(spike_times1,spike_times2,binsize,max_t)
% function [cc,xbin] = ccf(spike_times1,spike_times2,binsize,max_t)
%
% estimate cross-correlation function of input spike train
%
% INPUTS:
% spike_times1: [1 x 1 ts]
% spike_times2: [1 x 1 ts]
% binsize: ccf bin size in s
% max_t: length of acf in s
%
% OUTPUTS:
% cc: cross-correlation estimate (relative to spike_times1)
% xbin: bin centers (in s)
%
% MvdM 2013
 
spk_t1 = Data(spike_times1);
spk_t2 = Data(spike_times2);
 
xbin_centers = -max_t-binsize:binsize:max_t+binsize; % first and last bins are to be deleted later
cc = zeros(size(xbin_centers));
 
for iSpk = 1:length(spk_t1)
 
   relative_spk_t = spk_t2 - spk_t1(iSpk);
 
   cc = cc + hist(relative_spk_t,xbin_centers); % note that histc puts all spikes outside the bin centers in the first and last bins! delete later.
 
end
 
xbin = xbin_centers(2:end-1); % remove unwanted bins
cc = cc(2:end-1);
 
cc = cc./(length(spk_t1)); % normalize by number of spikes of first input