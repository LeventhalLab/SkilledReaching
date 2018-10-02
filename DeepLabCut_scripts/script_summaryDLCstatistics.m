% script_summaryDLCstatistics

mean_p_figProps.m = 4;
mean_p_figProps.n = 2;

mean_p_figProps.panelWidth = ones(mean_p_figProps.n,1) * 9;
mean_p_figProps.panelHeight = ones(mean_p_figProps.m,1) * 5;

mean_p_figProps.colSpacing = ones(mean_p_figProps.n-1,1) * 0.5;
mean_p_figProps.rowSpacing = ones(mean_p_figProps.m-1,1) * 1;

mean_p_figProps.width = 8.5 * 2.54;
mean_p_figProps.height = 11 * 2.54;

mean_p_figProps.topMargin = 2;
mean_p_figProps.leftMargin = 2.54;

mean_p_timeLimits = [-0.5,2];

labeledBodypartsFolder = '/Volumes/Tbolt_01/Skilled Reaching/DLC output';

script_ratInfo_for_deepcut;
ratInfo_IDs = [ratInfo.ratID];

ratFolders = findRatFolders(labeledBodypartsFolder);
numRatFolders = length(ratFolders);

for i_rat = 1 : numRatFolders
    
    ratID = ratFolders{i_rat};
    ratIDnum = str2double(ratID(2:end));
    
    ratInfo_idx = find(ratInfo_IDs == ratIDnum);
    if isempty(ratInfo_idx)
        error('no entry in ratInfo structure for rat %d\n',C{1});
    end
    thisRatInfo = ratInfo(ratInfo_idx);
    pawPref = thisRatInfo.pawPref;
    
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    
    cd(ratRootFolder);
    DLCstatsFolder = fullfile(ratRootFolder,[ratID '_DLCstats']);
    
    if ~exist(DLCstatsFolder,'dir')
        mkdir(DLCstatsFolder);
    end
    
    sessionDirectories = listFolders([ratID '_2*']);   % all were recorded after the year 2000
    numSessions = length(sessionDirectories);
    
    numRatPages = 0;
    for iSession = 1 : numSessions
    
        C = textscan(sessionDirectories{iSession},[ratID '_%8c']);
        sessionDate = C{1};
    
        fullSessionDir = fullfile(ratRootFolder,sessionDirectories{iSession});
        
        cd(fullSessionDir);
        
        matList = dir([ratID '_*_3dtrajectory.mat']);
        numTrials = length(matList);
        
        try
        load(matList(1).name);
        catch
            keyboard
        end
        t = linspace(frameTimeLimits(1),frameTimeLimits(2), size(pawTrajectory,1));
        all_p_direct = zeros(size(direct_p,1),size(direct_p,2),numTrials);
        all_p_mirror = zeros(size(mirror_p,1),size(mirror_p,2),numTrials);
        
        for iTrial = 1 : numTrials
            
            load(matList(iTrial).name);
            
            all_p_direct(:,:,iTrial) = direct_p;
            all_p_mirror(:,:,iTrial) = mirror_p;
            
        end
        
        mean_p_direct = mean(all_p_direct,3);
        mean_p_mirror = mean(all_p_mirror,3);
        
        rowNum = mod(iSession, mean_p_figProps.m);
        if rowNum == 0
            rowNum = mean_p_figProps.m;
        end
        if rowNum == 1
            [h_fig,h_axes] = createFigPanels5(mean_p_figProps);
            currentSessionList = {[ratID '\_' sessionDate]};
            h_figAxis = createFigAxes(h_fig);
        else
            currentSessionList{rowNum} = [ratID '\_' sessionDate];
        end
        
        axes(h_axes(rowNum,1));
        imagesc(t, 1:length(bodyparts), mean_p_direct)
        set(gca,'clim',[0 1],'xlim',mean_p_timeLimits);
        set(gca,'ytick',1:16,'yticklabel',bodyparts);
        if rowNum == 1
            title('direct view');
        end
        
        axes(h_axes(rowNum,2));
        imagesc(t, 1:length(bodyparts), mean_p_mirror)
        set(gca,'clim',[0 1],'xlim',mean_p_timeLimits,'ytick',[]);
        if rowNum == 1
            title('mirror view');
        end
        
        if rowNum == mean_p_figProps.m || iSession == numSessions
            textString{1} = 'mean p-values for DLC point detection';
            textString{2} = sprintf('sessions: %s', currentSessionList{1});
            for ii = 2 : rowNum
                textString{2} = sprintf('%s, %s', textString{2},currentSessionList{ii});
            end
            
            axes(h_figAxis);
            text(mean_p_figProps.leftMargin,mean_p_figProps.height-0.5,textString,'units','centimeters');
            
            numRatPages = numRatPages + 1;
            
            mean_p_summaryName = sprintf('%s_mean_p_heatmaps_%02d',ratID,numRatPages);
            
            mean_p_summaryName = fullfile(DLCstatsFolder,mean_p_summaryName);
            mean_p_figName = [mean_p_summaryName '.fig'];
            mean_p_pdfName = [mean_p_summaryName '.pdf'];
            
            print(mean_p_pdfName, '-dpdf');
            savefig(mean_p_figName);
            
            close(h_fig);
        end
%         set(gca,'ytick',1:16,'yticklabel',bodyparts);

        
            
        % TO DO:
        %   1) set up a sheet to make a mean_p heat map for the direct and
        %   mirror views for each session
        %   3) make at least one colorbar
    end
    
end
% mean p-value as a function of frame number