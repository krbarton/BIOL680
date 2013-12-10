clearvars;clc;
%% Get the data
cd('C:\BIOL680\Data\R016-2012-10-03');
 
%% Start with FieldTrip

spike = ft_read_spike('R016-2012-10-03-TT02_2.t'); % needs fixed read_mclust_t.m
fc = {'R016-2012-10-03-CSC02b.ncs','R016-2012-10-03-CSC02d.ncs','R016-2012-10-03-CSC03d.ncs'};
data = ft_read_neuralynx_interp(fc);
data_all = ft_appendspike([],data, spike);

plot(data_all.time{1},data_all.trial{1}(1,:)) % a LFP
hold on;
plot(data_all.time{1},data_all.trial{1}(4,:)*500,'r') % binarized spike train (0 means no spike, 1 means spike)

%% Compute STA

cfg              = [];
cfg.timwin       = [-0.5 0.5]; %
cfg.spikechannel = spike.label{1}; % first unit
cfg.channel      = data.label(1:3); % first 3 LFPs
staAll           = ft_spiketriggeredaverage(cfg, data_all);
 
% plot
figure
plot(staAll.time, staAll.avg(:,:)');
legend(data.label); h = title(cfg.spikechannel); set(h,'Interpreter','none');
set(gca,'FontSize',14,'XLim',cfg.timwin,'XTick',cfg.timwin(1):0.1:cfg.timwin(2)); 
xlabel('time (s)'); grid on;

%% Event-related STA

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

cfg              = [];
cfg.timwin       = [-0.5 0.5];
cfg.latency      = [-2.5 0];
cfg.spikechannel = spike.label{1}; % first unit
cfg.channel      = data.label(1:3); % first 3 LFPs
staPre           = ft_spiketriggeredaverage(cfg, data_trl);

cfg              = [];
cfg.timwin       = [-0.5 0.5];
cfg.latency      = [0 2.5];
cfg.spikechannel = spike.label{1}; % first unit
cfg.channel      = data.label(1:3); % first 3 LFPs
staPost          = ft_spiketriggeredaverage(cfg, data_trl);
 
% plot
figure();
subplot(2,1,1);
plot(staPre.time, staPre.avg(:,:)');
legend(data.label); h = title('Pre-nosepoke'); set(h,'Interpreter','none');
set(gca,'FontSize',14,'XLim',cfg.timwin,'XTick',cfg.timwin(1):0.1:cfg.timwin(2)); 
subplot(2,1,2);
plot(staPost.time, staPost.avg(:,:)');
legend(data.label); h = title('Post-nosepoke'); set(h,'Interpreter','none');
set(gca,'FontSize',14,'XLim',cfg.timwin,'XTick',cfg.timwin(1):0.1:cfg.timwin(2)); 
xlabel('time (s)'); grid on;

%%Question 3
%Post-reward firing activity seems to show a much stronger preference to
%produce/sustain firing activity due to the precession of the theta
%oscillation. As such, this seems to demonstrate that the phase-locking
%modulates the potentiation process.