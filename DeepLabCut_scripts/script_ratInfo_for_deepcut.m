% script to hard code rat information for purposes of trying out deeplabcut

rootPath = fullfile('/Volumes','Tbolt_01','Skilled Reaching');

startRatNum = 216;
endRatNum = 229;

ii = 0;
for ratNum = startRatNum : endRatNum
    if ratNum == 224; continue; end
    ii = ii + 1;
    ratInfo(ii).ratID = ratNum;
    ratInfo(ii).IDstring = sprintf('R%04d',ratNum);
    
    ratPathName = fullfile(rootPath,ratInfo(ii).IDstring);
    cd(ratPathName);
    
    % get the session names for this rat
    sessionDirs = dir([ratInfo(ii).IDstring, '*']);
    numSessions = length(sessionDirs,1);
    ratInfo(ii).sessionList = cell(numSessions);
    for iSession = 1 : numSessions
        ratInfo(ii).sessionList{iSession} = sessionDirs(iSession).name;
    end
    
    switch ratNum
        case 216
            ratInfo(ii).pawPref = 'right';
        case 217
            ratInfo(ii).pawPref = 'left';
        case 218
            ratInfo(ii).pawPref = 'left';
        case 219
            ratInfo(ii).pawPref = 'left';
        case 220
            ratInfo(ii).pawPref = 'right';
        case 221
            ratInfo(ii).pawPref = 'left';
        case 222
            ratInfo(ii).pawPref = 'right';
        case 223
            ratInfo(ii).pawPref = 'right';
        case 225
            ratInfo(ii).pawPref = 'right';
        case 226
            ratInfo(ii).pawPref = 'right';
        case 227
            ratInfo(ii).pawPref = 'right';
        case 228
            ratInfo(ii).pawPref = 'right';
        case 229
            ratInfo(ii).pawPref = 'right';
    end    % switch
            
end

