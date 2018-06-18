% detect checkerboard calibration images, 20180605

calImageDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Calibration Images';
cd(calImageDir)

% first row red, second row green, third row blue
hsvThresh = [0,0.1,0.5,1,0.5,1;
             0.33,0.1,0.3,1,0.5,1;
             0.66,0.1,0.3,1,0.5,1];
         
RGBdistThresh = 0.15;

anticipatedBoardSize = [4 5];
minCheckArea = 200;

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


for iImg = 1 : length(imgList)
    iImg
    
    curImgName = imgList(iImg).name;
    
    A = imread(curImgName);
    Ahsv = rgb2hsv(A);
    
%     figure(1)
%     imshow(A)
    
    [ initBorderMask, borderMask, whiteCheckMask, blackCheckMask ] = ...
        findBorderAndCheckMasks(Ahsv, hsvThresh, ROIs, anticipatedBoardSize);
   
    % find the centroids for the white and black squares
    all_check_centers = zeros(prod(anticipatedBoardSize), 2, 6);
    for iMask = 1 : 6
        white_check_props = regionprops(whiteCheckMask(:,:,iMask),'Centroid');
        black_check_props = regionprops(blackCheckMask(:,:,iMask),'Centroid');

        numWhiteChecks = length(white_check_props);
        numBlackChecks = length(black_check_props);
        numChecks = numWhiteChecks + numBlackChecks;
        checkCenters = zeros(numChecks,2);
        for iCheck = 1 : numChecks
            if iCheck <= numWhiteChecks
                checkCenters(iCheck,:) = white_check_props(iCheck).Centroid;
            else
                checkCenters(iCheck,:) = black_check_props(iCheck - numWhiteChecks).Centroid;
            end
        end

        all_check_centers(:,1,iMask) = checkCenters(:,1);
        all_check_centers(:,2,iMask) = checkCenters(:,2);
    end



dispMask = false(h,w);
for iMask = 1 : 6
    dispMask = dispMask | squeeze(checkBoardMask(:,:,iMask));
end
masked_img = A .* repmat(uint8(dispMask),1,1,3);

figure(1)
hold off
imshow(A)
hold on
for iMask = 1 : 6
    scatter(squeeze(all_check_centers(:,1,iMask)),squeeze(all_check_centers(:,2,iMask)),50,'b','filled')
end

calPtsName = strrep(imgList(iImg).name,'png','mat');
calPtsName = fullfile(calImageDir,calPtsName);
% save(calPtsName,'all_check_centers');


end
