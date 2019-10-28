function [vidIdx,trajectory_file_name] = identifyCorrectVidIdx(vidName,searchFolder)

vidIdx = [];
ratID_and_session = vidName(1:14);
trajectory_file_name = '';

% figure out which trialNumbers index corresponds to the desired video
cur_dir = pwd;

cd(searchFolder)
% is this a kinematics summary folder or a raw video files folder?

% get the vid name without any extension
[~,vidName,ext] = fileparts(vidName);

if isempty(ext)    % extension not specified in vidName
    testString = [vidName '*'];
    testFile = dir(testString);
    if isempty(testFile)
        fprintf('no match for %s found in %s\n',vidName,searchFolder);
        return
    end
    testName = testFile(1).name;
    [~,~,ext] = fileparts(testName);
end
    
if strcmpi(ext,'.avi')
    testString = [ratID_and_session '*.avi'];
elseif strcmpi(ext,'.mat')
    testString = [ratID_and_session '*_3dtrajectory_new.mat'];
end
fullFileList = dir(testString);

numFiles = length(fullFileList);

for iFile = 1 : numFiles
    
    [~,curName,~] = fileparts(fullFileList(iFile).name);
    testName = curName(1:27);
    if strcmpi(testName,vidName)
        vidIdx = iFile;
        
        if strcmpi(ext,'.mat')
            trajectory_file_name = fullFileList(iFile).name;
        end
    end
    
end