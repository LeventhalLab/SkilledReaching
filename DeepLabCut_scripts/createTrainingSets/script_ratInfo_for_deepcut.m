% script to hard code rat information for purposes of trying out deeplabcut

rootPath = fullfile('/Volumes','Tbolt_01','Skilled Reaching');

startRatNum = 186;
endRatNum = 229;

ii = 0;
for ratNum = startRatNum : endRatNum

    
    IDstring = sprintf('R%04d',ratNum);
    ratPathName = fullfile(rootPath,IDstring);
    if ~isfolder(ratPathName);continue;end
    
    ii = ii + 1;
    
    ratInfo(ii).ratID = ratNum;
    ratInfo(ii).IDstring = IDstring;
    
    cd(ratPathName);
    
    % get the session names for this rat
    sessionDirs = dir([ratInfo(ii).IDstring, '*']);
    numSessions = length(sessionDirs);
    ratInfo(ii).sessionList = cell(numSessions,1);
    ratInfo(ii).numVids = zeros(numSessions,1);
    
    for iSession = 1 : numSessions
        ratInfo(ii).sessionList{iSession} = sessionDirs(iSession).name;
        sessionDirName = fullfile(ratPathName, sessionDirs(iSession).name);
        cd(sessionDirName);
        vidList = dir('R*.avi');
        ratInfo(ii).numVids(iSession) = length(vidList);
    end
    
    switch ratNum
        case 186
            ratInfo(ii).pawPref = 'right';
            ratInfo(ii).firstTattooedSession = '20170813';   % actually earlier, but first session we're looking at for now
        case 187
            ratInfo(ii).pawPref = 'right';
            ratInfo(ii).firstTattooedSession = '20170918';   % actually earlier, but first session we're looking at for now
        case 189
            ratInfo(ii).pawPref = 'right';
            ratInfo(ii).firstTattooedSession = '20171014';
        case 191
            ratInfo(ii).pawPref = 'left';
            ratInfo(ii).firstTattooedSession = '20171014';
        case 193
            ratInfo(ii).pawPref = 'right';
            ratInfo(ii).firstTattooedSession = '20170916';   % actually earlier, but first session we're looking at for now
        case 195
            ratInfo(ii).pawPref = 'right';
            ratInfo(ii).firstTattooedSession = '20171014';   % actually earlier, but first session we're looking at for now
        case 216
            ratInfo(ii).pawPref = 'right';
            ratInfo(ii).firstTattooedSession = '20180201';
        case 217
            ratInfo(ii).pawPref = 'left';
            ratInfo(ii).firstTattooedSession = '20180201';
        case 218
            ratInfo(ii).pawPref = 'left';
            ratInfo(ii).firstTattooedSession = '20180202';
        case 219
            ratInfo(ii).pawPref = 'left';
            ratInfo(ii).firstTattooedSession = '20180213';
        case 220
            ratInfo(ii).pawPref = 'right';
            ratInfo(ii).firstTattooedSession = '20180213';
        case 221
            ratInfo(ii).pawPref = 'left';
            ratInfo(ii).firstTattooedSession = '20180315';
        case 222
            ratInfo(ii).pawPref = 'left';
            ratInfo(ii).firstTattooedSession = '20180315';
        case 223
            ratInfo(ii).pawPref = 'left';
            ratInfo(ii).firstTattooedSession = '';
        case 225
            ratInfo(ii).pawPref = 'right';
            ratInfo(ii).firstTattooedSession = '';
        case 226
            ratInfo(ii).pawPref = 'left';
            ratInfo(ii).firstTattooedSession = '';
        case 227
            ratInfo(ii).pawPref = 'right';
            ratInfo(ii).firstTattooedSession = '';
        case 228
            ratInfo(ii).pawPref = 'left';
            ratInfo(ii).firstTattooedSession = '';
        case 229
            ratInfo(ii).pawPref = 'left';
            ratInfo(ii).firstTattooedSession = '';
    end    % switch
            
end

