% script to hard code rat information for purposes of trying out deeplabcut

rootPath = fullfile('/Volumes','Tbolt_01','Skilled Reaching');

startRatNum = 186;
endRatNum = 229;

if exist('ratInfo','var')
    clear ratInfo
end
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
            ratInfo(ii).digitColors = ['g','p','b','y','r'];   % index finger, middle finger, ring finger, pinky, dorsum.
                                                               % g = green, p = purple, b = blue, y = yellow, r = red
        case 187
            ratInfo(ii).pawPref = 'right';
            ratInfo(ii).firstTattooedSession = '20170918';   % actually earlier, but first session we're looking at for now
            ratInfo(ii).digitColors = ['g','p','b','y','r'];
        case 189
            ratInfo(ii).pawPref = 'right';
            ratInfo(ii).firstTattooedSession = '20171014';
            ratInfo(ii).digitColors = ['g','p','y','b','r'];
        case 191
            ratInfo(ii).pawPref = 'left';
            ratInfo(ii).firstTattooedSession = '20170916';
            ratInfo(ii).digitColors = ['g','p','b','y','r'];
        case 193
            ratInfo(ii).pawPref = 'right';
            ratInfo(ii).firstTattooedSession = '20171014';   % actually earlier, but first session we're looking at for now
            ratInfo(ii).digitColors = ['g','p','y','b','r'];
        case 195
            ratInfo(ii).pawPref = 'right';
            ratInfo(ii).firstTattooedSession = '20171014';   % actually earlier, but first session we're looking at for now
            ratInfo(ii).digitColors = ['g','p','y','b','r'];
        case 216
            ratInfo(ii).pawPref = 'right';
            ratInfo(ii).firstTattooedSession = '20180201';
            ratInfo(ii).digitColors = ['g','p','y','b','r'];
        case 217
            ratInfo(ii).pawPref = 'left';
            ratInfo(ii).firstTattooedSession = '20180201';
            ratInfo(ii).digitColors = ['g','p','y','b','r'];
        case 218
            ratInfo(ii).pawPref = 'left';
            ratInfo(ii).firstTattooedSession = '20180202';
            ratInfo(ii).digitColors = ['g','p','y','b','r'];
        case 219
            ratInfo(ii).pawPref = 'left';
            ratInfo(ii).firstTattooedSession = '20180213';
            ratInfo(ii).digitColors = ['g','p','y','b','r'];
        case 220
            ratInfo(ii).pawPref = 'right';
            ratInfo(ii).firstTattooedSession = '20180213';
            ratInfo(ii).digitColors = ['g','p','y','b','r'];
        case 221
            ratInfo(ii).pawPref = 'left';
            ratInfo(ii).firstTattooedSession = '20180315';
            ratInfo(ii).digitColors = ['g','p','y','b','r'];
        case 222
            ratInfo(ii).pawPref = 'left';
            ratInfo(ii).firstTattooedSession = '20180315';
            ratInfo(ii).digitColors = ['g','p','y','b','r'];
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

