% script to crop video with the same ROI as the extracted frames

% script to randomly select calibration images and split them into separate
% folders for marking specific regions


% need to set up a destination folder to put the stacks of videos of each
% type - left vs right pawed, tattooed vs not

rootPath = fullfile('/Volumes','Tbolt_01','Skilled Reaching','calibration_images');
saveDirs = {'direct', 'top', 'left', 'right'};
calImg_prefix = {'GridCalibration'};

for iView = 1 : length(saveDirs)
    if ~isfolder(fullfile(rootPath,saveDirs{iView}))
        mkdir(fullfile(rootPath,saveDirs{iView}));
    end
end

cd(rootPath);
% search for calibration images
foundValidImages = false;
for ii = 1 : length(calImg_prefix)
    tempImgs = dir([calImg_prefix{ii} '_*.png']);

    if isempty(tempImgs); continue; end

    if foundValidImages
        num_newImgs = length(tempImgs);
        calImgs(end+1:end+num_newImgs) = tempImgs;
    else
        calImgs = tempImgs;
        foundValidImages = true;
    end
end

if ~exist('calImgs','var')
    disp('no calibration images found.')
    return;
end

% load a test image
A = imread(calImgs(1).name,'png');
h = size(A,1); w = size(A,2);
rightMirrorLeftEdge = 1700;
ROIs = [700,200,650,775;
        750,1,600,350;
        1,350,350,550;
        rightMirrorLeftEdge,400,w-rightMirrorLeftEdge,500];
    
for iView = 1 : 4
    ROI = ROIs(iView,:);
    fname = fullfile(rootPath,saveDirs{iView},[saveDirs{iView} '_metadata.mat']);
    save(fname,'ROI');
end
    
for iImg = 1 : length(calImgs)
    
    img = imread(fullfile(rootPath, calImgs(iImg).name),'png');
    
    for iView = 1 : length(saveDirs)
        
        cropped_img = img(ROIs(iView,2):ROIs(iView,2)+ROIs(iView,4),...
                          ROIs(iView,1):ROIs(iView,1)+ROIs(iView,3),:);
        cropped_fname = strrep(calImgs(iImg).name,'.png', ['_' saveDirs{iView} '.png']);
        
        imwrite(cropped_img, fullfile(rootPath,saveDirs{iView},cropped_fname));
        
    end
    
end