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
cfg.channel      = data.label{1};
stsConvol        = ft_spiketriggeredspectrum(cfg, data_trli);


%% Sliding Window

param = 'ppc0'; % set the desired parameter
 
cfg                = [];
cfg.method         = param;
 
cfg.spikechannel  = stsConvol.label;
cfg.channel       = stsConvol.lfplabel; % selected LFP channels
cfg.avgoverchan    = 'unweighted';
cfg.winstepsize    = 0.01; % step size of the window that we slide over time
cfg.timwin         = 0.5; % duration of sliding window
statSts            = ft_spiketriggeredspectrum_stat(cfg,stsConvol);
 
figure
cfg            = [];
cfg.parameter  = param;
cfg.refchannel = statSts.labelcmb{1,1};
cfg.channel    = statSts.labelcmb{1,2};
cfg.xlim       = [-2 3]; cfg.ylim = [2 30];
ft_singleplotTFR(cfg, statSts);

%% Spike-field Coherence
cfg              = [];
cfg.output       = 'powandcsd';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 1:1:100; % frequencies to use
cfg.t_ftimwin    = 5./cfg.foi;  % frequency-dependent, 5 cycles per time window
cfg.keeptrials   = 'yes';
cfg.channel      = {'R016-2012-10-03-CSC02b', 'R016-2012-10-03-TT02_2'};
cfg.channelcmb   = {'R016-2012-10-03-CSC02b', 'R016-2012-10-03-TT02_2'}; % channel pairs to compute csd for
 
cfg.toi          = -2:0.05:3;
 
TFR_pre = ft_freqanalysis(cfg, data_trl);
 
cfg            = [];
cfg.method     = 'ppc'; % compute coherence; other measures of connectivity are also available
fd             = ft_connectivityanalysis(cfg,TFR_pre);
 
iC = 1; % which signal pair to plot
lbl = [fd.labelcmb{1,:}]; % get the label of this pair
imagesc(fd.time,fd.freq,sq(fd.ppcspctrm(iC,:,:))); axis xy; colorbar
xlabel('time (s)'); ylabel('Frequency (Hz)'); title(lbl);

csc = myLoadCSC('R016-2012-10-03-CSC02d.ncs');
cscR = Range(csc); cscD = Data(csc);
 
% filter in theta range
Fs = 2000;
Wp = [ 6 10] * 2 / Fs;
Ws = [ 4 12] * 2 / Fs;
[N,Wn] = cheb1ord( Wp, Ws, 3, 20); % determine filter parameters
[b_c1,a_c1] = cheby1(N,0.5,Wn); % builds filter
 
csc_filtered = filtfilt(b_c1,a_c1,cscD);
phi = angle(hilbert(csc_filtered));

S = LoadSpikes({'R016-2012-10-03-TT02_1.t'});
spk_t = Data(S{1});
spk_phi = interp1(cscR,phi,spk_t,'nearest');
 
hist(spk_phi,-pi:pi/18:pi)

[Timestamps, X, Y, Angles, Targets, Points, Header] = Nlx2MatVT('VT1.nvt', [1 1 1 1 1 1], 1, 1, []);
Timestamps = Timestamps*10^-6;
toRemove = (X == 0 & Y == 0);
X = X(~toRemove); Y = Y(~toRemove); Timestamps = Timestamps(~toRemove);
 
spk_x = interp1(Timestamps,X,spk_t,'linear');
spk_y = interp1(Timestamps,Y,spk_t,'linear');
 
plot(X,Y,'.','Color',[0.5 0.5 0.5],'MarkerSize',1); axis off; hold on;
h = scatterplotC(spk_x,spk_y,spk_phi,'Scale',[-pi pi],'solid_face',1,'plotchar','.');