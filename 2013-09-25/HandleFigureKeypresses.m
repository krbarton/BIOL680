function HandleFigureKeypresses2(obj,event)
    %This function handles any keypresses for a figure    
    %Left/A and Right/D navigate the plot backwards and forwards in time.
    %Up/W and Down/S zoom the plot in and out.
    %Notes:
    %
    %1. Scrolling is limited between 0 and the max data value (spike raster
    %and LFP plots inclusive)
    %
    %2. Zoom extent is updated for each zoom.
    %
    %3. The LFP axis dynamically resizes based on the range of 'visible'
    %data for the current timespan.
    %
    %Needs optimization; probably should have re-used code put into
    %separate .m files, but putting it in one place presumably makes it
    %easier to evaluate, at once.
    keypressed = event.Key;
    objs = get(get(gcf,'Children'),'Children'); 
    maxT = getappdata(0, 'maxT');    
    maxY = getappdata(0, 'maxY');
    if (strcmp(keypressed,'leftarrow') || strcmp(keypressed,'rightarrow')|| strcmp(keypressed,'a') || strcmp(keypressed,'d'))
        
        %Figure out which of the two keys was pressed
        if strcmp(keypressed(1),'l') || strcmp(keypressed(1),'a')
           direction = -1;
        else
           direction = 1;           
        end
        %Dynamically determine the range to iterate over and calculate the
        %shift
        current_limits = get(gca,'XLim');
        adjustment = 2000 * (0.10 * direction);     
        new_limits = current_limits + adjustment;        
        if (maxT)
            real_limits = [0 maxT];            
        else
            real_limits = [0 10000];            
        end
        new_limits = current_limits + adjustment;
        if new_limits(1) >= real_limits(1) && new_limits(2) <= real_limits(2)
            current_limits =  current_limits + adjustment;
            set(gca,'XLim', current_limits);
            %A bit hacky, but here we go...translate the neuron labels
            %every movement. Figure-relative coordinates would probably be a
            %better solution, but laziness has won me over!
            neuronlabel = findobj(objs,'Tag','neuronText');
            labelpos = cell2mat(get(neuronlabel,'Position'));
            for i = 1:length(neuronlabel)
                pos = [labelpos(i,1)+adjustment,labelpos(i,2),labelpos(i,3)];
                set(neuronlabel(i),'Position',pos);
            end            
            zoomlabel = findobj(objs,'Tag','zoomlevelText');
            zoompos = get(zoomlabel,'Position');
            set(zoomlabel,'Position',[zoompos(1)+adjustment, zoompos(2), zoompos(3)]);
            lfpAxis = findobj(objs,'Tag', 'lfpAxis');  %Drawn axis
            lfpAxisXData = get(lfpAxis,'XData');
            [minv maxv] = neuroplot_scaleY(objs,[current_limits(1) current_limits(2)]);
            set(lfpAxis,'XData',lfpAxisXData + adjustment);
            set(lfpAxis,'YData',[minv maxv]);            
            lfpAxisUBtext = findobj(objs,'Tag','lfpAxisUB');
            lfpAxisLBtext = findobj(objs,'Tag','lfpAxisLB');
            UB = get(lfpAxisUBtext,'Position');
            LB = get(lfpAxisLBtext,'Position');
            set(lfpAxisUBtext,'String',strcat(num2str(ceil((maxv-maxY-3)*1000)), ' \muV'),'Position',[UB(1)+adjustment, maxv, 0]);
            set(lfpAxisLBtext,'String',strcat(num2str(ceil((minv-maxY-3)*1000)), ' \muV'),'Position',[LB(1)+adjustment, minv, 0]);            
        end
        %Clear the variables, for good housekeeping. Probably not necessary              
        clearvars direction current_limits adjustment xdata new_limits real_limits neuronlabel labelpos pos zoomlabel zoompos;
    end
    if (strcmp(keypressed,'uparrow') || strcmp(keypressed,'downarrow')|| strcmp(keypressed,'w') || strcmp(keypressed,'s'))
        if strcmp(keypressed(1),'u') || strcmp(keypressed(1),'w')
           direction = -1;
           disp('Enhance!');       
        else
           direction = 1;
           disp('Zoom out!');
        end
        current_limits = get(gca,'XLim');
        adjustment = 2000 * (direction * 0.01);
        if ((current_limits(1) <= 0.0 || current_limits(1)+adjustment <= 0.0) && (current_limits(2)+adjustment*2 <= maxT) && current_limits(2)+adjustment*2 > 0.0)
            new_limits = [current_limits(1), current_limits(2)+adjustment*2];
        elseif ((current_limits(2) >= maxT || current_limits(2)+adjustment >= maxT) && (current_limits(1)+adjustment*2 >= 0.0) && current_limits(1)+adjustment*2 < maxT)
            new_limits = [current_limits(1)+adjustment*2, current_limits(2)];
        elseif (current_limits(1)-adjustment >= 0.0 && current_limits(2)+adjustment <= maxT && current_limits(1)-adjustment ~= current_limits(2)+adjustment)
            new_limits = [current_limits(1)-adjustment, current_limits(2)+adjustment];
        else
            return;
        end            
        set(gca,'XLim', new_limits);        
        zoomlevel = ((new_limits(2) - new_limits(1)) / 2000);
        neuronlabel = findobj(objs,'Tag','neuronText');
        labelpos = cell2mat(get(neuronlabel,'Position'));
        for i = 1:length(neuronlabel)
            pos = [new_limits(1) + 12 * zoomlevel,labelpos(i,2),labelpos(i,3)];
            set(neuronlabel(i),'Position',pos);
        end    
        zoomlabel = findobj(objs,'Tag','zoomlevelText');
        zoomlabelpos = get(zoomlabel,'Position');
        set(zoomlabel,'String',strcat(num2str(roundn(1/zoomlevel,-3)),'x'),'Position',[new_limits(2)-100*zoomlevel, zoomlabelpos(2), zoomlabelpos(2)]);
        lfpAxis = findobj(objs,'Tag','lfpAxis');        
        [minv maxv] = neuroplot_scaleY(objs,new_limits);
        set(lfpAxis,'XData',[new_limits(1)+12*zoomlevel, new_limits(1)+12*zoomlevel]);
        plotboundary = get(findobj(objs,'Tag','cscPlotboundary'),'YData');
        minbd = plotboundary(1);
        maxbd = maxY+5;
        if (minv < minbd || minv > maxbd)
            minv = minbd * 1.05;                                            
        end
        if (maxv > maxbd || maxv < minv)
            maxv = maxbd * 0.95;                                
        end
        set(lfpAxis,'YData',[minv maxv]);
        lfpAxisUBtext = findobj(objs,'Tag','lfpAxisUB');
        lfpAxisLBtext = findobj(objs,'Tag','lfpAxisLB');
        set(lfpAxisUBtext,'String',strcat(num2str(ceil((maxv-maxY-3)*1000)), ' \muV'),'Position',[new_limits(1)+18*zoomlevel, maxv, 0]);
        set(lfpAxisLBtext,'String',strcat(num2str(ceil((minv-maxY-3)*1000)), ' \muV'),'Position',[new_limits(1)+18*zoomlevel, minv, 0]);
        clearvars zoomlevel current_limits new_upper_bound ydata lfpAxis;
    end        
end


