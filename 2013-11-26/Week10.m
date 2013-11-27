%% Intialize
clear all;clc;
cd('C:\BIOL680\Data\R042-2013-08-18');
start_time = 3250;
finish_time = 5650;

%% Grab some data
sd.fc = FindFiles('*.t');
sd.fc = cat(1,sd.fc,FindFiles('*._t'));
sd.S = LoadSpikes(sd.fc); 
[Timestamps, X, Y, Angles, Targets, Points, Header] = Nlx2MatVT('VT1.nvt', [1 1 1 1 1 1], 1, 1, []);
Timestamps = Timestamps*10^-6;

%% Filter out bad samples
toRemove = (X == 0 & Y == 0);
X = X(~toRemove); Y = Y(~toRemove); Timestamps = Timestamps(~toRemove);

%% Create data and restrict
sd.x = tsd(Timestamps,X');
sd.y = tsd(Timestamps,Y');
for iC = 1:length(sd.S)
    sd.S{iC} = Restrict(sd.S{iC},start_time,finish_time);
end
sd.x = Restrict(sd.x,start_time,finish_time);
sd.y = Restrict(sd.y,start_time,finish_time);

%% Create a plot of the restricted movement
%figure(1);clf;
%plot(Data(sd.x),Data(sd.y),'.','Color',[0.5 0.5 0.5],'MarkerSize',1);
%axis off; hold on;
iC = 5;
spk_x = interp1(Range(sd.x),Data(sd.x),Data(sd.S{iC}),'linear');
spk_y = interp1(Range(sd.y),Data(sd.y),Data(sd.S{iC}),'linear');
%h = plot(spk_x,spk_y,'.r');

%%Estimate the tuning curve

SET_xmin = 10; SET_ymin = 10; SET_xmax = 640; SET_ymax = 480;
SET_nxBins = 63; SET_nyBins = 47;
spk_binned = ndhist(cat(1,spk_x',spk_y'),[SET_nxBins; SET_nyBins],[SET_xmin; SET_ymin],[SET_xmax; SET_ymax]);

%figure(2);clf;
%imagesc(spk_binned');
%axis xy; colorbar;
occ_binned = ndhist(cat(1,Data(sd.x)',Data(sd.y)'),[SET_nxBins; SET_nyBins],[SET_xmin; SET_ymin],[SET_xmax; SET_ymax]);
VT_Fs = 30;
tc = spk_binned./(occ_binned .* (1./VT_Fs)); % firing rate is spike count divided by time 
%pcolor(tc'); shading flat;
%axis xy; colorbar; axis off;

SET_nxBins = 630; SET_nyBins = 470;
kernel = gausskernel([30 30],8);
spk_binned = ndhist(cat(1,spk_x',spk_y'),[SET_nxBins; SET_nyBins],[SET_xmin; SET_ymin],[SET_xmax; SET_ymax]);
spk_binned = conv2(spk_binned,kernel,'same');
occ_binned = ndhist(cat(1,Data(sd.x)',Data(sd.y)'),[SET_nxBins; SET_nyBins],[SET_xmin; SET_ymin],[SET_xmax; SET_ymax]);
occ_binned = conv2(occ_binned,kernel,'same');
occ_binned(occ_binned < 0.01) = 0;
tc = spk_binned./(occ_binned .* (1 / VT_Fs));
tc(isinf(tc)) = NaN;
%figure(3);clf;
%pcolor(tc'); shading flat; axis off;
%axis xy; colorbar;

%% Prepare tuning curves for decoding

kernel = gausskernel([4 4],2); % 2-D gaussian, width 4 bins, SD 2
SET_xmin = 10; SET_ymin = 10; SET_xmax = 640; SET_ymax = 480;
SET_nxBins = 63; SET_nyBins = 47;
spk_binned = ndhist(cat(1,spk_x',spk_y'),[SET_nxBins; SET_nyBins],[SET_xmin; SET_ymin],[SET_xmax; SET_ymax]);
spk_binned = conv2(spk_binned,kernel,'same'); % smoothing
occ_binned = ndhist(cat(1,Data(sd.x)',Data(sd.y)'),[SET_nxBins; SET_nyBins],[SET_xmin; SET_ymin],[SET_xmax; SET_ymax]);
occ_mask = (occ_binned < 5);
occ_binned = conv2(occ_binned,kernel,'same'); % smoothing
occ_binned(occ_mask) = 0; % don't include bins with less than 5 samples
VT_Fs = 30;
tc = spk_binned./(occ_binned .* (1 / VT_Fs));
tc(isinf(tc)) = NaN;
%figure(4);clf;
%pcolor(tc'); shading flat;
%axis xy; colorbar; axis off;
clear tc;
nCells = length(sd.S);
for iC = 1:nCells
    spk_x = interp1(Range(sd.x),Data(sd.x),Data(sd.S{iC}),'linear');
    spk_y = interp1(Range(sd.y),Data(sd.y),Data(sd.S{iC}),'linear');
    spk_binned = ndhist(cat(1,spk_x',spk_y'),[SET_nxBins; SET_nyBins],[SET_xmin; SET_ymin],[SET_xmax; SET_ymax]);
    spk_binned = conv2(spk_binned,kernel,'same');
    tc = spk_binned./(occ_binned .* (1 / VT_Fs));
    tc(isinf(tc)) = NaN;
    sd.tc{iC} = tc;
end
ppf = 25; % plots per figure
%for iC = 1:length(sd.S)
%    nFigure = ceil(iC/ppf);
%    figure(4+nFigure);
%    subplot(5,5,iC-(nFigure-1)*ppf);
%    pcolor(sd.tc{iC}); shading flat; axis off;
%end

%% Prepare firing rates for decoding
binsizes = [0.05, 0.10, 0.25, 0.50]
figure(9);clf;
for bidx = [1:4]
    disp('A');
    clear Q;
    binsize = binsizes(bidx);
    tvec = start_time:binsize:finish_time;
    for iC = length(sd.S):-1:1
        spk_t = Data(sd.S{iC});
        Q(iC,:) = histc(spk_t,tvec);
    end
    nActiveNeurons = sum(Q > 0);
    %figure(7);clf;
    %imagesc(tvec,1:nCells,Q)
    %set(gca,'FontSize',16); xlabel('time(s)'); ylabel('cell #');

    %% Reformat tuning curves

    clear tc
    nBins = numel(occ_binned);
    nCells = length(sd.S);
    for iC = nCells:-1:1
        tc(:,:,iC) = sd.tc{iC};
    end
    tc = reshape(tc,[size(tc,1)*size(tc,2) size(tc,3)]);
    occUniform = repmat(1/nBins,[nBins 1]);

    %% Decoding!

    len = length(tvec);
    p = nan(length(tvec),nBins);
    for iB = 1:nBins
        tempProd = nansum(log(repmat(tc(iB,:)',1,len).^Q));
        tempSum = exp(-binsize*nansum(tc(iB,:),2));
        p(:,iB) = exp(tempProd)*tempSum*occUniform(iB);
    end
    p = p./repmat(sum(p,2),1,nBins);
    p(nActiveNeurons < 1,:) = 0;

    xBinEdges = linspace(SET_xmin,SET_xmax,SET_nxBins+1);
    yBinEdges = linspace(SET_ymin,SET_ymax,SET_nyBins+1);

    xTempD = Data(sd.x); xTempR = Range(sd.x);
    yTempD = Data(sd.y);

    gS = find(~isnan(xTempD) & ~isnan(yTempD));
    xi = interp1(xTempR(gS),xTempD(gS),tvec,'linear');
    yi = interp1(xTempR(gS),yTempD(gS),tvec,'linear');

    xBinned = (xi-xBinEdges(1))./median(diff(xBinEdges));
    yBinned = (yi-yBinEdges(1))./median(diff(yBinEdges));

    %% Visualize
    %{
    figure(8);clf;
    goodOccInd = find(occ_binned > 0);
    for iT = 1:size(p,1)
        cla;
        temp = reshape(p(iT,:),[SET_nxBins SET_nyBins]);
        toPlot = nan(SET_nxBins,SET_nyBins);
        toPlot(goodOccInd) = temp(goodOccInd);

        pcolor(toPlot); axis xy; hold on; caxis([0 0.5]);
        shading flat; axis off;

        hold on; plot(yBinned(iT),xBinned(iT),'ow','MarkerSize',15);

        h = title(sprintf('t %.2f, nCells %d',tvec(iT),nActiveNeurons(iT))); 
        if nActiveNeurons(iT) == 0
            set(h,'Color',[1 0 0]);
        else
            set(h,'Color',[0 0 0]);
        end
        drawnow; pause(0.1);
    end
    %}

    %% And finally...the assignment....
    %% Error!

    %Initialize empty variables. NaN instead of zero to account for potential 0
    %error situations
    MAPdecodedX = NaN(length(p),1);
    MAPdecodedY = NaN(length(p),1);
    %Determine which samples have data, only use those...
    goodReading = find(occ_binned > 0);
    for idx = 1:length(p)
        temp = reshape(p(idx,:),[SET_nxBins SET_nyBins]);
        toPlot = NaN(SET_nxBins,SET_nyBins);
        toPlot(goodReading) = temp(goodReading);
        %Find the MAP indices and write the data, only do so for good samples
        try
            [MAPdecodedY(idx),MAPdecodedX(idx)] = find(toPlot == (max(toPlot(:))));
        end
    end
    decodingErrorX = MAPdecodedX - xBinned.'; %Calculate the error
    decodingErrorY = MAPdecodedY - yBinned.'; %Calculate the error
    decodingErrorTotal = sqrt((decodingErrorX.^2)+(decodingErrorY.^2)); %Calculate the Euclidean distance
    corr_idx = find(~isnan(decodingErrorTotal)); %Filter out any samples we never actually discovered
    subplot(2,2,bidx);
    plot(decodingErrorTotal(corr_idx),'LineWidth',0.1,'color',[0 0 0]);
    title(sprintf('%fms Bin Size', ceil(binsize * 1000)));
    xlabel('Time(s)');ylabel('Error');
end

%Error seems to oscillate following 'correct' decoding and appears
%relatively invariant to the bin size. Perhaps related to theta 
%oscillation from entorhinal and phase-lock decoding? If so, I'd expect
%a bin proportional to theta or lower to result in a change in pattern.
