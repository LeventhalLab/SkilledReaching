% detect checkerboard calibration images, 20180605

% <<<<<<< HEAD
% % calImageDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Calibration Images';
% % calImageDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Calibration Images';
% calImageDir = '/home/kkrista/Documents/Publications/JOVE_Winter2019/CalCubeImages/';
% 
% camParamFile = '/home/kkrista/Documents/Publications/JOVE_Winter2019/CalCubeImages/cameraParameters.mat';
% % camParamFile = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/multiview geometry/cameraParameters.mat';
% =======

month_to_analyze = '201704';
year_to_analyze = month_to_analyze(1:4);
rootDir = '/Volumes/LL EXHD #2/calibration_images';
calImageDir = fullfile(rootDir,year_to_analyze,...
    [month_to_analyze '_calibration'],[month_to_analyze '_original_images']);
autoImageDir = fullfile(rootDir,year_to_analyze,...
    [month_to_analyze '_calibration'],[month_to_analyze '_auto_marked']);
if ~exist(autoImageDir,'dir')
    mkdir(autoImageDir)
end

camParamFile = '/Users/dan/Documents/Leventhal lab github/SkilledReaching/Manual Tracking Analysis/ConvertMarkedPointsToReal/cameraParameters.mat';

% calImageDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Calibration Images';
% calImageDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Calibration Images';
% calImageDir = '/home/kkrista/Documents/Publications/JOVE_Winter2019/CalCubeImages/';

% camParamFile = '/home/kkrista/Documents/Publications/JOVE_Winter2019/CalCubeImages/cameraParameters.mat';
% camParamFile = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/multiview geometry/cameraParameters.mat';

load(camParamFile);

saveMarkedImages = true;
markRadius = 5;
colorList = {'red','green','blue'};
markOpacity = 1;

% first row red, second row green, third row blue
direct_hsvThresh = [0,0.1,0.9,1,0.9,1;
                    0.33,0.1,0.9,1,0.9,1;
                    0.66,0.1,0.9,1,0.9,1];

mirror_hsvThresh = [0,0.1,0.85,1,0.85,1;
                    0.30,0.05,0.85,1,0.85,1;
                    0.60,0.1,0.85,1,0.85,1];

boardSize = [4 5];
points_per_board = prod(boardSize-1);

cd(calImageDir)

anticipatedBoardSize = [4 5];

imgList = dir('GridCalibration_*.png');
% load test image
A = imread(imgList(1).name,'png');
h = size(A,1); w = size(A,2);
% [x,y,w,h]. first row is for direct cube view, second row tpp mirror,
% third row left mirror, fourth row right mirror
rightMirrorLeftEdge = 1700;
ROIs = [700,270,650,705;
        750,1,600,400;
        1,400,350,500;
        rightMirrorLeftEdge,400,w-rightMirrorLeftEdge,500];
    
numBoards = size(ROIs,1) - 1;

mirrorOrientation = {'top','left','right'};
   
cd(calImageDir);

% NOTE: the function groupCalibrationImagesbyDate removes any .png files
% with "marked" in their filename, so that this only operates on the
% originally acquired .png files
[imFiles_from_same_date, dateList] = groupCalibrationImagesbyDate(imgList);
numDates = length(dateList);

for iDate = 1 : numDates
    
    curDate = dateList{iDate};
%     if ~any(strcmp({'20170522','20170529'}, curDate))
%         continue;
%     end
    
    fprintf('processing %s\n',curDate);
    numFilesPerDate = length(imFiles_from_same_date{iDate});
    img = cell(1, numFilesPerDate);
    for iImg = 1 : numFilesPerDate

        curImgName = imFiles_from_same_date{iDate}{iImg};
        img{iImg} = imread(curImgName);
        
    end
    
    [directBorderMask, initDirBorderMask] = findDirectBorders(img, direct_hsvThresh, ROIs);
    [mirrorBorderMask, initMirBorderMask] = findMirrorBorders(img, mirror_hsvThresh, ROIs);
    
    [directChecks,dir_foundValidPoints] = findMaskedCheckerboards(img, directBorderMask, initDirBorderMask, boardSize, cameraParams);
    [mirrorChecks,mir_foundValidPoints] = findMaskedCheckerboards(img, mirrorBorderMask, initMirBorderMask, boardSize, cameraParams);
    
    % find images in which checkerboard pairs were identified
    matchedCheckerboards = dir_foundValidPoints & mir_foundValidPoints;
    
    allMatchedPoints = NaN(points_per_board * numFilesPerDate, 2, 2, numBoards);
    for iImg = 1 : numFilesPerDate
        for iBoard = 1 : numBoards
            
            if matchedCheckerboards(iBoard,iImg)
                curDirectChecks = squeeze(directChecks(:,:,iBoard,iImg));
                curMirrorChecks = squeeze(mirrorChecks(:,:,iBoard,iImg));
                
                % now undistorting points in findMaskedCheckerboards
%                 curDirectChecks = undistortPoints(curDirectChecks, cameraParams);
%                 curMirrorChecks = undistortPoints(curMirrorChecks, cameraParams);
                
                matchIdx = matchCheckerboardPoints(curDirectChecks, curMirrorChecks);
                
                matchStartIdx = (iImg-1) * points_per_board + 1;
                matchEndIdx = (iImg) * points_per_board;
                
                allMatchedPoints(matchStartIdx:matchEndIdx,:,1,iBoard) = curDirectChecks(matchIdx(:,1),:);
                allMatchedPoints(matchStartIdx:matchEndIdx,:,2,iBoard) = curMirrorChecks(matchIdx(:,2),:);
            end

        end
    end
    
    matFileName = ['GridCalibration_' dateList{iDate} '_auto.mat'];
    matFileName = fullfile(autoImageDir,matFileName);
    imFileList = imFiles_from_same_date{iDate};
    save(matFileName, 'directChecks','mirrorChecks','allMatchedPoints','dir_foundValidPoints','mir_foundValidPoints','imFileList','cameraParams','curDate');
    
    if saveMarkedImages
        for iImg = 1 : numFilesPerDate
            
%            newImg = undistortImage(img{iImg},cameraParams);
            newImg=img{iImg};

            for iBoard = 1 : numBoards
                
                if dir_foundValidPoints(iBoard,iImg)
                    curChecks = squeeze(directChecks(:,:,iBoard,iImg));
                    for i_pt = 1 : size(curChecks,1)
                        newImg = insertShape(newImg,'filledcircle',...
                            [curChecks(i_pt,1),curChecks(i_pt,2),markRadius],...
                            'color',colorList{iBoard},'opacity',markOpacity);
                    end
                end
                
                if mir_foundValidPoints(iBoard,iImg)
                    curChecks = squeeze(mirrorChecks(:,:,iBoard,iImg));
                    for i_pt = 1 : size(curChecks,1)
                        newImg = insertShape(newImg,'filledcircle',...
                            [curChecks(i_pt,1),curChecks(i_pt,2),markRadius],...
                            'color',colorList{iBoard},'opacity',markOpacity);
                    end
                end 
            end
            curImgName = imFiles_from_same_date{iDate}{iImg};
            newImgName = strrep(curImgName,'.png','_marked.png');
            newImgName = fullfile(autoImageDir,newImgName);
%             figure(1);imshow(newImg);
            imwrite(newImg,newImgName,'png');
        end       
    end
end 
