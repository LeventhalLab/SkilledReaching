function alternateSessions = identifyAlternateSessions(ratInfo, laserOnTiming, laserOffTiming, varargin)
%
% INPUTS
%
% OUTPUTS
%


DLCoutput_folder = '/Volumes/LL EXHD #2/DLC output';

for iarg = 1 : 2 : nargin - 3
    switch lower(varargin{iarg})
        case 'dlcoutput_folder'
            DLCoutput_folder = varargin{iarg + 1};
    end
end

% find only ChR2 rats
% ChR2_rows = ratInfo.Virus == 'ChR2';
% ChR2_ratInfo = ratInfo(ChR2_rows,:);
% num_ChR2_rats = size(ChR2_ratInfo,1);

num_rats = size(ratInfo,1);
num_valid_alternate_sessions = 0;

for i_rat = 1 : num_rats
    
    ratID = ratInfo(i_rat,:).ratID;
    ratIDstring = sprintf('R%04d',ratID);
    current_rat_folder = fullfile(DLCoutput_folder,ratIDstring);
    
    if ~isfolder(current_rat_folder)
        continue
    end
    cd(current_rat_folder);
    
    sessionCSV = [ratIDstring '_sessions.csv'];
    sessionTable = readSessionInfoTable(sessionCSV);
    
    % find sessions where laserTrialSetting is "alternate", laserOnTiming
    % and laserOfftTiming match inputs
    
    alternateRows = sessionTable.laserTrialSetting == 'alternate';
    laserOnRows = sessionTable.laserOnTiming == laserOnTiming;
    laserOffRows = sessionTable.laserOffTiming == laserOffTiming;
    
    validAlternateRows = alternateRows & laserOnRows & laserOffRows;
    
    if any(validAlternateRows)
        if num_valid_alternate_sessions == 0
            alternateSessions = sessionTable(validAlternateRows,:);
        else
            alternateSessions = outerjoin(alternateSessions,sessionTable(validAlternateRows,:),'mergekeys',true);
        end
        num_valid_alternate_sessions = num_valid_alternate_sessions + sum(validAlternateRows);
    end
    
end

