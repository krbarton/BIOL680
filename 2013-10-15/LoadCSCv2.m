function finaldata = LoadCSCv2(filename, varargin)
%Creates a TSD file from a Neurolynx CSC file
%
%Optional parameters:
% TimeUnits = ms or s (defaults to S)
% VoltageUnits = V, mV, or uV (defaults to mV)
% DisplayBlock = # (block found in matching ExpKeys files to save; defaults to all data)
% LoadRange = [start end] (loads data within a specific time range (s))
    TimeUnits = 's';
    VoltageUnits = 'mV';
    DisplayBlock = 0;
    LoadRange = [];
    extract_varargin;    
    [times, ~, sampledFrequencies, numSamples, data, header] = Nlx2MatCSC(filename, [1 1 1 1 1], 1, 1, []);
    compiledHeader = readCSCHeader(header);
    %[csc1, csc_info1] = LoadCSC('C:\BIOL680\Data\R016-2012-10-08\R016-2012-10-08-CSC03b.ncs');
    unblockedData = reshape(data,numel(data),1); %Convert data to continuous stream nx1 matrix    
    if ((length(unblockedData)/compiledHeader.SamplingFrequency) ~= length(times))        
        missingTime = length(times) - (length(unblockedData)/compiledHeader.SamplingFrequency);
        if (missingTime > 0)            
            warning('Gaps found in the data');
        else
            warning('Too much data found');
        end
    end
    if (missingTime || DisplayBlock > 0)        
        run(FindFile('*keys.m'));
        if (isempty(ExpKeys))
            warning('Cannot find ExpKeys file. Unable to select only active recording sessions.');
        else
            disp('Loading ExpKeys');
            onTask =  ExpKeys.TimeOnTrack;
            offTask = ExpKeys.TimeOffTrack;            
        end        
        fprintf('Found %d blocks!\n', min([length(onTask) length(offTask)]));
        if (DisplayBlock > length(onTask) || DisplayBlock > length(offTask))
            warning('Selected block %d but only %d found. Defaulting to showing all data.', DisplayBlock, min([length(onTask), length(offTask)]));
            DisplayBlock = 0;
        end
    end    
    
    %%Allow the person to select the voltage units, optionally
    %Default to millivolts
    if (strcmp(VoltageUnits,'V'))
        voltAdj = 1;
    elseif (strcmp(VoltageUnits,'uV'))
        voltAdj = 10^6;
    else
        voltAdj = 10^3;
    end        
    %%Calculate voltage in the appropriate units
    vData = unblockedData.*compiledHeader.ADBitVolts.*voltAdj;    
    %%Allow person to select the time units
    if (strcmp(TimeUnits,'ms'))        
        timeAdj = 10^-3;
    else
        timeAdj = 10^-6;        
    end
    %%Reconstruct intermediate times between blocks
    timesS = repmat(times,[size(data,1),1]).*timeAdj;
    dt = (0:size(data,1)-1)*(1/compiledHeader.SamplingFrequency);
    timeAdjustment = repmat(dt.', [1, size(data,2)]);
    timeSAdjusted = reshape(timesS + timeAdjustment,numel(timesS),1);
    if (~isempty(onTask) && ~isempty(offTask) || length(LoadRange)==2)
       if (strcmp(TimeUnits,'ms'))
          onTask = onTask.*10^3;
          offTask = offTask.*10^3;          
       end
       if (DisplayBlock)
           fprintf('Loading block %d [From: %d To: %d]\n', DisplayBlock, onTask(DisplayBlock),offTask(DisplayBlock));
           indices = find(timeSAdjusted>=onTask(DisplayBlock) & timeSAdjusted<=offTask(DisplayBlock));
           vData = vData(indices);
           timeSAdjusted = timeSAdjusted(indices);           
       elseif (length(LoadRange)==2)
           indices = find(timeSAdjusted>=LoadRange(1) & timeSAdjusted<=LoadRange(2));
           vData = vData(indices);
           timeSAdjusted = timeSAdjusted(indices);           
       end      
    end
    %Filter out negative time samples
    indices = find(diff(timeSAdjusted)>0);
    fprintf('Removing %d badly timed samples\n', length(vData) - length(indices));
    vData = vData(indices);
    timeSAdjusted = timeSAdjusted(indices);
    %Filter out data that seems problematic
    %indices = find(vData ~= 0);
    %fprintf('Removing %d samples with zero values\n', length(vData) - length(indices));
    %vData = vData(indices);
    %timeSAdjusted = timeSAdjusted(indices);
    %Spit out the result
    finaldata = mytsd(timeSAdjusted,vData,compiledHeader);  
end

function csc_info = readCSCHeader(Header)
%Borrowed from original function, my code is below, with strings being
%treated as cells
    csc_info = [];
    for hline = 1:length(Header)   
        line = strtrim(Header{hline});    
        if isempty(line) | ~strcmp(line(1),'-') % not an informative line, skip
            continue;
        end    
        a = regexp(line(2:end),'(?<key>\w+)\s+(?<val>\S+)','names');    
        % deal with characters not allowed by MATLAB struct
        if strcmp(a.key,'DspFilterDelay_µs')
            a.key = 'DspFilterDelay_us';
        end    
        csc_info = setfield(csc_info,a.key,a.val);    
        % convert to double if possible
        if ~isnan(str2double(a.val))
            csc_info = setfield(csc_info,a.key,str2double(a.val));
        end
    
    end
end

%{
function header_info = readHeader(raw_header)
    header_info = [];
    for l = 1:length(raw_header)
        line = raw_header(l);
        text = strtrim(line);
        if (isempty(text) || strcmp(text{1},'-')==1 || strcmp(text{1},'#')==1)
            disp('Skip');
            continue;
        else
            disp('Go');
            contents = regexp(str(text{2:end}),'(?<key>\w+)\s+(?<val>\S+)','names');
            contents
            continue
            if (strcmp(contents.key,'DspFilterDelay_µs') == 1)
                contents.key = 'DspFilterDelay_us';
            end
            if (~isnan(str2double(contents.val)))
                %header_info.(contents.key) = str2double(contents.val);
                header_info = setfield(header_info,contents.key,str2double(contents.val));
            else
                %header_info.(contents.key) = contents.val;
                header_info = setfield(header_info,contents.key,contents.val);
            end                
        end
    end            
end

%}