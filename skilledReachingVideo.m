function [pawCenters,pawHulls,pelletCenters] = skilledReachingVideo(...
    videoFile,hsvBounds,pelletCenter,saveVideoAs)

    [pawCenters,pawHulls,pelletCenters] = skilledReaching(videoFile,hsvBounds,pelletCenter);
    pawCenters = cleanCentroids(pawCenters);
    pelletCenters = cleanCentroids(pelletCenters);
    
    video = VideoReader(videoFile);
    newVideo = VideoWriter(saveVideoAs,'Motion JPEG AVI');
    newVideo.Quality = 100;
    newVideo.FrameRate = 30;
    open(newVideo);
    
    for i=1:video.NumberOfFrames
        disp(['Writing Video... ' num2str(i)])
        image = read(video,i);
        
        if(~isnan(pawCenters(i,1)))
            image = insertShape(image,'FilledCircle',[pawCenters(i,:) 8]);
        end

        if(~isnan(pawHulls{i}(1)))
            simpleHullIndexes = convhull(pawHulls{i},'simplify',true);
            for j=1:(size(simpleHullIndexes)-1)
                % lines to hull points
                if(~isnan(pawCenters(i,1)))
                    image = insertShape(image,'Line',[pawCenters(i,:)... 
                        pawHulls{i}(simpleHullIndexes(j),1) pawHulls{i}(simpleHullIndexes(j),2)]);
                end
                % hull points
                if(~isnan(pawHulls{i}(1)))
                    image = insertShape(image,'FilledCircle',...
                        [pawHulls{i}(simpleHullIndexes(j),1) pawHulls{i}(simpleHullIndexes(j),2) 3],'Color','red');
                end
            end
        end
        
        if(~isnan(pelletCenters(i,:)))
            image = insertShape(image,'FilledCircle',...
                [pelletCenters(i,:) 5],'Color','blue');
        end
        
        writeVideo(newVideo,image);

%         [northPole,southPole] = poles(hull);
%         if(abs(mean(northPole-southPole)) > 10)
%             image = insertShape(image,'Line',[centerGravityRow centerGravityColumn northPole;...
%                 centerGravityRow centerGravityColumn southPole]);
%             image = insertShape(image,'FilledCircle',[northPole 3]);
%             image = insertShape(image,'FilledCircle',[southPole 3]);
%         end
    end
    
    close(newVideo);
end