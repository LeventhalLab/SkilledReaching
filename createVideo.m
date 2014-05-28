% Matt Gaidica, mgaidica@med.umich.edu
% Leventhal Lab, University of Michigan
% --- release: beta ---

% Controls video creation and step-by-step creation of data
function [pawCenters,pawHulls] = createVideo(videoFile,hsvBounds)

    [pawCenters,pawHulls] = getDataFromVideo(videoFile,hsvBounds);
    [pathstr,name,ext] = fileparts(videoFile);
    
    video = VideoReader(videoFile);
    mkdir(fullfile(pathstr,'processed'));
    newVideo = VideoWriter(fullfile(pathstr,'processed',['processed_' name]),'Motion JPEG AVI');
    newVideo.Quality = 100;
    newVideo.FrameRate = 20;
    open(newVideo);

    for i=2:video.NumberOfFrames
        disp(['Writing Video... ' num2str(i)])
        im = read(video,i);
        
        if(~isnan(pawCenters(i,1)))
            im = insertShape(im,'FilledCircle',[pawCenters(i,:) 8]);
        end
        
        % pawCenters are always set when there is a pawHull, but the hull
        % can not exist without the center
        if(~isnan(pawHulls{i}(1)))
            im = insertShape(im,'Line',[repmat(pawCenters(i,:),[size(pawHulls{i},1),1]) pawHulls{i}]);
            im = insertShape(im,'FilledCircle',...
                    [pawHulls{i} repmat(3,size(pawHulls{i},1),1)],'Color','red');
           
            maxIndexes = maxSpread(pawCenters(i,:),pawHulls{i});
            im = insertShape(im,'FilledCircle',[pawHulls{i}(maxIndexes,:) repmat(5,2,1)],'Color','white');
        end
        
        writeVideo(newVideo,im);
    end
    
    close(newVideo);
    mkdir(fullfile(pathstr,'trials'));
    save(fullfile(pathstr,'trials',name),'pawCenters','pawHulls','hsvBounds');
end