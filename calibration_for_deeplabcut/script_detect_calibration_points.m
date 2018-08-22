% detect checkerboard calibration images, 20180605

% calImageDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Calibration Images';
% calImageDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Calibration Images';
calImageDir = '/Volumes/Tbolt_01/Skilled Reaching/calibration_images';

camParamFile = '/Users/dan/Documents/Leventhal lab github/SkilledReaching/Manual Tracking Analysis/ConvertMarkedPointsToReal/cameraParameters.mat';
% camParamFile = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/multiview geometry/cameraParameters.mat';
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
ROIs = [700,375,650,600;
        750,1,600,400;
        1,400,350,500;
        rightMirrorLeftEdge,400,w-rightMirrorLeftEdge,500];
    
numBoards = size(ROIs,1) - 1;

mirrorOrientation = {'top','left','right'};
   
cd(calImageDir);

[imFiles_from_same_date, dateList] = groupCalibrationImagesbyDate(imgList);
numDates = length(dateList);

for iDate = 1 : numDates
    
    numFilesPerDate = length(imFiles_from_same_date{iDate});
    img = cell(1, numFilesPerDate);
    for iImg = 1 : numFilesPerDate

        curImgName = imFiles_from_same_date{iDate}{iImg};
        img{iImg} = imread(curImgName);
        
    end
%         if ~isempty(strfind(imgList(iImg).name,'marked'))
%             continue;
%         end

%         dImg = A(ROIs(1,2):ROIs(1,2)+ROIs(1,4),ROIs(1,1):ROIs(1,1)+ROIs(1,3),:);
%         lImg = A(ROIs(3,2):ROIs(3,2)+ROIs(3,4),ROIs(3,1):ROIs(3,1)+ROIs(3,3),:);
%         rImg = A(ROIs(4,2):ROIs(4,2)+ROIs(4,4),ROIs(4,1):ROIs(4,1)+ROIs(4,3),:);
    
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
                
                % now undistoring points in findMaskedCheckerboards
%                 curDirectChecks = undistortPoints(curDirectChecks, cameraParams);
%                 curMirrorChecks = undistortPoints(curMirrorChecks, cameraParams);
                
                matchIdx = matchCheckerboardPoints(curDirectChecks, curMirrorChecks, mirrorOrientation{iBoard});
                
                matchStartIdx = (iImg-1) * points_per_board + 1;
                matchEndIdx = (iImg) * points_per_board;
                
                allMatchedPoints(matchStartIdx:matchEndIdx,:,1,iBoard) = curDirectChecks(matchIdx(:,1),:);
                allMatchedPoints(matchStartIdx:matchEndIdx,:,2,iBoard) = curMirrorChecks(matchIdx(:,2),:);
            end

        end
    end
    
    matFileName = ['GridCalibration_' dateList{iDate} '_auto.mat'];
    save(matFileName, 'directChecks','mirrorChecks','allMatchedPoints','dir_foundValidPoints','mir_foundValidPoints','cameraParams');
    
    if saveMarkedImages
        for iImg = 1 : 3
            
            newImg = undistortImage(img{iImg},cameraParams);
            
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
            imwrite(newImg,newImgName,'png');
        end       
    end
end
    
    % now should have identified matched points in any views in which the
    % checkerboards were "easy" to detect
    
    % go back and see if we can find any additional points now that we can
    % estimate the fundamental matrix for each mirror and look for matched
    % points along epipolar lines defined by checkerboard points that were
    % identified on the first pass but didn't have a match
%     for iBoard = 1 : numBoards
%         if all(matchedCheckerboards(iBoard,:))
%             % already identified checkerboard points in every image
%             continue;
%         end
%         % estimate the fundamental matrix from the known matches
%         mp1 = squeeze(allMatchedPoints(:,:,1,iBoard));
%         mp2 = squeeze(allMatchedPoints(:,:,2,iBoard));
%         mp1 = mp1(~isnan(mp1(:,1)),:);
%         mp2 = mp2(~isnan(mp2(:,1)),:);
% 
%         F = fundMatrix_mirror(mp1,mp2);
%         [~,epiPt] = isEpipoleInImage(F,[h,w]);
%         
%         for iImg = 1 : numFilesPerDate
%             if matchedCheckerboards(iBoard,iImg)
%                 % already have matches for this view in this image
%                 continue;
%             end
%             
%             if ~dir_foundValidPoints(iBoard,iImg) && ~mir_foundValidPoints(iBoard,iImg)
%                 % didn't find points in the direct or mirror view for this
%                 % combination, so additional efforts are futile
%                 continue;
%             end
%             
%             img_ud = undistortImage(img{iImg},cameraParams);
% 
%             % which view did we already find the checkerboard points in?
%             if dir_foundValidPoints(iBoard,iImg)
%                 % found direct view checkerboard points earlier
%                 knownPts = squeeze(directChecks(:,:,iBoard,iImg));
%                 ROI = ROIs(iBoard+1,:);
%                 initMask = squeeze(initMirBorderMask(:,:,iBoard,iImg));
%             else
%                 % found mirror view checkerboard points earlier
%                 knownPts = squeeze(mirrorChecks(:,:,iBoard,iImg));
%                 ROI = ROIs(1,:);
%                 initMask = squeeze(initDirBorderMask(:,:,iBoard,iImg));
%             end
%             knownPts = undistortPoints(knownPts, cameraParams);
%             newBoardPts = detectMatchingCheckerboard(img_ud, epiPt, ROI, knownPts);
%                 
%         end
%     end
    %%
%     numViews = size(directBorderMask{1},3);
% %     direct_whiteMask = false(h,w,numViews, numFilesPerDate);
% %     direct_blackMask = false(h,w,numViews, numFilesPerDate);
% %     mirror_whiteMask = false(h,w,numViews, numFilesPerDate);
% %     mirror_blackMask = false(h,w,numViews, numFilesPerDate);
%     
%     for iImg = 1 : numFilesPerDate
%         testGray = adapthisteq(rgb2gray(img{iImg}));
%         for iView = 1 : 3
%             borderMask = directBorderMask{iImg}(:,:,iView);
%             boardMask = imfill(borderMask,'holes') & ~borderMask;
% %             boardMask = bwconvhull(boardMask);
%             boardMask = imclose(boardMask,strel('disk',5));
%             boardMask = imopen(boardMask,strel('disk',5));
% 
% %             [direct_whiteMask(:,:,iView,iImg), direct_blackMask(:,:,iView,iImg), errorFlag] = isolateCheckerboardSquares_20180618(testGray, boardMask, anticipatedBoardSize);
%             
% %             figure(iView*2-1)
% %             imshow(whiteMask | blackMask)
% %             set(gcf,'name','direct')
%             
%             borderMask = mirrorBorderMask{iImg}(:,:,iView);
%             boardMask = imfill(borderMask,'holes') & ~borderMask;
%             boardMask = bwconvhull(boardMask);
%             
%             boardMask = imclose(boardMask,strel('disk',5));
%             boardMask = imopen(boardMask,strel('disk',5));
% 
%             [mirror_whiteMask(:,:,iView,iImg), mirror_blackMask(:,:,iView,iImg), errorFlag] = isolateCheckerboardSquares_20180618(testGray, boardMask, anticipatedBoardSize);
%             
%             matchIdx = matchCheckerboardPoints(direct_whiteMask(:,:,iView,iImg),mirror_whiteMask(:,:,iView,iImg),mirrorOrientation{iView});
% %             figure(iView * 2)
% %             imshow(whiteMask | blackMask)
% %             set(gcf,'name','mirror')
%         end
%         
%     end
%     
%     registerCheckerBoards(img, directBorderMask, mirrorBorderMask, mirrorOrientation);
% 
% 
%         
% 
%         figure(1)
%         imshow(directBorderMask(:,:,1) | directBorderMask(:,:,2) | directBorderMask(:,:,3))
% 
%         figure(2)
%         imshow(mirrorBorderMask(:,:,1) | mirrorBorderMask(:,:,2) | mirrorBorderMask(:,:,3))
% 
%         figure(3)
%         imshow(A);
%         hold on
%         scatter(directBorderChecks(:,1,1),directBorderChecks(:,2,1));
%         scatter(directBorderChecks(:,1,2),directBorderChecks(:,2,2));
%         scatter(directBorderChecks(:,1,3),directBorderChecks(:,2,3));
% 
%     %     mirrorBorderMask = findMirrorCheckerboards(A, directBorderMask, directBorderChecks, mirror_hsvThresh, boardSize, ROIs, cameraParams);
%     % %     borderMask = findColoredBorder(A, hsvThresh, ROIs);
%     %     dispMask = false(h,w);
%     %     for iMask = 1 : 6
%     %         dispMask = dispMask | squeeze(borderMask(:,:,iMask));
%     %     end
%     %     
% 
% 
% end