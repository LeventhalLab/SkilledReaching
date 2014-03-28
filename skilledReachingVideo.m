function [pawCenters,pawHulls,pelletCenters,pelletBboxes] = skilledReachingVideo(...
    videoFile,hsvBounds,pelletCenter,saveVideoAs)

    [pawCenters,pawHulls,pelletCenters,pelletBboxes] = skilledReaching(videoFile,hsvBounds,pelletCenter);
    pawCenters = cleanCentroids(pawCenters);
    pelletCenters = cleanCentroids(pelletCenters);
    [graspIndexes,success] = pelletClassify(pelletBboxes,pawHulls);
    
    video = VideoReader(videoFile);
    newVideo = VideoWriter(saveVideoAs,'Motion JPEG AVI');
    newVideo.Quality = 100;
    newVideo.FrameRate = 20;
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
                image = insertShape(image,'Line',[pawCenters(i,:)... 
                    pawHulls{i}(simpleHullIndexes(j),1) pawHulls{i}(simpleHullIndexes(j),2)]);
                % hull points
                image = insertShape(image,'FilledCircle',...
                    [pawHulls{i}(simpleHullIndexes(j),1) pawHulls{i}(simpleHullIndexes(j),2) 3],'Color','red');

            end
        end
        
        % pellet bbox
%         if(~isnan(pelletBboxes(i,1)))
%             image = insertShape(image,'Rectangle',pelletBboxes(i,:),'Color','blue');
%         end
%         
%         if(size(graspIndexes,1)==0 || i < min(graspIndexes))
%            image = insertText(image,[20 20],'No Pellet Grasp','BoxColor','red');
%         else
%            % if grasping in this image
%            if(i < max(graspIndexes))
%                image = insertText(image,[20 20],'Pellet Grasping...','BoxColor','blue');
%            else
%                if(success)
%                    image = insertText(image,[20 20],'Pellet Grasped!','BoxColor','green');
%                else
%                   image = insertText(image,[20 20],'Pellet Deflected','BoxColor','yellow'); 
%                end
%            end
%         end
        
        %imshow(image)
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