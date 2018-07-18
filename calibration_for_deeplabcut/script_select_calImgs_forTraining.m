% script to pull out a specified random number of calibration images for
% training

rootPath = fullfile('/Volumes','Tbolt_01','Skilled Reaching','calibration_images');
savePath = fullfile('/Volumes','Tbolt_01','Skilled Reaching','deeplabcut_calibration_images');
saveDirs = {'direct', 'top', 'left', 'right'};

cd(rootPath)

numSamples = 100;

calImgs = dir('GridCalibration_*.png');
numImgs = length(calImgs);

randSample = randperm(numImgs, numSamples);

for ii = 1 : numSamples
    
    
    for iDir = 1 : length(saveDirs)
        fname = calImgs(randSample(ii)).name;
        fname = [fname(1:end-4) '_' saveDirs{iDir} '.png'];
        full_orig_name = fullfile(rootPath,saveDirs{iDir},fname);
        full_dest_path = fullfile(savePath,saveDirs{iDir});
        full_dest_name = fullfile(full_dest_path,fname);
        
        if ~isfolder(full_dest_path)
            mkdir(full_dest_path);
        end
        
        copyfile(full_orig_name,full_dest_name);
    end
end