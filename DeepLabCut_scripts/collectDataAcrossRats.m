function experimentSummary = collectDataAcrossRats(ratTable,sessionTables,varargin)

% experimentSummary is a structure array where element 1 is for session 1
% across rats, element 2 is session 2 across rats, etc.

DLCdirectory = '/Volumes/LL EXHD #2/DLC output';

% data to collect in experimentSummary
%   


for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'dlcdirectory'
            DLCdirectory = varargin{iarg + 1};
    end
end

% figure out what the maximum number of sessions in any of the session
% tables
maxSessions = 0;
for ii = 1 : length(sessionTables)
    maxSessions = max(maxSessions, size(sessionTables{ii},1));
end
numRats = size(ratTable,1);

experimentSummary.outcomeRates = zeros(numRats, maxSessions, 5);
experimentSummary.num_omitted_trials = zeros(numRats,maxSessions);
experimentSummary.numValidTrials = zeros(numRats,maxSessions);
for iSession = 1 : maxSessions
    
    for i_rat = 1 : numRats
        cur_rat = ratTable(i_rat,:);
        cur_session = sessionTables{i_rat}(iSession,:);
        
        ratID = cur_rat.ratID;
        ratIDstring = sprintf('R%04d',ratID);
        
        rat_DLCfolder = fullfile(DLCdirectory,ratIDstring);
        sessionDateString = datestr(cur_session.date,'yyyymmdd');
        
        [sessionSummaryName,sessionSummary_exists] = ...
            findSessionSummary(ratID,cur_session.date,'dlcdirectory',DLCdirectory);
        load(sessionSummaryName);
        
        [experimentSummary.outcomeRates(i_rat,iSession,:),experimentSummary.num_omitted_trials(i_rat,iSession)] = ...
            calculateSessionOutcomes(all_trialOutcomes);
        
        experimentSummary.numValidTrials(i_rat,iSession) = length(all_trialOutcomes) - experimentSummary.num_omitted_trials(i_rat,iSession);
        
        pawPref = cur_rat.pawPref;
        if iscell(pawPref)
            pawPref = pawPref{1};
        end
        determineTrialTrajectories(squeeze(allTrajectories(:,:,:,1)), bodyparts, pawPref);
        [reachTrajectories,reachEndFrames] = collectReachTrajectories(all_trialOutcomes,allTrajectories,all_reachFrameIdx,10,bodyparts,1,pawPref);
        
    end
    
end
        
        