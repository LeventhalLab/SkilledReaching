% script to extract calibration images and move them to one folder
%%
% rootPath = fullfile('/Volumes','Tbolt_01','Skilled Reaching');
rootPath = fullfile('/Volumes/RecordingsLeventhal04/SkilledReaching');
savePath = fullfile('/Volumes','Tbolt_01','Skilled Reaching','calibration_images');
if ~isfolder(savePath)
    mkdir(savePath);
end

if exist('calImgs','var')
    clear calImgs
end
% find all rat directories
cd(rootPath);
Rdirs = dir('R*');

calImg_prefix = {'GridCalibration'};

for i_ratDir = 1 : length(Rdirs)
    
    ratDir = fullfile(rootPath, Rdirs(i_ratDir).name);
    if ~isfolder(ratDir); continue; end
    cd(ratDir);
    ratID = Rdirs(i_ratDir).name(1:5);
    
    testRawDataDir = [ratID '-rawdata'];
    if isfolder(testRawDataDir)
        ratDir = fullfile(ratDir,testRawDataDir);
        cd(testRawDataDir);
    end
    
    % find directories for individual sessions
    sessionDirs = dir([ratID '_*']);
    
    for i_sessionDir = 1 : length(sessionDirs)
        
        if ~isfolder(sessionDirs(i_sessionDir).name); continue; end
        
        cd(sessionDirs(i_sessionDir).name);
    
        % search for calibration images
        foundValidImages = false;
        for ii = 1 : length(calImg_prefix)
            tempImgs = dir([calImg_prefix{ii} '_*.png']);

            if isempty(tempImgs)
                continue
            end

            if foundValidImages
                num_newImgs = length(tempImgs);
                calImgs(end+1:end+num_newImgs) = tempImgs;
            else
                calImgs = tempImgs;
                foundValidImages = true;
            end
        end

        if ~exist('calImgs','var')
            cd(ratDir)
            continue
        end

        for i_calImg = 1 : length(calImgs)
            destName = fullfile(savePath, calImgs(i_calImg).name);
            copyfile(calImgs(i_calImg).name, destName);
        end
        
        clear calImgs
        cd(ratDir);
        
    end
    
end