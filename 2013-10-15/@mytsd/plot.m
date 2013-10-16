function plot(mytsd)

hold on;
plot(mytsd.timestamps,mytsd.data,'color',[0.0 0.0 0.0],'LineWidth',1.0);
plot(mytsd.timestamps,repmat(mean(mytsd.data), size(mytsd.data)),'color',[0.7 0.5 0.5],'LineStyle','--');
plot(mytsd.timestamps,smooth(mytsd.data,20,'lowess'),'color',[0.5 0.5 0.5],'LineStyle','-.');
xlabel('Time');
ylabel('Signal');
legend('Data','Mean','Lowess');
set(findall(gcf,'type','text'),'FontSize',14,'FontWeight','bold','FontName','Calibri')
set(gca,'FontSize',12,'FontName','Calibri');
hold off;

