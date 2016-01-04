function [x1_left,x2_left,x1_right,x2_right,mp_metadata] = generateMatchedPointVectors(matchedPoints, varargin)
%
% INPUTS:
%   matchedPoints - matched points structure output from
%       read_xl_matchedPoints
%   
%
% OUTPUTS:
%   x1,x2 - 
%   sessionNames - 


% exclude points for which I'm not confident of the match
excludePoints = {'left_bottom_box_corner','right_bottom_box_corner'};

sessionNames = fieldnames(matchedPoints);
mp_metadata.sessionNames = sessionNames;

numSessions = length(sessionNames);

x1_left = cell(1,numSessions);
x2_left = cell(1,numSessions);

x1_right = cell(1,numSessions);
x2_right = cell(1,numSessions);

for iSession = 1 : numSessions
    curSession = matchedPoints.(sessionNames{iSession});
    
    % need to find points for which there is both a direct and left point
    leftMirrorPoints = {};
    leftPointNames = fieldnames(curSession.leftMirror);
    numValidPoints = 0;
    x1_left{iSession} = zeros(1,2);
    x2_left{iSession} = zeros(1,2);
    for ii = 1 : length(leftPointNames)
        pointMatch = strcmp(leftPointNames{ii}, excludePoints);
        if any(pointMatch(:)); continue; end
        
        if any(isnan(curSession.leftMirror.(leftPointNames{ii})))
            continue;
        end
        
        % check to see if this point is also valid in the direc view
        if any(isnan(curSession.direct.(leftPointNames{ii})))
            continue;
        end
        
        numValidPoints = numValidPoints + 1;
        leftMirrorPoints{numValidPoints} = leftPointNames{ii};
        x1_left{iSession}(numValidPoints,:) = curSession.direct.(leftPointNames{ii});
        x2_left{iSession}(numValidPoints,:) = curSession.leftMirror.(leftPointNames{ii});
    end
    mp_metadata.leftMirrorPointNames{iSession} = leftMirrorPoints;
    
    rightMirrorPoints = {};
    rightPointNames = fieldnames(curSession.rightMirror);
    numValidPoints = 0;
    x1_right{iSession} = zeros(1,2);
    x2_right{iSession} = zeros(1,2);
    for ii = 1 : length(leftPointNames)
        pointMatch = strcmp(rightPointNames{ii}, excludePoints);
        if any(pointMatch(:)); continue; end
        
        if any(isnan(curSession.rightMirror.(rightPointNames{ii})))
            continue;
        end
        
        % check to see if this point is also valid in the direc view
        if any(isnan(curSession.direct.(rightPointNames{ii})))
            continue;
        end
        
        numValidPoints = numValidPoints + 1;
        rightMirrorPoints{numValidPoints} = rightPointNames{ii};
        x1_right{iSession}(numValidPoints,:) = curSession.direct.(rightPointNames{ii});
        x2_right{iSession}(numValidPoints,:) = curSession.rightMirror.(rightPointNames{ii});
    end
    mp_metadata.rightMirrorPointNames{iSession} = rightMirrorPoints;
    
end
