function plt = eventLFPplot(csc,event_times,varargin)
%--------------------------------------------------------------------------
%eventLFPplot(csc, event_times) plots LFPs for a series of trials within a 
%specified peristimulus window.
%
%Inputs:
%
%   CSC: [1 x 1] TSD containing an LFP signal
%   event_times: [nEvents x 1]  event times to align LFP
%
%Optional:
%
%   t_window: [2 x 1] indicating time window (default: [-1 3])
%   decimate_amt: ratio to decimate the signal by (default: 4)
%   color_on: boolean controlling whether plot is done in color (default:
%             false)
%   filter_on: boolean controlling whether filter is applied (default:
%              false)
%   filter_for: string indicating filter range (default: 'gamma') or 
%                [2 x 1] double indicating a custom filter range
%                1) 'gamma': 40-100 Hz
%                2) 'beta': 10-20 Hz
%                3) 'theta': 6-9 Hz
%                4) 'delta': 3-5 Hz
%--------------------------------------------------------------------------
    clc;
    t_window = [-1 3];    
    decimate_amt = 4;
    color_on = false;
    filter_on = false;
    filter_for = 'gamma';    
    extract_varargin;    
    
    %Sanity checking for custom inputs
    if (isa(decimate_amt,'double')  ~= 1)
        error('decimate_amt must be of type double');
    elseif (length(decimate_amt) ~= 1)
        error('decimate_amt must be a single double');
    elseif (decimate_amt < 1)
        warning('decimate_amt must be positive double. Defaulting to 1!');
        decimate_amt = 1;
    end
    if (isa(color_on,'logical') ~= 1)
        error('color_on must be of boolean type');
    end
    if (isa(filter_on,'logical') ~= 1)
        error('filter_on must be of boolean type');
    else
        if (filter_on == true)
            if (isa(filter_for,'char') ~= 1 && isa(filter_for,'double') ~= 1)
                error('filter_for must be of type string or [2x1] double');
            elseif (isa(filter_for,'double') == 1 && length(filter_for) ~= 2)        
                error('filter_for using custom range must be 2 x 1');
            elseif (isa(filter_for,'char') && (strcmp(filter_for,'gamma') ~= 1 && strcmp(filter_for,'beta') ~= 1 && strcmp(filter_for,'theta') ~= 1 && strcmp(filter_for,'delta') ~= 1))
                error('specified filter_for must be of expected type: gamma, beta, theta, or delta');
            end
        end
    end
       
    %header = getHeader(csc);
    %Fs = header.SamplingFrequency;  
    Fs = 2000;
    
    dataCSC = Data(csc);
    timesCSC = Range(csc);
    
    if (decimate_amt > 1)
        workingData = decimate(dataCSC,decimate_amt);
        workingTimes = downsample(timesCSC,decimate_amt);
        Fs = Fs / decimate_amt;
    else
        workingData = dataCSC;
        workingTimes = timesCSC;
    end
    
    if (filter_on == true)
        switch filter_for
            case 'gamma'
                disp('filtering for gamma');
                filterRange = [40 100];
            case 'beta'
                disp('filtering for beta');
                filterRange = [10 20];
            case 'theta'
                disp('filtering for theta');
                filterRange = [6 9];
            case 'delta'
                disp('filtering for gamma');
                filterRange = [3 5];                
            otherwise
                disp('filtering for custom range');
                filterRange = filter_for;
        end
        Wp = filterRange * 2 / Fs;
        Ws = (filterRange + [-2 2]) * 2 / Fs;
        [N,Wn] = cheb1ord(Wp, Ws, 3, 20);
        [b_c1,a_c1] = cheby1(N,0.5,Wn);
    end
    
    plt = figure;hold on;
    cscale = zeros(1,length(event_times));
    for evt = 1:length(event_times)
        evtIndices = find(workingTimes >= (event_times(evt) + t_window(1)) & workingTimes <= (event_times(evt) + t_window(2)));
        evtData = workingData(evtIndices);
        %Start filter ONLY when required. This should save significant
        %amounts of time in larger data files over processing the entire
        %file in one-go.
        if (filter_on == true)
            evtData = filtfilt(b_c1, a_c1, evtData);
        end                
        cscale(1,evt) = std(evtData);
        %Attempt to optimally scale and offset based on a 300-unit range
        evtData = (300 / (max(evtData) - min(evtData))) * evtData + 300 * (evt-1);
        evtTimes = workingTimes(evtIndices);evtTimes = evtTimes - evtTimes(1) + t_window(1);
        plot(evtTimes,evtData,'color',[0.3 0.3 0.3]);
    end    
    gAxes = get(gcf,'children');
    set(gAxes,'ylim',[-2*300, ((length(event_times) + 1) * 300)],'ytick',[],'xlim',t_window);  
    line([0 0], [-2*300 ((length(event_times)+1)*300)],'color',[0 0 0],'linewidth',2);
    cscaleR = max(cscale) - min(cscale);
    if (color_on == true)
        %Scales the color so that well-represented LFPs (per band) are
        %darkest, but a bit buggy because of how it scales (that is, it
        %depends on the range of all samples, so if there is a restriction
        %of range the scale saturates and all lines are close to it.
        %Luckily this is easily fixed.
        objs = get(gAxes,'children');
        for evt = 1:length(event_times)
            obj = objs(evt + 1); %offset for zero-line
            yd = get(obj,'ydata');
            col = min(max(std(yd) * cscaleR, 0.0),1.0);;
            fprintf('COL %d %d \n', std(yd), col);            
            set(obj,'color',[col col col]);
        end
    end    
    %line([t_window(1) t_window(1)], [0 ((length(event_times)+1)*300)],'color',[0 0 0],'linestyle','--','linewidth',2);
    %line([t_window(2) t_window(2)], [0 ((length(event_times)+1)*300)],'color',[0 0 0],'linestyle','--','linewidth',2);     
    hold off;
    %%Answer to question
    %No. The LFPs fluctuate greatly, even when filtered. The mean may
    %approximate behaviour in a relatively clean signal, but in real data
    %it would likely obscure effects because a large number of different
    %frequency patterns could produce an identical mean. Instead, maybe a
    %measure of deviation or self-similarity might be more appropriate.
end

    

    
