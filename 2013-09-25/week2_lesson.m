cd('C:\BIOL680\Data\R042-2013-08-18');

%%Wipe variables and command console
clearvars;clc;
%%Load some data
%Get spiking data
fprintf('Starting to load data...\n');
tfiles = FindFiles('*.t');
spikes = LoadSpikes(tfiles);
%Get CSC data
[csc,csc_info] = LoadCSC('R042-2013-08-18-CSC03a.ncs');
%Get tracking data
[Timestamps, X, Y, Angles, Targets, Points, Header] = Nlx2MatVT('VT1.nvt', [1 1 1 1 1 1], 1, 1, [] );
fprintf('Done loading data!\n');

%%Data Integrity Check
if (size(Data(csc)) ~= size(Range(csc)))
    error('Size Error', 'CSC data and timestamps are not the same size');
end
fprintf('Data integrity check...PASSED\n');

%%Timestamping tracking data
fprintf('Timestamping tracking data\n');
Timestamps_S = Timestamps * 10^-6;
x_TSD = tsd(Timestamps_S, X.');
y_TSD = tsd(Timestamps_S, Y.');

%%Data Restriction
csc_short = Restrict(csc,5950,6050);
x_short = Restrict(x_TSD,5950,6050);
y_short = Restrict(y_TSD,5950,6050);

%%Plotting
figure(1);clf;
lp = plot(Range(csc_short),Data(csc_short));
%tp = title('Local Field Potential');
%set(tp,'Color',[1 1 1]);
%xlabel('Time(s)');
%ylabel('Voltage(mV)');
set(gcf,'Color',[0 0 0]);
set(gca,'Color',[0 0 0]);
set(gca,'XColor',[1 1 1]);
set(gca,'YColor',[1 1 1]);
set(gcf,'InvertHardCopy','on');
print(gcf,'-dpng','-r300','1R042-2013-08-18-LFPsnippet.png');
set(gcf,'InvertHardCopy','off');
print(gcf,'-dpng','-r300','2R042-2013-08-18-LFPsnippet.png');

hold on;box off;
csc_mean= nanmean(Data(csc));
xr = get(gca,'XLim');
mean_hdl = plot(xr,[csc_mean csc_mean]);
set(mean_hdl,'Color',[1 0 0]);
set(mean_hdl,'LineStyle','--');
set(mean_hdl,'LineWidth',2);
%lg = legend('Voltage', 'Mean');
%set(lg,'Color',[0.5 0.5 0.5]);
print(gcf,'-dpng','-r300','3R042-2013-08-18-LFPsnippet.png');
set(gca,'XLim',[5989 5990],'FontSize',[24])
print(gcf,'-dpng','-r300','4R042-2013-08-18-LFPsnippet.png');

%%Anon Function
sqr_fn = @(x) x.^2;
sqr_fn(2);

set(gcf,'KeyPressFcn',@(h_obj,evt) week2_lesson_HandleFigureKeypresses(h_obj,evt));

