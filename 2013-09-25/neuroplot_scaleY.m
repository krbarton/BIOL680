function [minv maxv] = neuroplot_scaleY(objs,limits)
%Identifies the maximum and minimum Y value from plotted data within a
%given time range
    lfpAxis = findobj(objs,'Tag', 'lfpAxis');  %Drawn axis
    lfpObjs = findobj(objs,'Tag','cscPlot');   %Drawn Data
    %lfpAxisXData = get(lfpAxis,'XData');
    %lfpAxisYData = get(lfpAxis,'YData');
    minv = 100000;maxv = -100000;
    for i = 1:length(lfpObjs)
        xdata = get(lfpObjs(i),'XData');
        validtimes = find(xdata>=limits(1)&xdata<=limits(2));
        clearvars xdata;
        ydata = get(lfpObjs(i),'YData');
        validydata = ydata(validtimes);
        clearvars validtimes ydata;
        minv = min([minv, min(validydata)]);
        maxv = max([maxv, max(validydata)]);
    end    
    clearvars lfpAxis lfpObjs lfpAxisXData lfpAxisYData ydata validydata;
end

