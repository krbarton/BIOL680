function week2_lesson_HandleFigureKeypresses(obj,event)
    %This function handles any keypresses for a figure    
    % Left and Right move through the data
    keypressed = event.Key;
    disp(keypressed);
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
        current_range = current_limits(2) - current_limits(1);
        adjustment = (0.5 * current_range) * direction;
        %Retrieve the axis data and make sure we don't move beyond the
        %range of the data
        xdata = get(get(gca,'Children'),'XData');
        real_limits = cell2mat(xdata(1,1));
        new_limits = current_limits + adjustment;
        if new_limits(1) >= real_limits(1) && new_limits(2) <= real_limits(2)
            set(gca,'XLim', current_limits + adjustment);
        end
        %Clear the variables, for good housekeeping. Probably not necessary   
        clearvars direction current_limits current_range adjustment xdata new_limits real_limits;
    end
    if (strcmp(keypressed,'uparrow') || strcmp(keypressed,'downarrow')|| strcmp(keypressed,'w') || strcmp(keypressed,'s'))
        disp('Zoom!');       
    end
end

