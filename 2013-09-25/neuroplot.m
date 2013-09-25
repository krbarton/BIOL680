function fig = neuroplot(spikes,csc,varargin);
%fig = neuroplot(spikes(1:5),csc,'spikeColor',[0 0 0;1 0 0;0 1 0;0 0 0;0 0 0])
%NEUROPLOT produces spike raster and LFP plot
%
% Implemented features: 
% 1. Keyboard navigation using arrow and WASD keys
% 2. Limited navigation within real data spans (0 to maximum data point,
% checks all imported files for this value; it does not impute it)
% 3. Zooming (though, the size of the zoom could be made to be relative to
% the distance from the original zoom level, to create a coarse-to-fine
% zoom). At the moment, it zooms at a rate of +/- 2%, which is more
% meaninful at low voltages, but comparatively minimal at high voltages.
% 4. Neuron labels on the plot
% 5. A minimalist y-axis bound to the maximum and minimum values visible
% within the current data window. This is updated for each zoom and pan.
% 6. A zoom amount indicator in the top right
% 7. Most or all of the text/labels/lines should dynamically rescale based
% on the size of the viewing window and amount of data (.t) files imported.
%
% Note: For maximum quality of the figure, it will try to maximize itself
% to 95% of the screen size.
%
% Known bugs: the zoom label is sized wrong under certain conditions
% (usually if data is maximized). Easy to fix, just didn't have the time.
% 
%Inputs:
%
% spikes: {nCells x 1} cell array of ts objects (spike train)
% csc: {nCSCs x 1} cell array of tsd objects (LFPs)
%
% varargins:
%
% cscColor: [nCSC x 3] RGB values to plot CSCs, default []
% spikeColor: [nCells x 3] RGB values to plot spikes, default []
%
% evt: [nEvents x 1] event times to plot, default []
% evtColor: [nEvents x 3] RGB values to plot events, default []
%
% interactiveMode: boolean to enable/disable arrow key navigation
    %Downsampling for testing purposes - removed from final version
    %csc = tsd(downsample(Range(csc),200), downsample(Data(csc),200));
    spikeColor = [];
    cscColor = [];
    evt = [];
    evtColor = [];
    interactiveMode = 1;
    extract_varargin;
    screenSize = get(0,'Screensize') * 0.95;
    %%Create the figure
    fig = figure('Position', screenSize); %Size is only calculated once here; dynamic re-sizing could be added, but it appears that has to be on the java backend to avoid bugs.
    variation_from_native = ((screenSize(3) / 1920) + (screenSize(4) / 1080)) / 2;
    hold on;
    box on;
    minT = 0;
    maxT = minT + 2000;
    totalT = 0;
    %%Create the spike raster
    for neuron = 1:length(spikes)
        text(12,neuron - 0.5,num2str(neuron),'FontSize',int64(30/length(spikes)*12*variation_from_native),'Tag','neuronText');
        spikeobj = spikes(neuron);
        %data = Data(Restrict(spikeobj{1},minT, maxT));
        data = Data(spikeobj{1});
        if (length(spikeColor) > 0)
            spikergb = spikeColor(neuron,:);
        else
            spikergb = [0.5 0.5 0.5];
        end        
        for spikeindex = 1:length(data)            
            line([data(spikeindex) data(spikeindex)],[neuron-1 neuron],'Color',spikergb,'Tag','rasterLine');            
        end
        totalT = max(totalT, data(spikeindex));
        clearvars data spikeobj spikergb;
    end  
    %%Add events to the spike raster
    if (length(evt) > 0)
        limits = get(gca,'XLim');
        for event = 1:length(evt)
            event_value = evt(event);
            if (length(evtColor))
                eventColor = evtColor(event,:);
            else
                eventColor = [0 0 0];
            end
            line([event_value event_value],[0 length(spikes)],'Color',eventColor,'LineWidth',1+(maxT-minT)*0.001,'Tag','eventLine');   
            text(event_value + (maxT-minT) * 0.005,length(spikes)*0.005,sprintf('Event (%i)', event_value),'rotation',90,'FontName','Calibri','FontSize',10,'Color',eventColor,'Tag','eventText','Clipping','on');
            clearvars event_value eventColor;
        end            
    end    
    %Scale the raster plot and add an xlabel
    set(gca,'XLim',[minT maxT],'YLim',[0 length(spikes)+5]);
    xlabel('Time(ms)','FontName','Cambria','FontSize',14,'Tag','abscissaLabel');
    %Remove axis labels and make border thicker
    set(gca,'YTick',[],'ticklength',[0,0],'linewidth',2);
    %Change the axis label font
    set(gca,'FontName','Calibri','FontSize',14);           
    %Add an extra line to function as a border between spike raster and LFP
    %plot
    line([0 max(Range(csc))],[length(spikes) length(spikes)],'Color',[0 0 0],'Tag','cscPlotboundary');
    
    %%Create LFP plot
    %minC = 1000;maxC = -1000;
    for cscindex = 1:length(csc)
        cscdata = csc(cscindex);        
        if (length(cscColor) > 0)
            cscrgb = cscColor(cscindex,:);
        else
            cscrgb = [0.75 0.75 0.75];
        end
        scaled_data = Data(cscdata)/1000+length(spikes)+3;
        plot(Range(cscdata),scaled_data,'Tag','cscPlot','Color',cscrgb); %max(Data(csc))
        %minC = min(minC, min(Data(cscdata)/1000+length(spikes)+3));
        %maxC = max(maxC, max(Data(cscdata)/1000+length(spikes)+3));
        totalT = max(totalT, max(Range(cscdata)));
    end
    hold off;
    setappdata(0, 'maxT', roundn(totalT,2));
    setappdata(0, 'maxY', length(spikes));
    setappdata(0, 'resMod', variation_from_native);
    [minv maxv] = neuroplot_scaleY(get(gca,'children'),[minT maxT]);
    line([12, 12], [minv, maxv],'Color',[0 0 0],'Tag','lfpAxis');
    text(18,minv,strcat(num2str(ceil((minv-length(spikes)-3)*1000)), ' \muV'),'Color',[0.8 0.8 0.8],'Tag','lfpAxisLB');
    text(18,maxv,strcat(num2str(ceil((maxv-length(spikes)-3)*1000)), ' \muV'),'Color',[0.8 0.8 0.8],'Tag','lfpAxisUB');
    text(maxT - 100,length(spikes)+4.7,strcat(num2str(1),'.00x'),'Tag','zoomlevelText');    
    if (interactiveMode == 1)
        set(gcf,'KeyPressFcn',@(h_obj,evt) HandleFigureKeypresses(h_obj,evt));
    end
end

