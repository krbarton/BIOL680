%% Wipe variables and command console
clearvars;clc;
neuronNum = 1;
cd('C:\BIOL680\Data\R016-2012-10-03');
profile on;
 
%% Start loading some data
sd.fc = FindFiles('*.t');
sd.S = LoadSpikes(sd.fc);
csc = LoadCSC('R016-2012-10-03-CSC02d.ncs');
cscR = Range(csc); cscD = Data(csc);

Fs = 2000; dt = 1./Fs;
cscD = locdetrend(cscD,Fs,[1 0.5]); % remove slow drifts in signal (this can mess up the STA)

w = [-1 1]; % time window to compute STA over
tvec = w(1):dt:w(2); % time axis for STA
 
iC = neuronNum; % only do the third neuron for now
clear sta;
 
spk_t = Data(sd.S{iC});
 
h = waitbar(0,sprintf('Cell %d/%d...',iC,length(sd.S)));
 
for iSpk = length(spk_t):-1:1 % for each spike...
 
   sta_t = spk_t(iSpk)+w(1);
   sta_idx = nearest(cscR,sta_t); % find index of leading window edge
 
   toAdd = cscD(sta_idx:sta_idx+length(tvec)-1); % grab LFP snippet for this window
   % note this way can be dangerous if there are gaps in the data
 
   sta{iC}(iSpk,:) = toAdd'; % build up matrix of [spikes x samples] to average later
 
   waitbar(iSpk/length(spk_t));
end
 
close(h);

plot(tvec,nanmean(sta{neuronNum}),'k','LineWidth',2); 
set(gca,'FontSize',14,'XLim',[-0.5 0.5]); xlabel('time (s)'); grid on;

%% Question 1
% The spiking seems biased toward the positive phase of the theta
% oscillation. This seems theoretically related to a change in the membrane
% potential related to the local theta activity, pushing the neuron closer
% (in the case of positive phase) or farther (in the case of negative
% phase) spiking threshold. Kamondi, Acsady, Wang, and Buzaki (1998) seem 
% to relate this to slow-potassium channel activity. If I'm correct, this
% is one way in which local fields can interact with individual neurons to
% produce more complicated patterns of activity.