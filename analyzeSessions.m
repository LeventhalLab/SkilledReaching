% >> analyzeSessions(150,0.1053,STRUCT(left,center,right))
function analyzeSessions(frameRate,pxToMm,pelletCoords)
    workingDirectory = uigetdir;
    leftSessions = dir(fullfile(workingDirectory,'left','sessions','*.mat'));
    centerSessions = dir(fullfile(workingDirectory,'center','sessions','*.mat'));
    rightSessions = dir(fullfile(workingDirectory,'right','sessions','*.mat'));
    
    % should do some basic checks on quantity and display error if session count is unequal
    
    allLeftPawCenters = loadPawCenters(leftSessions,fullfile(workingDirectory,'left','sessions'));
    allCenterPawCenters = loadPawCenters(centerSessions,fullfile(workingDirectory,'center','sessions'));
    allRightPawCenters = loadPawCenters(rightSessions,fullfile(workingDirectory,'right','sessions'));
    
    allXyzPawCenters = cell(1,numel(leftSessions));
    for i=1:numel(leftSessions)
        allXyzPawCenters{i} = createXyzPawCenters(allLeftPawCenters{i},allCenterPawCenters{i},...
            allRightPawCenters{i},pelletCoords);
        allXyzPawCenters{i} = allXyzPawCenters{i}.*pxToMm;
        %xyzPawCenters = smoothn(xyzPawCenters);
    end
    
    allXyzDistPawCenters = cell(1,numel(leftSessions));
    for i=1:numel(leftSessions)
        allXyzDistPawCenters{i} = createXyzDistPawCenters(allXyzPawCenters{i});
    end

    allAlignedXyzPawCenters = cell(1,numel(leftSessions));
    allAlignedXyzDistPawCenters = cell(1,numel(leftSessions));
    for i=25:numel(leftSessions)
        [allAlignedXyzPawCenters{i},allAlignedXyzDistPawCenters{i}] = alignData(allXyzPawCenters{i},allXyzDistPawCenters{i});
    end
    
    mkdir(fullfile(workingDirectory,'_xyzData'));
    save(fullfile(workingDirectory,'_xyzData','xyzData'),'allAlignedXyzPawCenters','allAlignedXyzDistPawCenters',...
        'allXyzPawCenters','allXyzDistPawCenters');
    
    h1 = plot1dDistance(allAlignedXyzDistPawCenters);
    saveas(h1,fullfile(workingDirectory,'_xyzData','1dDistancePlot'),'png');
    saveas(h1,fullfile(workingDirectory,'_xyzData','1dDistancePlot'),'fig');

    h2 = plot3dDistance(allAlignedXyzPawCenters);
    % use view() to rotate and save a couple angles
    saveas(h2,fullfile(workingDirectory,'_xyzData','3dDistancePlot'),'png');
    saveas(h2,fullfile(workingDirectory,'_xyzData','3dDistancePlot'),'fig');
end

function [alignedXyzPawCenters,alignedXyzDistPawCenters]=alignData(xyzPawCenters,xyzDistPawCenters)
    % find frame index that distance crosses a minimum distance threshold
    for shiftIndex=1:numel(xyzDistPawCenters)
        if(xyzDistPawCenters(shiftIndex) < 10)
           break;
        end
    end
    % apply the shift index if it sits somewhere near the middle of the video, otherwise we can
    % assume it is bad data
    alignedXyzPawCenters = NaN(200,3);
    alignedXyzDistPawCenters = NaN(200,1);
    if(shiftIndex > 100 && shiftIndex < 200) % less than this is a bad reach/data
        alignedXyzPawCenters(1:numel(xyzDistPawCenters(shiftIndex-50:end)),:) =...
            xyzPawCenters(shiftIndex-50:end,:);
        alignedXyzDistPawCenters(1:numel(xyzDistPawCenters(shiftIndex-50:end))) =...
            xyzDistPawCenters(shiftIndex-50:end);
    end
end

% xyzPawCenters is a cell above, but a is just a single array here
function xyzDistPawCenters=createXyzDistPawCenters(xyzPawCenters)
    frameCount = size(xyzPawCenters,1);
    xyzDistPawCenters = NaN(frameCount,1);
    for i=1:frameCount
        % need all 3 coordinates to accurately assess distance
        if(sum(isnan(xyzPawCenters(i,:)))==0)
            pawCenters = xyzPawCenters(i,:);
            % dist = sqrt(x^2+y^2+z^2)
            xyzDistPawCenters(i) = sqrt(sum(pawCenters(~isnan(pawCenters)).^2));
        else
            xyzDistPawCenters(i) = NaN;
        end
    end
end

% creates xyz data for a single session (a.k.a. single video)
function xyzPawCenters=createXyzPawCenters(leftPawCenters,centerPawCenters,rightPawCenters,pelletCoords)
    % x=C, y=mean(L,R), z=mean(L,C,R)
    frameCount = size(leftPawCenters,1);
    xyzPawCenters = NaN(frameCount,3);
    for i=1:frameCount
        % calculate x
        if(~isnan(centerPawCenters(i,1)))
            xyzPawCenters(i,1) = pelletCoords.center(1)-centerPawCenters(i,1); % x-axis
        else
            xyzPawCenters(i,1) = NaN;
        end
        % calculate y
        if(~isnan(leftPawCenters(i,1)) && ~isnan(rightPawCenters(i,1)))
            % these equations are intentionally reversed to account for the mirroring, making the
            % x-axis always more negative as it extends inwards into the box
            leftDist = pelletCoords.left(1)-leftPawCenters(i,1); % x-axis
            rightDist = rightPawCenters(i,1)-pelletCoords.right(1); % x-axis
            xyzPawCenters(i,2) = mean([leftDist,rightDist]);
        elseif(~isnan(leftPawCenters(i,1)))
            xyzPawCenters(i,2) = pelletCoords.left(1)-leftPawCenters(i,1); % x-axis
        elseif(~isnan(rightPawCenters(i,1)))
            xyzPawCenters(i,2) = rightPawCenters(i,1)-pelletCoords.right(1); % x-axis
        else
            xyzPawCenters(i,2) = NaN;
        end
        % calculate z, not the most elegant way, but at least it is readable
        if(~isnan(leftPawCenters(i,1)) && ~isnan(centerPawCenters(i,1)) && ~isnan(rightPawCenters(i,1)))
            leftDist = pelletCoords.left(2)-leftPawCenters(i,2); % y-axis
            centerDist = pelletCoords.center(2)-centerPawCenters(i,2); % y-axis
            rightDist = pelletCoords.right(2)-rightPawCenters(i,2); % y-axis
            xyzPawCenters(i,3) = mean([leftDist,centerDist,rightDist]);
        elseif(~isnan(leftPawCenters(i,1)) && ~isnan(centerPawCenters(i,1)))
            leftDist = pelletCoords.left(2)-leftPawCenters(i,2); % y-axis
            centerDist = pelletCoords.center(2)-centerPawCenters(i,2); % y-axis
            xyzPawCenters(i,3) = mean([leftDist,centerDist]);
        elseif(~isnan(centerPawCenters(i,1)) && ~isnan(rightPawCenters(i,1)))
            centerDist = pelletCoords.center(2)-centerPawCenters(i,2); % y-axis
            rightDist = pelletCoords.right(2)-rightPawCenters(i,2); % y-axis
            xyzPawCenters(i,3) = mean([centerDist,rightDist]);
        elseif(~isnan(leftPawCenters(i,1)) && ~isnan(rightPawCenters(i,1)))
            leftDist = pelletCoords.left(2)-leftPawCenters(i,2); % y-axis
            rightDist = pelletCoords.right(2)-rightPawCenters(i,2); % y-axis
            xyzPawCenters(i,3) = mean([leftDist,rightDist]);
        elseif(~isnan(leftPawCenters(i,1)))
            xyzPawCenters(i,3) = pelletCoords.left(2)-leftPawCenters(i,2); % y-axis
        elseif(~isnan(centerPawCenters(i,1)))
            xyzPawCenters(i,3) = pelletCoords.center(2)-centerPawCenters(i,2); % y-axis
        elseif(~isnan(rightPawCenters(i,1)))
            xyzPawCenters(i,3) = pelletCoords.right(2)-rightPawCenters(i,2); % y-axis
        else
            xyzPawCenters(i,3) = NaN;
        end
    end
end

function allPawCenters=loadPawCenters(sessions,sessionsPath)
    allPawCenters = cell(1,numel(sessions));
    for i=1:numel(sessions)
        load(fullfile(sessionsPath,sessions(i).name));
        allPawCenters{i} = pawCenters; % "pawCenters" variable is loaded via .mat file
    end
end