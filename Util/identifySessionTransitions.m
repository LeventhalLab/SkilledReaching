function sessionBlockLabels = identifySessionTransitions(sessionTable)

% logic is that if the following session characteristics are the same
% between consecutive sessions, these sessions are part of the same block
%   trainingStage - 'training' or 'testing'
%   laserStim - 'none', 'on', or 'occlude'
%   laserTrialSetting - 'probability' or 'alternate'
%   laserProbability - numeric value between 0 and 100
%   laserOnTiming - 'beambreak', 'vidTrigger+4000'
%   laserOffTiming - 'vidTrigger+3000','laserOn+5000'

sessionParameters_to_check = {'trainingStage','laserStim','laserProbability','laserOnTiming','laserOffTiming'};
numSessions = size(sessionTable,1);

sessionBlockLabels = ones(numSessions,1);

for i_param = 1 : length(sessionParameters_to_check)
    curParamValue{i_param} = sessionTable.(sessionParameters_to_check{i_param})(1);
end
blockNumber = 1;
for iSession = 2 : numSessions
    
    for i_param = 1 : length(sessionParameters_to_check)
        newParamValue{i_param} = sessionTable.(sessionParameters_to_check{i_param})(iSession);
    end
    allValuesMatch = true;
    for i_param = 1 : length(sessionParameters_to_check)
        
        if ischar(curParamValue{i_param})
            if ~strcmp(curParamValue{i_param},newParamValue{i_param})
                allValuesMatch = false;
            end
        elseif iscategorical(curParamValue{i_param})
            if isundefined(curParamValue{i_param}) && isundefined(newParamValue{i_param})
                continue;
            end
            if curParamValue{i_param} ~= newParamValue{i_param}
                allValuesMatch = false;
            end
        else
            if curParamValue{i_param} ~= newParamValue{i_param}
                allValuesMatch = false;
            end
        end
        
    end
    
    if ~allValuesMatch
        blockNumber = blockNumber + 1;
        sessionBlockLabels(iSession:end) = blockNumber;
        for i_param = 1 : length(sessionParameters_to_check)
            curParamValue{i_param} = newParamValue{i_param};
        end
    end

end