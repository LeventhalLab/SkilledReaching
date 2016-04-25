%gridDir = '/Volumes/RecordingsLeventhal04/SkilledReaching/R0000/R0000-rawdata/R0000_20160301d';
gridDir = '/Users/damienjellens/Documents/TestVideos/R0112_2016031a';
gridName = 'GridCalibration_20160314_1.png';

cparamDir = '/Users/damienjellens/Box Sync/Leventhal Lab/Skilled Reaching Project/SR_box_matched_points';
cparamName = 'cameraParameters.mat';
cparamName = fullfile(cparamDir,cparamName);
load(cparamName);

HSV_limits = zeros(3,6);
HSV_limits(1,:) = [0.33,0.1,0.8,1.0,0.8,1.0];   % green
HSV_limits(2,:) = [0.0,0.1,0.8,1.0,0.8,1.0];    % red
HSV_limits(3,:) = [0.55,0.3,0.8,1.0,0.8,1.0];   % blue


gridName = fullfile(gridDir,gridName);

grid_im = imread(gridName,'png');
grid_im_ud = undistortImage(grid_im,cameraParams);
dc_img = decorrstretch(grid_im_ud,'tol',[0,1]);
hsv_img = rgb2hsv(dc_img);

%imshow(hsv_img)

h = size(grid_im,1);
w = size(grid_im,2);

viewEdges = zeros(2,4,3);
viewEdges(1,:,1) = [400,1,1200,h-1];
viewEdges(2,:,1) = [1,1,400,h-1];

viewEdges(1,:,2) = [400,320,1200,h-321];
viewEdges(2,:,2) = [400,1,1200,320];

viewEdges(1,:,3) = [400,1,1200,h-1];
viewEdges(2,:,3) = [1200,1,w-1201,h-1];

% mask based on color
col_masks = false(size(hsv_img));
for iCol = 1 : 1
    col_masks(:,:,iCol) = HSVthreshold(hsv_img,HSV_limits(iCol,:));
    SE = strel('disk',2);
    col_masks(:,:,iCol) = imopen(col_masks(:,:,iCol),SE);
    col_masks(:,:,iCol) = imclose(col_masks(:,:,iCol),SE);
    col_masks(:,:,iCol) = imfill(col_masks(:,:,iCol),'holes');
    
    % find the boxes for each color
    s = regionprops(col_masks(:,:,iCol),'area');
    lmat = bwlabel(col_masks(:,:,1));
    
    % pick out the two biggest regions to keep
    [~,idx] = sort([s.Area]);
    col_masks(:,:,iCol) = (lmat == idx(end) | lmat == idx(end-1));
end

masked_im = uint8(zeros(h,w,3,2,3));   % height by width by color channel by view by target color

for iCol = 1 : 1 %??? only working for green... 1 : 1
    
    for iView = 1 : 2 %1 is front view, 2 is side view
        
        regionMask = false(h,w);
        regionMask(viewEdges(iView,2,iCol):viewEdges(iView,2,iCol)+viewEdges(iView,4,iCol),...
                   viewEdges(iView,1,iCol):viewEdges(iView,1,iCol)+viewEdges(iView,3,iCol)) = true;
               
        tempMask = col_masks(:,:,iCol) & regionMask;
        masked_im(:,:,:,iView,iCol) = grid_im_ud .* uint8(repmat(tempMask,1,1,3));
        %masked_imGreen = grid_im_ud .* uint8(repmat(tempMask,1,1,3));
        
        %tempMask = col_masks(:,:,iCol) & regionMask; %apply mask for red
        %masked_imR = grid_im_ud .* uint8(repmat(tempMask,1,1,3));
        
        %tempMask = col_masks(:,:,3) & regionMask; %apply mask for blue
        %masked_imB = grid_im_ud .* uint8(repmat(tempMask,1,1,3));
      
        %find the checkerboard points
        currentMask = squeeze(masked_im(:,:,:,iView,iCol));
        [cb_pts,cb_size] = detectCheckerboardPoints(currentMask)
        %[cb_pts2,cb_size2] = detectCheckerboardPoints(masked_imGreen_2);
        
        %[cb_pts1,cb_size1] = detectCheckerboardPoints(masked_imR)
        %[cb_pts2,cb_size2] = detectCheckerboardPoints(masked_imR_2);
        
        %[cb_pts1,cb_size1] = detectCheckerboardPoints(masked_imB)
        %[cb_pts2,cb_size2] = detectCheckerboardPoints(masked_imB_2);
        
        %overlay checkerboard points onto image
        figure(iView)
        imshow(currentMask);
        hold on
        plot(cb_pts(:,1),cb_pts(:,2),'marker','*','linestyle','none')
        hold off
        %plot(cb_pts(:,1),cb_pts(:,2),'marker','*','linestyle','none')
        
        %display combined grid and image
        
        
        
        %imshow(masked_imR);
        %imshow(masked_imB);
             
    
    end
       
end

% green mask, direct view
%   squeeze(masked_im(:,:,:,1,1))
