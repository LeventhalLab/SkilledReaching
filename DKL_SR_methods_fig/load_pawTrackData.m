function pawData = load_pawTrackData(processedDir, trialNum)
%
% function to read left, center, right paw coordinates from Titus'
% directories

subDirList = {'center','left','right'};
pawData = [];

for iView = 1 : 3

    dataDirName = fullfile(processedDir, ...
                           subDirList{iView}, ...
                           'trials');

    cd(dataDirName);

    matName = sprintf('*%03d.mat',trialNum);
    trajFile = dir(matName);
    
    if isempty(trajFile) || length(trajFile) > 1
        return;
    end
    load(trajFile.name);

    if iView == 1
        pawData = zeros(size(pawCenters,1),size(pawCenters,2), 3);
    end
    
    pawData(:,:,iView) = pawCenters;
end
        
        