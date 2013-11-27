%% Intiailize
clear all;clc;
cd('C:\BIOL680\Data\R042-2013-08-18');

fc = FindFiles('*.t');
S = LoadSpikes(fc);

%% Pick our time sample and two neurons
start_time = 3200;
finish_time = 5650;
cell1 = 5;
cell2 = 42;

%% Grab some data for the neurons
tvec = start_time:0.001:finish_time;tvec = tvec(1:end-1)';
signal1 = Restrict(S{cell1},start_time,finish_time);
signal2 = Restrict(S{cell2},start_time,finish_time);
spk_t1 = Data(signal1);
spk_t2 = Data(signal2);

%% Generate the SDF
binsize = 0.001; %1ms
tbin_edges = start_time:binsize:finish_time;
tbin_centers = tbin_edges(1:end-1)+binsize/2;
spk_count_1 = histc(spk_t1,tbin_edges);
spk_count_1 = spk_count_1(1:end-1);
spk_count_2 = histc(spk_t2,tbin_edges);
spk_count_2 = spk_count_2(1:end-1);
gauss_window = 1./binsize; % 1 second window
gauss_SD = 0.05./binsize; %0.05 seconds (50ms) SD
gk = gausskernel(gauss_window,gauss_SD); gk = gk./binsize; %Normalize
gauss_sdf_s1 = conv2(spk_count_1,gk,'same'); %Convolve with a gaussian kernel
gauss_sdf_s2 = conv2(spk_count_2,gk,'same'); 

figure(1);clf;
subplot(1,2,1);
bar(tbin_centers,gauss_sdf_s1);
title('Signal 1');
subplot(1,2,2);
bar(tbin_centers,gauss_sdf_s2);
title('Signal 2');

%% Start computing the poisson spike train
%Signal 1
prob_s1 = gauss_sdf_s1*0.001;
s1_distribution = rand(size(tvec));s1_idx = find(s1_distribution < prob_s1);
s1_poisson = tvec(s1_idx).';
s1_poisson_ts = ts(s1_poisson);
s1_orig_ts = ts(spk_t1);
%Signal 2
prob_s2 = gauss_sdf_s2*0.001;
s2_distribution = rand(size(tvec));s2_idx = find(s2_distribution < prob_s2);
s2_poisson = tvec(s2_idx).';
s2_poisson_ts = ts(s2_poisson);
s2_orig_ts = ts(spk_t2);

%% Compute CCF

[xcorr_poisson,xbins_poisson] = ccf(s1_poisson_ts,s2_poisson_ts,0.01,1);
[xcorr_orig,xbins_orig] = ccf(s1_orig_ts,s2_orig_ts,0.01,1);
figure(2);clf;
title('Synthetic Versus Actual Signal');
plot(xbins_poisson,xcorr_poisson,'linewidth',0.75,'linestyle','--','color',[0 0 0]);
hold on;
plot(xbins_orig,xcorr_orig,'linewidth',1.5,'color',[0 0 0]);
xlabel('Time(S)');
ylabel('Cross Correlation');
legend('Synthetic','Actual');
hold off;