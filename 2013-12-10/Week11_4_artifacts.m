clearvars;clc;
%% Get the data
cd('C:\BIOL680\Data\R016-2012-10-03');
 
%% Start with FieldTrip

spike = ft_read_spike('R016-2012-10-03-TT02_2.t'); % needs fixed read_mclust_t.m
fc = {'R016-2012-10-03-CSC02b.ncs','R016-2012-10-03-CSC02d.ncs','R016-2012-10-03-CSC03d.ncs'};
data = ft_read_neuralynx_interp(fc);
data_all = ft_appendspike([],data, spike);

%% General data

cfg = [];
cfg.trialfun = 'ft_trialfun_lineartracktone2';
cfg.trialdef.hdr = data.hdr;
cfg.trialdef.pre = 2.5;
cfg.trialdef.post = 5;
 
cfg.trialdef.eventtype = 'nosepoke'; % could be 'nosepoke', 'reward', 'cue'
cfg.trialdef.location = 'both'; % could be 'left', 'right', 'both'
cfg.trialdef.block = 'both'; % could be 'value', 'risk'
cfg.trialdef.cue = {'c1','c3','c5'}; % cell array with choice of elements {'c1','c3','c5','lo','hi'}
 
[trl, event] = ft_trialfun_lineartracktone2(cfg);
cfg.trl = trl;
 
data_trl = ft_redefinetrial(cfg,data_all);

%% Remove artifact

cfg              = [];
cfg.timwin       = [-0.002 0.006]; % remove 4 ms around every spike
cfg.spikechannel = spike.label{1};
cfg.channel      = data.label(2); % only remove spike in the second LFP ('02d')
cfg.method       = 'linear'; % remove the replaced segment with interpolation
data_trli        = ft_spiketriggeredinterpolation(cfg, data_trl);

%% Phase-Locking
% Compute fourier

cfg              = [];
cfg.method       = 'convol';
cfg.foi          = 1:1:100;
cfg.t_ftimwin    = 5./cfg.foi; % 5 cycles per frequency
cfg.taper        = 'hanning';
cfg.spikechannel = spike.label{1};
cfg.channel      = data.label{2};
stsConvol        = ft_spiketriggeredspectrum(cfg, data_trli);

figure(1);plot(stsConvol.freq,nanmean(sq(abs(stsConvol.fourierspctrm{1}))));
figure(2);hist(angle(stsConvol.fourierspctrm{1}(:,:,9)),-pi:pi/18:pi);

cfg               = [];
cfg.method        = 'ppc0'; % compute the Pairwise Phase Consistency
cfg.spikechannel  = stsConvol.label;
cfg.channel       = stsConvol.lfplabel; % selected LFP channels
cfg.avgoverchan   = 'unweighted'; % weight spike-LFP phases irrespective of LFP power
cfg.timwin        = 'all'; % compute over all available spikes in the window
cfg.latency       = [-2.5 0];
statSts           = ft_spiketriggeredspectrum_stat(cfg,stsConvol);

% plot the results
figure(3);
plot(statSts.freq,statSts.ppc0');
xlabel('frequency');
ylabel('PPC');

%% Question 4
% The resulting PPC shows a much stronger level of activity in the theta
% range than prior to the artifact removal. There also appears to be a
% slight beta (~22Hz peaked) increase in firing.
