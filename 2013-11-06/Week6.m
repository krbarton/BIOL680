clear all; clc;

%% load the data
cd('C:/BIOL680/Data/R016-2012-10-03');
csc = myLoadCSC('R016-2012-10-03-CSC04a.Ncs');
data = ft_read_neuralynx_interp({'R016-2012-10-03-CSC04a.ncs'});

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
 
data_trl = ft_redefinetrial(cfg,data);

%% Basic eventLFPplot parameters

time_window = [-1 3]; % how many seconds before ans after event times

event_times = event.ts*10^-6;
events = event_times(:); % to select events

plt = eventLFPplot(csc,events,'decimate_amt',4,'filter_on',true,'filter_for','gamma','color_on',true)