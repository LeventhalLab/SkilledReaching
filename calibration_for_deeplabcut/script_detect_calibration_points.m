% detect checkerboard calibration images, 20180605

calImageDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Calibration Images';
% calImageDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Calibration Images';

% first row red, second row green, third row blue
direct_hsvThresh = [0,0.1,0.8,1,0.5,1;
                    0.33,0.1,0.8,1,0.5,1;
                    0.66,0.1,0.8,1,0.5,1];

mirror_hsvThresh = [0,0.1,0.5,1,0.5,1;
                    0.33,0.1,0.5,1,0.5,1;
                    0.66,0.1,0.5,1,0.5,1];

boardSize = [4 5];
cd(calImageDir)

imgList = dir('GridCalibration_*.png');
% load test image
A = imread(imgList(1).name,'png');
h = size(A,1); w = size(A,2);
% [x,y,w,h]. first row is for direct cube view, second row tpp mirror,
% third row left mirror, fourth row right mirror
rightMirrorLeftEdge = 1700;
ROIs = [700,375,650,600;
        750,1,600,400;
        1,400,350,500;
        rightMirrorLeftEdge,400,w-rightMirrorLeftEdge,500];
   
cd(calImageDir);


for iImg = 30 : length(imgList)
    
    if ~isempty(strfind(imgList(iImg).name,'marked'))
        continue;
    end
    
    curImgName = imgList(iImg).name;
%     
    A = imread(curImgName);
    dImg = A(ROIs(1,2):ROIs(1,2)+ROIs(1,4),ROIs(1,1):ROIs(1,1)+ROIs(1,3),:);
    lImg = A(ROIs(3,2):ROIs(3,2)+ROIs(3,4),ROIs(3,1):ROIs(3,1)+ROIs(3,3),:);
    rImg = A(ROIs(4,2):ROIs(4,2)+ROIs(4,4),ROIs(4,1):ROIs(4,1)+ROIs(4,3),:);

    directBorderMask = findDirectBorders(A, direct_hsvThresh, ROIs);
    [directBorderChecks,dir_foundValidPoints] = findDirectCheckerboards(A, directBorderMask, boardSize);
    mirrorBorderMask = findMirrorCheckerboards(A, directBorderMask, directBorderChecks, mirror_hsvThresh, boardSize, ROIs);
%     borderMask = findColoredBorder(A, hsvThresh, ROIs);
    dispMask = false(h,w);
    for iMask = 1 : 6
        dispMask = dispMask | squeeze(borderMask(:,:,iMask));
    end
    
    figure(2)
    imshow(dispMask)
    
end

