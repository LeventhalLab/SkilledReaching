function data_by_streak = extractAlternatingTrials(kinematicData,varargin)

includeFirstStreak = false;

numAltTrials = 5;
startProtocol = 'off';

if isrow(kinematicData)
    kinematicData = kinematicData';
end

numTrials = size(kinematicData,1);

if nargin == 2
    trialLabels = varargin{1};
    transitionTrials = diff(trialLabels);
    numTransitions = sum(transitionTrials ~= 0);
    numOnStreaks = sum(transitionTrials == 1);
    numOffStreaks = sum(transitionTrials == -1);
else
    numTransitions = ceil(numTrials/numAltTrials);
    trialLabels = false(numTrials,1);
    if strcmpi(startProtocol,'on')
        curLabel = true;
    else
        curLabel = false;
    end
    
    for ii = 1 : numTransitions
        startIdx = (ii-1) * numAltTrials + 1;
        endIdx = min(ii * numAltTrials,numTrials);
        trialLabels(startIdx:endIdx) = curLabel;
        curLabel = ~curLabel;
    end
    transitionTrials = diff(trialLabels);
    numOnStreaks = sum(transitionTrials == 1);
    numOffStreaks = sum(transitionTrials == -1);
end

onTransitions = find(transitionTrials == 1) + 1;
offTransitions = find(transitionTrials == -1) + 1;

if includeFirstStreak
    if strcmpi(startProtocol,'on')
        numOnStreaks = numOnStreaks + 1;
        onTransitions = [1;onTransitions];
    else
        numOffStreaks = numOffStreaks + 1;
        offTransitions = [1;offTransitions];
    end
end

offData = NaN(numOffStreaks,numAltTrials);
onData = NaN(numOnStreaks,numAltTrials);


for ii = 1 : numOnStreaks
    startIdx = onTransitions(ii);
%     endIdx = offTransitions(ii    % WORKING HERE - MAKE THESE LINE UP
end

end