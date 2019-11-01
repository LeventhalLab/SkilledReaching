function sessionIdx = identifyAlternateStimIdx(alternateKinematics,ratNum,sessionDate)

sessionIdx = [];
numSessions = length(alternateKinematics);

for iSession = 1 : numSessions
    
    if isempty(alternateKinematics(iSession).ratID)
        continue;
    end
    if alternateKinematics(iSession).ratID == ratNum && ...
            alternateKinematics(iSession).sessionDate == sessionDate
        
        sessionIdx = iSession;
    end
end