% detect checkerboard calibration images, 20180605

calImageDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Calibration Images';

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
    
    curImgName = imgList(iImg).name;
    
    A = imread(curImgName);
    Ahsv = rgb2hsv(A);
    
%     figure(1)
%     imshow(A)
    
    [initBorderMask, borderMask] = findColoredBorder(Ahsv, hsvThresh, ROIs);
    
    % now find the checkerboard points
    checkBoardMask = false(h,w,6);
%     fullRegionMask = false(h,w,6);
    all_check_centers = zeros(prod(anticipatedBoardSize), 2, 6);
    for iMask = 1 : 6
        tempMask = imfill(squeeze(borderMask(:,:,iMask)),'holes') & ~squeeze(borderMask(:,:,iMask));
        tempMask = imclose(tempMask,strel('disk',50));  % get rid of bumps in the border
        tempMask = imopen(tempMask,strel('disk',5));
        cvHull = bwconvhull(tempMask);

        checkBoardMask(:,:,iMask) = cvHull;
%         fullRegionMask(:,:,iMask) = checkBoardMask(:,:,iMask) | borderMask(:,:,iMask);
%         checkBoardMask(:,:,iMask) = imdilate(squeeze(checkBoardMask(:,:,iMask)), strel('disk',5));
        
        % find the bounding box for the current checkerboard
        bboxstats = regionprops(squeeze(borderMask(:,:,iMask)),'boundingbox');
        bbox = floor(bboxstats.BoundingBox);
        
        testImg = A .* repmat(uint8(squeeze(checkBoardMask(:,:,iMask))),1,1,3);
%         testImg_withBorder = A .* repmat(uint8(squeeze(fullRegionMask(:,:,iMask))),1,1,3);
        testRegion = testImg(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3),:);
        testRegion = imsharpen(testRegion);
        testRegionFull = A(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3),:);

        
        % now detect this checkerboard
        testRegionGray = rgb2gray(testRegion);
        checkThresh = graythresh(testRegionGray);
        check_bw = double(testRegionGray)/255 > checkThresh;
        check_bw = imopen(check_bw,strel('disk',3));
        
        [isolated_checks, eroded_checks, ~] = isolateCheckerboardSquares(check_bw,anticipatedBoardSize,'minarea',minCheckArea);
        isolated_checks_white = isolated_checks | eroded_checks;
        
        check_bw = double(testRegionGray)/255 < checkThresh & double(testRegionGray)/255 > 0;
        check_bw = imopen(check_bw,strel('disk',3));
        [isolated_checks, eroded_checks, ~] = isolateCheckerboardSquares(check_bw,anticipatedBoardSize,'minarea',minCheckArea);
        isolated_checks_black = isolated_checks | eroded_checks;
        
        % find mean RGB values for border, white checks, black checks
        
        A_r = squeeze(testRegionFull(:,:,1));
        A_b = squeeze(testRegionFull(:,:,2));
        A_g = squeeze(testRegionFull(:,:,3));
        A_r = A_r(:);
        A_b = A_b(:);
        A_g = A_g(:);
        initBorderROI = initBorderMask(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3),iMask);
        mean_white_checks_R = mean(A_r(isolated_checks_white(:))) / 255;
        mean_black_checks_R = mean(A_r(isolated_checks_black(:))) / 255;
        mean_white_checks_G = mean(A_g(isolated_checks_white(:))) / 255;
        mean_black_checks_G = mean(A_g(isolated_checks_black(:))) / 255;
        mean_white_checks_B = mean(A_b(isolated_checks_white(:))) / 255;
        mean_black_checks_B = mean(A_b(isolated_checks_black(:))) / 255;
        mean_border_R = mean(A_r(initBorderROI(:))) / 255;
        mean_border_G = mean(A_g(initBorderROI(:))) / 255;
        mean_border_B = mean(A_b(initBorderROI(:))) / 255;
        
        mean_whiteRGB = [mean_white_checks_R, mean_white_checks_G, mean_white_checks_B];
        mean_blackRGB = [mean_black_checks_R, mean_black_checks_G, mean_black_checks_B];
        mean_borderRGB = [mean_border_R, mean_border_G, mean_border_B];
        
        blackCheckDist = zeros(size(testRegionFull));
        whiteCheckDist = zeros(size(testRegionFull));
        borderDist = zeros(size(testRegionFull));
        blackCheckDist(:,:,1) = abs(double(testRegionFull(:,:,1)) / 255 - mean_black_checks_R);
        blackCheckDist(:,:,2) = abs(double(testRegionFull(:,:,2)) / 255 - mean_black_checks_G);
        blackCheckDist(:,:,3) = abs(double(testRegionFull(:,:,3)) / 255 - mean_black_checks_B);
        
        whiteCheckDist(:,:,1) = abs(double(testRegionFull(:,:,1)) / 255 - mean_white_checks_R);
        whiteCheckDist(:,:,2) = abs(double(testRegionFull(:,:,2)) / 255 - mean_white_checks_G);
        whiteCheckDist(:,:,3) = abs(double(testRegionFull(:,:,3)) / 255 - mean_white_checks_B);
        
%         borderDist(:,:,1) = abs(double(testRegionFull(:,:,1)) / 255 - mean_border_R);
%         borderDist(:,:,2) = abs(double(testRegionFull(:,:,2)) / 255 - mean_border_G);
%         borderDist(:,:,3) = abs(double(testRegionFull(:,:,3)) / 255 - mean_border_B);
        
        newBlackCheckMask = blackCheckDist(:,:,1) < RGBdistThresh & ...
                            blackCheckDist(:,:,2) < RGBdistThresh & ...
                            blackCheckDist(:,:,3) < RGBdistThresh;
        newWhiteCheckMask = whiteCheckDist(:,:,1) < RGBdistThresh & ...
                            whiteCheckDist(:,:,2) < RGBdistThresh & ...
                            whiteCheckDist(:,:,3) < RGBdistThresh;
                        
        finalBlackCheckMask = false(size(newBlackCheckMask));
        L = bwlabel(isolated_checks_black);
        for i_L = 1 : length(L)
            finalBlackCheckMask = finalBlackCheckMask | imreconstruct(L==i_L, newBlackCheckMask);
        end
        finalBlackCheckMask = isolateCheckerboardSquares(finalBlackCheckMask,anticipatedBoardSize,'minarea',minCheckArea);
        
        finalWhiteCheckMask = false(size(newWhiteCheckMask));
        L = bwlabel(isolated_checks_white);
        for i_L = 1 : length(L)
            finalWhiteCheckMask = finalWhiteCheckMask | imreconstruct(L==i_L, newWhiteCheckMask);
        end
        finalWhiteCheckMask = isolateCheckerboardSquares(finalWhiteCheckMask,anticipatedBoardSize,'minarea',minCheckArea);
%         newBorderMask = borderDist(:,:,1) < RGBdistThresh & ...
%                             borderDist(:,:,2) < RGBdistThresh & ...
%                             borderDist(:,:,3) < RGBdistThresh;
                        
                        
        
%         meanRGB_white_checks = 

%         sc1 = imerode(isolated_checks_white,strel('disk',3));
%         sc2 = imerode(isolated_checks_black,strel('disk',3));
%         sc3 = imerode(initBorderMask(:,:,iMask),strel('disk',3));
%         sc3 = sc3(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3));
%         
%         q = imseggeodesic(testRegionFull,sc1,sc2,sc3);

        % find the centroids for the white and black squares
        white_check_props = regionprops(isolated_checks_white,'Centroid');
        black_check_props = regionprops(isolated_checks_black,'Centroid');
        
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
        
        try
            all_check_centers(:,1,iMask) = checkCenters(:,1)+bbox(1)-1;
        catch
        end
        
        all_check_centers(:,2,iMask) = checkCenters(:,2)+bbox(2)-1;

    end
    dispMask = false(h,w);
    for iMask = 1 : 6
        dispMask = dispMask | squeeze(checkBoardMask(:,:,iMask));
    end
    masked_img = A .* repmat(uint8(dispMask),1,1,3);
    
    figure(2)
    hold off
    imshow(masked_img)
    hold on
    for iMask = 1 : 6
        scatter(squeeze(all_check_centers(:,1,iMask)),squeeze(all_check_centers(:,2,iMask)),50,'b','filled')
    end

    calPtsName = strrep(imgList(iImg).name,'png','mat');
    calPtsName = fullfile(calImageDir,calPtsName);
    save(calPtsName,'all_check_centers');
    
end

