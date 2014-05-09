function data=scoreVideoData(scorePath,videosDirectory)
    scoreData = csvread(scorePath);
    allVideos = dir(fullfile(videosDirectory,'*.avi'));
    % trial, score, videoPath
    data = cell(size(scoreData,1),3);
    for i=1:size(scoreData,1)
        data{i,1} = scoreData(i,1);
        data{i,2} = scoreData(i,2);
    end
    for i=1:numel(allVideos)
        extractTrial = regexp(allVideos(i).name,'_[0-9][0-9][0-9].avi','match');
        trial = str2double(extractTrial{1}(2:4));
        data{trial,3} = fullfile(videosDirectory,allVideos(i).name);
    end
end