function data=getTrialData(trialPath)
    matFiles = dir(fullfile(trialPath,'*.mat'));
    lastTrial = extractTrial(matFiles(end).name);
    % trial, trialPath
    data = cell(lastTrial,2);
    for i=1:lastTrial
        data{i,1} = i; %setup trial number
    end
    for i=1:numel(matFiles)
        trial = extractTrial(matFiles(i).name);
        data{trial,2} = fullfile(trialPath,matFiles(i).name);
    end
end

function trial=extractTrial(name)
    extractTrial = regexp(name,'_[0-9][0-9][0-9].mat','match');
    trial = str2double(extractTrial{1}(2:4));
end