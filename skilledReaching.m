function [pawCenters,pawHulls,pelletCenters] = skilledReaching(videoFile,hsvBounds,pelletCenter)
    video = VideoReader(videoFile);

    pawCenters = NaN(video.NumberOfFrames,2);
    pawHulls = cell(1,video.NumberOfFrames);
    pelletCenters = NaN(video.NumberOfFrames,2);
    
    kalmanFilter = configureKalmanFilter('ConstantVelocity',pelletCenter,[1 1 ]*1e5,[25,10],25);
    predictedCount = 0;
    for i=1:video.NumberOfFrames
        disp(['Masking... ' num2str(i)])
        image = read(video,i);
        [pawCenters(i,:),pawHulls{i}] = pawData(image,hsvBounds);
        if(predictedCount < 5)
            [pelletCenter] = pelletData(image,pelletCenter);
            if(~isnan(pelletCenter))
                predict(kalmanFilter);
                pelletCenter = correct(kalmanFilter, pelletCenter);
                predictedCount = 0;
            else
                pelletCenter = predict(kalmanFilter);
                predictedCount = predictedCount + 1;
            end
            pelletCenter = round(pelletCenter);
            image = insertShape(image,'FilledCircle',[pelletCenter 5],'Color','blue');
        else
            % pellet is lost forever
            pelletCenter = NaN(1,2);
        end
        pelletCenters(i,:) = pelletCenter;
    end
end