function reachEndPoints = summarizeRatReachEndPoints(ratFolder,sessionDates)

[~,ratIDstring,~] = fileparts(ratFolder);

% analyze all trial types
validTrialTypes = {0:10};

for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'validtrialtypes'
            validTrialTypes = varargin{iarg + 1};
    end
end

for iDate = 1 : length(sessionDates)
    curDate = sessionDates(iDate);
    dateString = datestr(curDate,'yyyymmdd');
    sessionName = sprintf('%s_%s*',ratIDstring,dateString);
    
    cd(ratFolder);
    sessionFolders = listFolders(sessionName);
    
    if length(sessionFolders) > 1
        keyboard
        % more than one session from this date, figure out how to deal with
        % this later.
    end
    if isempty(sessionFolders)
        fprintf('directory for %s not found.\n',sessionName);
        continue;
    end
    
    sessionFolder = fullfile(ratFolder,sessionFolders{1});
    cd(sessionFolder);
    sessionSummaryName = [sessionName '_kinematicsSummary.mat'];
    sessionSummaryMat = dir(sessionSummaryName);
    
    load(sessionSummaryMat.name);
    [reachEndPoints{iDate},~] = collectReachEndPoints(all_endPts,validTrialTypes,all_trialOutcomes);
    
end