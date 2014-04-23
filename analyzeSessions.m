function analyzeSessions(frameRate,pxToMm,pelletCoords)
    workingDirectory = uigetdir;
    sessions = dir(fullfile(workingDirectory,'*.mat'));
    for i=1:numel(sessions)
        load(fullfile(workingDirectory,sessions(i).name));
        plotDistanceVsTime(pawCenters,frameRate,pxToMm,pelletCoords);
    end
end