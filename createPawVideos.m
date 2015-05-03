% Matt Gaidica, mgaidica@med.umich.edu
% Leventhal Lab, University of Michigan
% --- release: beta ---

% Creates a video montage of several videos based on a quantified score
function createPawVideos(nVideos,saveVideoAs,matchScore)
    disp('Select vidoes folder...');
    videosDirectory = uigetdir('/Users/mattgaidica/Documents/Data/SkilledReaching');
    disp('Select score file...');
	[f,p] = uigetfile({'*.csv'},'csv','/Users/mattgaidica/Documents/Data/SkilledReaching');
    scoreData = scoreVideoData(fullfile(p,f),videosDirectory);
    
    videoIndexes = find([scoreData{:,2}]==matchScore);
%     videoIndexes = [1:18]; %hack for not having all videos and not caring about score
    maxVideos = min([nVideos,numel(videoIndexes)]);
    % get random sample of videos
    randomVideoTrials = datasample(videoIndexes,maxVideos,'Replace',false)';

    newVideo = VideoWriter(saveVideoAs,'Motion JPEG AVI');
    newVideo.Quality = 100;
    newVideo.FrameRate = 20;
    open(newVideo);
    cropPixels = 200;
    for ii=1:maxVideos
        video = VideoReader(scoreData{randomVideoTrials(ii),3});
        if(ii==1)
            figure;
            imshow(read(video,150));
            disp('Select point of interest...');
            [x,y] = ginput;
            x = round(x);
            y = round(y);
            close;
        end
        disp(['Writing i=',num2str(ii),', trial=',num2str(randomVideoTrials(ii))]);
        workingDirectoryParts = strsplit(videosDirectory,filesep);
        xshift = 0; %in case pixels run into edge
        if(x-cropPixels<1)
            xshift = abs(x-cropPixels)+1;
        end
        for j=150:350
            im = read(video,j);
            im = im((y-cropPixels):(y+cropPixels),(x-cropPixels+xshift):(x+cropPixels+xshift),:);
            trialTitle = [workingDirectoryParts{end},', t',num2str(randomVideoTrials(ii))];
            im = insertText(im,[1 1],trialTitle);
            writeVideo(newVideo,im);
        end
    end
    
    close(newVideo);
end