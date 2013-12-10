clearvars;clc;
%% Get the data
cd('C:\BIOL680\Data\R016-2012-10-03');
 
%% Start loading some data
sd.fc = FindFiles('*.t');
sd.S = LoadSpikes(sd.fc);
csc = LoadCSC('R016-2012-10-03-CSC02d.ncs');
cscR = Range(csc); cscD = Data(csc);
Fs = 2000;
dt = 1./Fs;
cscD = locdetrend(cscD,Fs,[1 0.5]); % remove slow drifts in signal (this can mess up the STA)

w = [-1 1]; % time window to compute STA over
tvec = w(1):dt:w(2); % time axis for STA

%% Start the faster STA

%Neuron 1
iC = 1;
bin_edges = cscR+(dt/2);
len = length(tvec);
clear sta;
 
spk_ts = Restrict(sd.S{iC},cscR(1)-w(1),cscR(end)-w(2));
spk_t = Data(spk_ts)+w(1); % times corresponding to start of window
[~,spk_bins] = histc(spk_t,bin_edges); % index into data for start of window
spk_bins2 = spk_bins(:, ones(len,1));
toadd = repmat(0:len-1,[length(spk_bins) 1]);
spk_bins3 = spk_bins2+toadd;
 
sta_1 = cscD(spk_bins3);

%Neuron 3
iC = 3;
spk_ts = Restrict(sd.S{iC},cscR(1)-w(1),cscR(end)-w(2));
spk_t = Data(spk_ts)+w(1); % times corresponding to start of window
[~,spk_bins] = histc(spk_t,bin_edges); % index into data for start of window
spk_bins2 = spk_bins(:, ones(len,1));
toadd = repmat(0:len-1,[length(spk_bins) 1]);
spk_bins3 = spk_bins2+toadd;

sta_3 = cscD(spk_bins3);

figure();
plot(tvec,nanmean(sta_1),'color',[0 0 0],'LineWidth',1.5);
hold on;
plot(tvec,nanmean(sta_3),'color',[0 0 0],'LineWidth',1.5);
hold off;

%% Question
% Cell 1 seems to spike at or near the peak of the theta oscillation. 
% Cell 2 seems to spike at the opposing point of the theta oscillation.
% Both seem consistent with the idea that theta rhythm in the LFP modulates the
% local activity of hippocampal neurons (e.g., Spaak, 2012). In Cell 1, the 
% neuron hits threshold faster due to the rise in theta oscillation (or slower on a 
% downward phase), thus spikes maximally near the peak of the theta oscillation. 
% In Cell 2, the neuron seems to be at threshold (or more 'easily' excited) and 
% thus theta modulation draws down the membrane potential on downward phases, resulting 
% in firing at that point (in theory this would be related to refractory periods). Further
% to these observations, both of these neurons would seem to support the idea that neurons
% are not simply responsive to immediate excitation/inhibition, but also more global influences
% (i.e., LFPs), an idea critical to things like memory consolidation and LTP.