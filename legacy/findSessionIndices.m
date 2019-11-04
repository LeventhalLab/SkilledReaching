function [baselineIdx,laserIdx,occIdx] = findSessionIndices(sessionType)

numSessions = length(sessionType);

baselineIdx = [];
laserIdx = [];
occIdx = [];
for iSession = 1 : numSessions
    
    switch sessionType(iSession).type
        case 'training'
            baselineIdx = [baselineIdx,iSession];
        case {'laser_during','laser_between'}
            laserIdx = [laserIdx,iSession];
        case {'occlusion','post_occlusion'}
            occIdx = [occIdx,iSession];
    end
end