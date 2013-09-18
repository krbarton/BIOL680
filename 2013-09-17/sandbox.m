%% load data
% first, cd to where the data you just grabbed is located
[csc,csc_info] = LoadCSC('R016-2012-10-08-CSC02d.ncs');
tvec = Range(csc);
raw_LFP = Data(csc);
 
%% plot
nSamples = 10000;
plot(tvec(1:nSamples),raw_LFP(1:nSamples));