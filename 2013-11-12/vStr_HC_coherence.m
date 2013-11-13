%Answers:
%
%The ventral striatal cell(s) appear to show lower coherence about the
%theta range prior to an event, but recovers this post-event. It also shows
%strong correspondence at most other ranges, independent of pre/post
%status. So the theta modulation appears event-related. The gamma doesn't
%appear to show this pattern.
%
%The purported vStr-hippocampal cell(s) appear to show higher coherence about
%the theta range prior to an event, which reduces post-event. It also seems
%to show an increase in correspondence in the low-gamma range post-event.
%This seems to follow the pattern we would expect for spatial
%encoding/episodic recall (e.g., Shirvalkar, Rapp, Shapiro, 2010).
%
%The frequency correspondence, especially in the hippocampus, seems
%modulated by event much more than the vStr.

clear all;clc;


cd('C:\BIOL680\Data\R016-2012-10-03');
fc = {'R016-2012-10-03-CSC04d.ncs','R016-2012-10-03-CSC03d.ncs','R016-2012-10-03-CSC02b.ncs'};
data = ft_read_neuralynx_interp(fc);
data.label = {'vStr1','vStr2','HC1'}; % reassign labels to be more informative, the original filenames can be retrieved from 

%% One pellet

cfg = [];
cfg.trialfun = 'ft_trialfun_lineartracktone2';
cfg.trialdef.hdr = data.hdr;
cfg.trialdef.pre = 2.5; cfg.trialdef.post = 5;
 
cfg.trialdef.eventtype = 'nosepoke'; % could be 'nosepoke', 'reward', 'cue'
cfg.trialdef.location = 'both'; % could be 'left', 'right', 'both'
cfg.trialdef.block = 'both'; % could be 'value', 'risk', 'both'
cfg.trialdef.cue = {'c1'}; % cell array with choice of elements {'c1','c3','c5','lo','hi'} (1, 3, 5 pellets; low and high risk)
 
[trl, event] = ft_trialfun_lineartracktone2(cfg);
cfg.trl = trl;
 
data_trl = ft_redefinetrial(cfg,data);

cfg              = [];
cfg.output       = 'powandcsd';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 1:1:100; % frequencies to use
cfg.t_ftimwin    = 20./cfg.foi;  % frequency-dependent, 20 cycles per time window
cfg.keeptrials   = 'yes';
cfg.channel      = {'vStr1', 'vStr2', 'HC1'};
cfg.channelcmb   = {'vStr2', 'HC1'; 'vStr2' 'vStr1'}; % channel pairs to compute csd for

cfg.toi          = -2:0.05:0; % pre-nosepoke baseline (time 0 is time of nosepoke)
TFR_pre = ft_freqanalysis(cfg, data_trl);
cfg.toi          = 0:0.05:2;
TFR_post = ft_freqanalysis(cfg, data_trl);

cfg            = [];
cfg.method     = 'coh'; % compute coherence; other measures of connectivity are also available
fd_pre         = ft_connectivityanalysis(cfg,TFR_pre);
fd_post        = ft_connectivityanalysis(cfg,TFR_post);

figure(1);clf;
cols = 'rgb';
subplot(2,1,1);
for iCmb = 1:size(fd_pre.labelcmb,1)
    lbl{iCmb} = cat(2,fd_pre.labelcmb{iCmb,1},'-',fd_pre.labelcmb{iCmb,2}); 
    temp = nanmean(sq(fd_pre.cohspctrm(iCmb,:,:)),2);
    h(iCmb) = plot(fd_pre.freq,temp,cols(iCmb));
    hold on;
end
hold off;
title('Pre','fontname','Minionpro-bold','fontsize',24);
legend(h,lbl);

cols = 'rgb';
subplot(2,1,2);
for iCmb = 1:size(fd_post.labelcmb,1)
    lbl{iCmb} = cat(2,fd_post.labelcmb{iCmb,1},'-',fd_post.labelcmb{iCmb,2});
    temp = nanmean(sq(fd_post.cohspctrm(iCmb,:,:)),2);
    h(iCmb) = plot(fd_post.freq,temp,cols(iCmb));
    hold on;
end
hold off;
title('Post','fontname','Minionpro-bold','fontsize',24);
legend(h,lbl);

%% Five Pellets

cfg = [];
cfg.trialfun = 'ft_trialfun_lineartracktone2';
cfg.trialdef.hdr = data.hdr;
cfg.trialdef.pre = 2.5; cfg.trialdef.post = 5;
 
cfg.trialdef.eventtype = 'nosepoke'; % could be 'nosepoke', 'reward', 'cue'
cfg.trialdef.location = 'both'; % could be 'left', 'right', 'both'
cfg.trialdef.block = 'both'; % could be 'value', 'risk', 'both'
cfg.trialdef.cue = {'c5'}; % cell array with choice of elements {'c1','c3','c5','lo','hi'} (1, 3, 5 pellets; low and high risk)
 
[trl, event] = ft_trialfun_lineartracktone2(cfg);
cfg.trl = trl;
 
data_trl = ft_redefinetrial(cfg,data);

cfg              = [];
cfg.output       = 'powandcsd';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 1:1:100; % frequencies to use
cfg.t_ftimwin    = 20./cfg.foi;  % frequency-dependent, 20 cycles per time window
cfg.keeptrials   = 'yes';
cfg.channel      = {'vStr1', 'vStr2', 'HC1'};
cfg.channelcmb   = {'vStr2', 'HC1'; 'vStr2' 'vStr1'}; % channel pairs to compute csd for

cfg.toi          = -2:0.05:0; % pre-nosepoke baseline (time 0 is time of nosepoke)
TFR_pre = ft_freqanalysis(cfg, data_trl);
cfg.toi          = 0:0.05:2;
TFR_post = ft_freqanalysis(cfg, data_trl);

cfg            = [];
cfg.method     = 'coh'; % compute coherence; other measures of connectivity are also available
fd_pre         = ft_connectivityanalysis(cfg,TFR_pre);
fd_post        = ft_connectivityanalysis(cfg,TFR_post);

figure(2);clf;
cols = 'rgb';
subplot(2,1,1);
for iCmb = 1:size(fd_pre.labelcmb,1)
    lbl{iCmb} = cat(2,fd_pre.labelcmb{iCmb,1},'-',fd_pre.labelcmb{iCmb,2}); 
    temp = nanmean(sq(fd_pre.cohspctrm(iCmb,:,:)),2);
    h(iCmb) = plot(fd_pre.freq,temp,cols(iCmb));
    hold on;
end
hold off;
legend(h,lbl);
title('Pre','fontname','Minionpro-bold','fontsize',24);

cols = 'rgb';
subplot(2,1,2);
for iCmb = 1:size(fd_post.labelcmb,1)
    lbl{iCmb} = cat(2,fd_post.labelcmb{iCmb,1},'-',fd_post.labelcmb{iCmb,2});
    temp = nanmean(sq(fd_post.cohspctrm(iCmb,:,:)),2);
    h(iCmb) = plot(fd_post.freq,temp,cols(iCmb));
    hold on;
end
hold off;
title('Post','fontname','Minionpro-bold','fontsize',24);
legend(h,lbl);

figure(3);clf;
subplot(1,,1);
iC = 1; % which signal pair to plot
lbl = [fd_pre.labelcmb{1,:}]; % get the label of this pair
imagesc(fd_pre.time,fd_pre.freq,sq(fd_pre.cohspctrm(iC,:,:))); axis xy; colorbar
xlabel('time (s)'); ylabel('Frequency (Hz)'); title(lbl);

subplot(1,2,2);
iC = 1; % which signal pair to plot
lbl = [fd_post.labelcmb{1,:}]; % get the label of this pair
imagesc(fd_post.time,fd_post.freq,sq(fd_post.cohspctrm(iC,:,:))); axis xy; colorbar
xlabel('time (s)'); ylabel('Frequency (Hz)'); title(lbl);