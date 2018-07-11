% detect checkerboard calibration images, 20180605

calImageDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Calibration Images';
cd(calImageDir)

% first row red, second row green, third row blue
hsvThresh = [0,0.1,0.8,1,0.6,1;
             0.33,0.1,0.8,1,0.6,1;
             0.66,0.1,0.8,1,0.6,1];
         
RGBdistThresh = 0.15;

anticipatedBoardSize = [4 5];
numAnticipatedChecks = prod(anticipatedBoardSize);
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

whiteGridError = false(1,6);
blackGridError = false(1,6);
for iImg = 1 : length(imgList)
    iImg
    curImgName = imgList(iImg).name;
    if ~isempty(strfind(curImgName, 'marked'))
        continue;
    end
    
    A = imread(curImgName);
    Ahsv = rgb2hsv(A);
    
%     figure(1)
%     imshow(A)
    
    [ initBorderMask, borderMask, whiteCheckMask, blackCheckMask, errorFlag ] = ...
        findBorderAndCheckMasks(Ahsv, hsvThresh, ROIs, anticipatedBoardSize);
   
    % find the centroids for the white and black squares
    all_check_centers = zeros(prod(anticipatedBoardSize), 2, 6);
    for iMask = 1 : 6
        white_check_props = regionprops(whiteCheckMask(:,:,iMask),'Centroid');
        black_check_props = regionprops(blackCheckMask(:,:,iMask),'Centroid');

        numWhiteChecks = length(white_check_props);
        numBlackChecks = length(black_check_props);
        
        if numWhiteChecks ~= numAnticipatedChecks / 2
            whiteGridError(iMask) = true;
        end
        if numBlackChecks ~= numAnticipatedChecks / 2
            blackGridError(iMask) = true;
        end
        numChecks = numWhiteChecks + numBlackChecks;
        checkCenters = zeros(numChecks,2);
        
        for iCheck = 1 : numChecks
            if iCheck <= numWhiteChecks
%                 checkCenters(iCheck,:) = white_check_props(iCheck).Centroid;
                all_check_centers(iCheck,1,iMask) = white_check_props(iCheck).Centroid(1);
                all_check_centers(iCheck,2,iMask) = white_check_props(iCheck).Centroid(2);
            else
%                 checkCenters(iCheck,:) = black_check_props(iCheck - numWhiteChecks).Centroid;
                all_check_centers(iCheck,1,iMask) = black_check_props(iCheck - numWhiteChecks).Centroid(1);
                all_check_centers(iCheck,2,iMask) = black_check_props(iCheck - numWhiteChecks).Centroid(2);
            end
        end
        
        % WORKING HERE TO FIGURE OUT HOW TO FLAG POTENTIAL ERRORS

%         all_check_centers(:,1,iMask) = checkCenters(:,1);
%         all_check_centers(:,2,iMask) = checkCenters(:,2);
    end

% dispMask = false(h,w);
% checkBoardMask = false(size(borderMask));
% for iMask = 1 : 6
%     checkBoardMask(:,:,iMask) = imfill(borderMask(:,:,iMask),'holes');
%     dispMask = dispMask | squeeze(checkBoardMask(:,:,iMask));
% end
% masked_img = A .* repmat(uint8(dispMask),1,1,3);



ptsMask = false(h,w);
for iMask = 1 : 6
%     scatter(squeeze(all_check_centers(:,1,iMask)),squeeze(all_check_centers(:,2,iMask)),50,'b','filled')
    q = squeeze(round(all_check_centers(:,:,iMask)));
    for ii = 1 : size(q,1)
        if all(q(ii,:) > 0)
            ptsMask(q(ii,2),q(ii,1)) = true;
        end
    end
end
ptsMask = imdilate(ptsMask,strel('disk',4));

z = imoverlay(A, ptsMask,'r');
newName = [imgList(iImg).name(1:end-4) '_marked.png'];
imwrite(z,newName,'png');

calPtsName = strrep(imgList(iImg).name,'png','mat');
calPtsName = fullfile(calImageDir,calPtsName);
save(calPtsName,'all_check_centers','whiteGridError','blackGridError');


end
