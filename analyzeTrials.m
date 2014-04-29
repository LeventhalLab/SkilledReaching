% >> analyzeTrials(150,0.1053,STRUCT(left,center,right))

% This function requires that a video has already been cropped and pawData has already been saved
% into the trials folder for each of 3 viewing angles
function analyzeTrials(frameRate,pxToMm,pelletCoords)
    workingDirectory = uigetdir;
    workingDirectoryParts = strsplit(workingDirectory,filesep);
    trialName = workingDirectoryParts{end};
    % load all the .mat trials created for each video, from each angle
    leftTrials = dir(fullfile(workingDirectory,'left','trials','*.mat'));
    centerTrials = dir(fullfile(workingDirectory,'center','trials','*.mat'));
    rightTrials = dir(fullfile(workingDirectory,'right','trials','*.mat'));
    
    % just make sure there are equal trial for each angle
    if(numel(leftTrials) == numel(centerTrials) && numel(leftTrials) == numel(rightTrials))
        % load the pawCenter variables from the trial files
        allLeftPawCenters = loadPawCenters(leftTrials,fullfile(workingDirectory,'left','trials'));
        allCenterPawCenters = loadPawCenters(centerTrials,fullfile(workingDirectory,'center','trials'));
        allRightPawCenters = loadPawCenters(rightTrials,fullfile(workingDirectory,'right','trials'));

        % combines the paw centers from each video into an nx3 matrix, where n=numberOfFrames in the
        % video, and 3=[x y z] data in relation to the pellet
        allXyzPawCenters = cell(1,numel(leftTrials)); % number of videos
        for i=1:numel(leftTrials)
            % returns values in millimeters
            allXyzPawCenters{i} = createXyzPawCenters(allLeftPawCenters{i},allCenterPawCenters{i},...
                allRightPawCenters{i},pxToMm,pelletCoords);
        end

        % takes the [x y z] data just created and calculates a single distance based on all three
        % coordinates in relation to the pellet
        allXyzDistPawCenters = cell(1,numel(leftTrials));
        for i=1:numel(leftTrials)
            allXyzDistPawCenters{i} = createXyzDistPawCenters(allXyzPawCenters{i});
        end

        % aligns data based on distance threshold, ultimately compresses the data set slightly (see
        % alignData function for more)
        allAlignedXyzPawCenters = cell(1,numel(leftTrials));
        allAlignedXyzDistPawCenters = cell(1,numel(leftTrials));
        for i=1:numel(leftTrials)
            [allAlignedXyzPawCenters{i},allAlignedXyzDistPawCenters{i}] = alignData(allXyzPawCenters{i},allXyzDistPawCenters{i});
        end

        % save data
        mkdir(fullfile(workingDirectory,'_xyzData'));
        save(fullfile(workingDirectory,'_xyzData',[trialName,'_xyzData']),'allAlignedXyzPawCenters','allAlignedXyzDistPawCenters',...
            'allXyzPawCenters','allXyzDistPawCenters');
        
        plotFrames = 200;
        % create plots and save images/figures
        h1 = plot1dDistance(allAlignedXyzDistPawCenters,plotFrames);
        saveas(h1,fullfile(workingDirectory,'_xyzData',[trialName,'_1dDistancePlot']),'png');
        saveas(h1,fullfile(workingDirectory,'_xyzData',[trialName,'_1dDistancePlot']),'fig');

        h2 = plot3dDistance(allAlignedXyzPawCenters,plotFrames);
        % use view() to rotate and save a couple angles
        saveas(h2,fullfile(workingDirectory,'_xyzData',[trialName,'_3dDistancePlot']),'png');
        saveas(h2,fullfile(workingDirectory,'_xyzData',[trialName,'_3dDistancePlot']),'fig');
    else
        disp('The trial counts do not match, why not? Fix that and try again.');
    end
end

% Re-aligns data based on a distance threshold, useful for aberant recordings and mis-firing of the
% reach sensor. Also compresses the data set.
function [alignedXyzPawCenters,alignedXyzDistPawCenters]=alignData(xyzPawCenters,xyzDistPawCenters)
    % find frame index that distance crosses a minimum distance threshold
    for shiftIndex=1:numel(xyzDistPawCenters)
        if(xyzDistPawCenters(shiftIndex) < 15) % distance threshold
           break;
        end
    end
    % apply the shift index if it sits somewhere near the middle of the video, otherwise we can
    % assume it is bad data
    alignedXyzPawCenters = []; % final size of the data set
    alignedXyzDistPawCenters = []; % final size of the data set
    % make sure the distance threshold was met somewhere in the middle of the video otherwise the
    % data is considered junk
    if(shiftIndex > 100 && shiftIndex < 200)
        alignedXyzPawCenters(1:numel(xyzDistPawCenters(shiftIndex-50:end)),:) =...
            xyzPawCenters(shiftIndex-50:end,:);
        alignedXyzDistPawCenters(1:numel(xyzDistPawCenters(shiftIndex-50:end))) =...
            xyzDistPawCenters(shiftIndex-50:end);
    end
end

% If all three [x y z] coordinates are present, this returns a single-valued distance-to-pellet
% measurement, otherwise it returns NaN.
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

% Creates [x y z] data for a single trial/video. Not the most elegant way of handling the logic,
% but intended to remain readable and workable. All values are returned in millimeters based on the
% conversion factor for each angle.
function xyzPawCenters=createXyzPawCenters(leftPawCenters,centerPawCenters,rightPawCenters,pxToMm,pelletCoords)
    % x=C, y=mean(L,R), z=mean(L,C,R), *where L, C, and R are not NaN
    frameCount = size(leftPawCenters,1);
    xyzPawCenters = NaN(frameCount,3);
    for i=1:frameCount
        % calculate x
        if(~isnan(centerPawCenters(i,1)))
            xyzPawCenters(i,1) = (pelletCoords.center(1)-centerPawCenters(i,1))*pxToMm.center; % x-axis
        else
            xyzPawCenters(i,1) = NaN;
        end
        % calculate y
        if(~isnan(leftPawCenters(i,1)) && ~isnan(rightPawCenters(i,1)))
            % these equations are intentionally reversed to account for the mirroring, making the
            % x-axis always more negative as it extends inwards into the box
            leftDist = (pelletCoords.left(1)-leftPawCenters(i,1))*pxToMm.left; % x-axis
            rightDist = (rightPawCenters(i,1)-pelletCoords.right(1))*pxToMm.right; % x-axis
            xyzPawCenters(i,2) = mean([leftDist,rightDist]);
        elseif(~isnan(leftPawCenters(i,1)))
            xyzPawCenters(i,2) = (pelletCoords.left(1)-leftPawCenters(i,1))*pxToMm.left; % x-axis
        elseif(~isnan(rightPawCenters(i,1)))
            xyzPawCenters(i,2) = (rightPawCenters(i,1)-pelletCoords.right(1))*pxToMm.right; % x-axis
        else
            xyzPawCenters(i,2) = NaN;
        end
        % calculate z
        if(~isnan(leftPawCenters(i,1)) && ~isnan(centerPawCenters(i,1)) && ~isnan(rightPawCenters(i,1)))
            leftDist = (pelletCoords.left(2)-leftPawCenters(i,2))*pxToMm.left; % y-axis
            centerDist = (pelletCoords.center(2)-centerPawCenters(i,2))*pxToMm.center; % y-axis
            rightDist = (pelletCoords.right(2)-rightPawCenters(i,2))*pxToMm.right; % y-axis
            xyzPawCenters(i,3) = mean([leftDist,centerDist,rightDist]);
        elseif(~isnan(leftPawCenters(i,1)) && ~isnan(centerPawCenters(i,1)))
            leftDist = (pelletCoords.left(2)-leftPawCenters(i,2))*pxToMm.left; % y-axis
            centerDist = (pelletCoords.center(2)-centerPawCenters(i,2))*pxToMm.center; % y-axis
            xyzPawCenters(i,3) = mean([leftDist,centerDist]);
        elseif(~isnan(centerPawCenters(i,1)) && ~isnan(rightPawCenters(i,1)))
            centerDist = (pelletCoords.center(2)-centerPawCenters(i,2))*pxToMm.center; % y-axis
            rightDist = (pelletCoords.right(2)-rightPawCenters(i,2))*pxToMm.right; % y-axis
            xyzPawCenters(i,3) = mean([centerDist,rightDist]);
        elseif(~isnan(leftPawCenters(i,1)) && ~isnan(rightPawCenters(i,1)))
            leftDist = (pelletCoords.left(2)-leftPawCenters(i,2))*pxToMm.left; % y-axis
            rightDist = (pelletCoords.right(2)-rightPawCenters(i,2))*pxToMm.right; % y-axis
            xyzPawCenters(i,3) = mean([leftDist,rightDist]);
        elseif(~isnan(leftPawCenters(i,1)))
            xyzPawCenters(i,3) = (pelletCoords.left(2)-leftPawCenters(i,2))*pxToMm.left; % y-axis
        elseif(~isnan(centerPawCenters(i,1)))
            xyzPawCenters(i,3) = (pelletCoords.center(2)-centerPawCenters(i,2))*pxToMm.center; % y-axis
        elseif(~isnan(rightPawCenters(i,1)))
            xyzPawCenters(i,3) = (pelletCoords.right(2)-rightPawCenters(i,2))*pxToMm.right; % y-axis
        else
            xyzPawCenters(i,3) = NaN;
        end
    end
end

% Load and return the pawCenters variable from a trial file (one video).
function allPawCenters=loadPawCenters(trials,trialsPath)
    allPawCenters = cell(1,numel(trials));
    for i=1:numel(trials)
        load(fullfile(trialsPath,trials(i).name));
        allPawCenters{i} = pawCenters; % "pawCenters" variable is loaded via .mat file
    end
end