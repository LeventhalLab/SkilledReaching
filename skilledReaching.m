function [pawCenters,pawHulls,pelletCenters,pelletBboxes] = skilledReaching(videoFile,hsvBounds,pelletCenter)
    video = VideoReader(videoFile);

    pawCenters = NaN(video.NumberOfFrames,2);
    pawHulls = cell(1,video.NumberOfFrames);
    pelletCenters = NaN(video.NumberOfFrames,2);
    pelletBboxes = NaN(video.NumberOfFrames,4);
    
    waitingForPellet = 1;
    startingPelletCenter = pelletCenter;
    searchRadius = 30;
    
    kalmanFilter = configureKalmanFilter('ConstantVelocity',pelletCenter,[1 1 ]*1e5,[25,10],25);
    predictedCount = 0;
    for i=1:video.NumberOfFrames
        disp(['Masking... ' num2str(i)])
        image = read(video,i);
        [pawCenters(i,:),pawHulls{i}] = pawData(image,hsvBounds);
        
        % only allow a few predictions, the bounding pellet mask can trail
        % into other areas that might register as a pellet
        allowPredictions = 5;
        if(predictedCount < allowPredictions)
            [pelletCenter,pelletBbox] = pelletData(image,pelletCenter,searchRadius);
            if(~isnan(pelletCenter))
                predict(kalmanFilter);
                pelletCenter = correct(kalmanFilter,pelletCenter);
                % only record good and known pellet locations, interpolate later
                pelletCenters(i,:) = round(pelletCenter);
                pelletBboxes(i,:) = round(pelletBbox);
                predictedCount = 0;
                waitingForPellet = 0;
                searchRadius = 50;
            else
                if(waitingForPellet)
                    pelletCenter = startingPelletCenter;
                else
                    pelletCenter = predict(kalmanFilter);
                    predictedCount = predictedCount + 1;
                end
            end
        end
    end
end