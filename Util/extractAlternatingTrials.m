function extractAlternatingTrials(kinematicData,varargin)

numAltTrials = 5;
startProtocol = 'off';

if isrow(kinematicData)
    kinematicData = kinematicData';
end

numTrials = size(kinematicData,1);

if nargin == 2
    trialLabels = varargin{1};
else
    numTransitions = floor(numTrials/numAltTrials);
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
end

transitionTrials = diff(trialLabels);

% for ii = 1 : numTransitions

end