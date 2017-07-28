function points3d = compute3Dtrajectory(video, points2d, track_metadata, pawPref, boxRegions )

numFrames = size(points2d, 2);

points3d = cell(numFrames,1);
new_points2d = points2d;

timeDirection = 'forward';
[points3d,new_points2d] = compute_3Dtrajectory_loop(video, new_points2d, points3d, track_metadata, pawPref, boxRegions, timeDirection);

timeDirection = 'reverse';

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [points3d,new_points2d] = compute_3Dtrajectory_loop(video, new_points2d, points3d, track_metadata, pawPref, boxRegions, timeDirection)

zeroTol = 1e-10;
fps = video.FrameRate;
video.CurrentTime = track_metadata.triggerTime;
boxCalibration = track_metadata.boxCalibration;
cameraParams = boxCalibration.cameraParams;

if strcmpi(timeDirection,'reverse')
    numFrames = round((video.CurrentTime) * fps);
    frameCount = numFrames;
else
    numFrames = round((video.Duration - video.CurrentTime) * fps);
    frameCount = 0;
end
totalFrames = round(video.Duration * fps);

while video.CurrentTime < video.Duration && video.CurrentTime >= 0
   
    prevFrame = frameCount;
    
    if strcmpi(timeDirection,'reverse')
        frameCount = frameCount - 1;
        if frameCount == 0
            break;
        end
        video.CurrentTime = frameCount / fps;
    else
        frameCount = frameCount + 1;
    end
    currentFrame = round((video.CurrentTime) * fps);
    timeList(frameCount) = video.CurrentTime;
    fprintf('frame number %d, current frame %d\n',frameCount, currentFrame);
    
    image = readFrame(video);
    if strcmpi(timeDirection,'reverse')
        if abs(video.CurrentTime - timeList(prevFrame)) > zeroTol    % a frame was skipped
            % if going backwards, went one too many frames back, so just
            % read the next frame
            image = readFrame(video);
        end
    end
    
    if prevFrame > 0 && strcmpi(timeDirection,'forward') && ...
       abs(video.CurrentTime - timeList(prevFrame) - 2/fps) > zeroTol && ...
       video.CurrentTime - timeList(prevFrame) - 2/fps < 0
            % if going forwards, this means the CurrentTime didn't advance
            % by 1/fps on the last read (not sure why this occasionally
            % happens - some sort of rounding error)
            timeList(frameCount) = video.CurrentTime;
    else           
        timeList(frameCount) = video.CurrentTime - 1/fps;
    end

    if prevFrame > 0
        prev_im_ud = img_ud;
    else
        prev_im_ud = zeros(video.Height, video.Width, 3);
    end
    
    img_ud = undistortImage(image, cameraParams);
    img_ud = double(img_ud) / 255;
    
    [points3d{currentFrame},new_points2d] = computeNext3Dpoints( new_points2d, points3d, currentFrame, prevFrame, img_ud, boxCalibration, pawPref, boxRegions );
    
    
    
    prevFrame = currentFrame;
end


end    % function compute_3Dtrajectory_loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [frame_points3D,new_points2d] = computeNext3Dpoints( new_points2d, points3d, currentFrame, prevFrame, img_ud, boxCalibration, pawPref, boxRegions )
%
% INPUTS:
%   points2d - all of the paw points identified in all frames: 2 x n cell
%       array where n is the number of frames
%
% OUTPUTS:
%

frame_points2d = cell(1,2);
frame_points2d{1} =  new_points2d{1,currentFrame};
frame_points2d{2} =  new_points2d{2,currentFrame};

% use knowledge of where the 3D points were from the previous frame, where
% the paw was identified in the current frame/view (if at all), the current
% frame image, and where the paw was identified in adjacent frames to
% estimate where it is now

% 3 possibilities:
%   1. the paw is visible in both views. In this case, 
%
%   2. the paw is only visible in one view.

%   3. the paw is visible in neigher view

if ~isempty(new_points2d{1, currentFrame}) && ~isempty(new_points2d{2, currentFrame})
    % paw is visible in both views
    % now, figure out if the masks line up via epipolar geometry
    temp_2dpoints = masks2d_from_both_views( new_points2d, points3d, currentFrame, prevFrame, img_ud, boxCalibration, pawPref, boxRegions );
    new_points2d{1,currentFrame} = temp_2dpoints{1};
    new_points2d{2,currentFrame} = temp_2dpoints{2};
end


end    % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function new_2dpoints = masks2d_from_both_views( points2d, points3d, currentFrame, prevFrame, img_ud, boxCalibration, pawPref, boxRegions )
    
h = size(img_ud,1);w = size(img_ud,2);
orig_mask_dilate = 40;
% find instances where the epipolar tangent lines  
tanPts = zeros(2,2,2);   % x,y,view
tanLines = zeros(2,3,2);   % x,y,view
borderpts = zeros(2,4,2);
pawMask = cell(1,2);
ext_pts = cell(1,2);

frame_points2d = cell(1,2);
frame_points2d{1} =  points2d{1,currentFrame};
frame_points2d{2} =  points2d{2,currentFrame};

switch lower(pawPref)
    case 'right'
        F = squeeze(boxCalibration.srCal.F(:,:,1));
    case 'left'
        F = squeeze(boxCalibration.srCal.F(:,:,2));
end
            
[~,epipole] = isEpipoleInImage(F,[h,w]);

projMask = cell(1,2);
regions_to_search = cell(1,2);
bbox = zeros(2,4);
for iView = 1 : 2
    
    cvx_hull_idx = convhull(frame_points2d{iView});
    pawMask{iView} = poly2mask(frame_points2d{iView}(cvx_hull_idx,1),frame_points2d{iView}(cvx_hull_idx,2),h,w);
    pawMask{iView} = bwconvhull(pawMask{iView},'union');
    mask_ext = bwmorph(pawMask{iView},'remove');
    
    projMask{iView} = projMaskFromTangentLines(pawMask{iView}, F, [1,1,w-1,h-1], [h,w]);
    
    [y,x] = find(mask_ext);
    s = regionprops(mask_ext,'Centroid');
    ext_pts{iView} = sortClockWise(s.Centroid,[x,y]);
    
%     s = regionprops(imdilate(mask_ext,strel('disk',orig_mask_dilate)),'boundingbox');
%     bbox(iView,:) = s.BoundingBox;
%     
%     cur_bbox = round(bbox(iView,:));
%     img_to_thresh = img_ud(cur_bbox(2):cur_bbox(2)+cur_bbox(4),cur_bbox(1):cur_bbox(1)+cur_bbox(3),:);
%     cur_mask = pawMask{iView}(cur_bbox(2):cur_bbox(2)+cur_bbox(4),cur_bbox(1):cur_bbox(1)+cur_bbox(3));
    
    [tanPts(:,:,iView), tanLines(:,:,iView)] = findTangentToBlob(pawMask{iView}, epipole);
    
    % find the maximum region based on current masks that can contain paw
    % pixels
    
    %  DO I NEED THIS OR WAS THIS JUST FOR DEBUGGING PURPOSES?
    for i_pt = 1 : 2
        borderpts(i_pt,:,iView) = lineToBorderPoints(tanLines(i_pt,:,iView),[h,w]);
    end
    
end
ext_pts{2} = flipud(ext_pts{2});   % now these points are sorted in the clockwise direction
regions_to_search{1} = projMask{2} & ~projMask{1};
regions_to_search{2} = projMask{1} & ~projMask{2};

% now find points in each view that DO NOT have corresponding points in the
% other view
img_gray = rgb2gray(img_ud);
W = gradientweight(img_gray);

% expand the direct view if it needs to be
iView = 1;
otherView = 3-iView;
searchRegion = regions_to_search{iView} & imdilate(pawMask{iView},strel('disk',orig_mask_dilate));

newMask = pawMask;
if any(searchRegion(:))   % only need to expand the direct mask if its projection doesn't fully encompass the mirror view
    testMask = pawMask{2} & ~boxRegions.intMask;
    
    % NEED TO PUT A CHECK HERE TO SEE IF THE PAW IS INSIDE THE BOX BUT ALL
    % THE WAY BELOW THE SHELF
    
    if any(testMask(:))   % at least some of the paw is outside the box OR the paw is entirely below the shelf

        seg_thresh = 0.001;
        overlapTest = pawMask{2} & ~projMask{1};
        while any(overlapTest(:))
            new_seg = imsegfmm(W,pawMask{iView},seg_thresh);
            new_seg_proj = projMaskFromTangentLines(new_seg, F, [1,1,w-1,h-1], [h,w]);

            overlapTest = pawMask{otherView} & ~new_seg_proj;
            seg_thresh = seg_thresh + 0.001;
        end
        
        newMask{1} = (new_seg & regions_to_search{iView}) | pawMask{1};

    else    % the paw could be partially obscured by the shelf
        
        % WILL EITHER HAVE TO USE THE PREVIOUS IMAGE OR JUST GUESS THAT THE
        % CLOSEST POINT TO THE MIRROR PROJECTION WILL GIVE A REASONABLY
        % ACCURATE EXTENSION OF THE CURRENT MASK
        
    end
    
end

iView = 2;
otherView = 3-iView;
searchRegion = regions_to_search{iView} & imdilate(pawMask{iView},strel('disk',orig_mask_dilate));
if any(searchRegion(:))   % only need to expand the mirror mask if its projection doesn't fully encompass the direct view
    
end

    
    
    % how many places to search are there (could be one above and one below
    % original mask)
    
    % calculate mean rgb values for current paw mask
    
    searchLabel = bwlabel(searchRegion);
    
    for i_searchRegion = 1 : max(searchLabel(:))
        
        cur_region = (searchLabel == i_searchRegion);
%         [meanRGB,stdRGB] = RGBstats(img_ud,pawMask{iView});
        
        % are there any points in the search region that match with the
        % previous region stats?
        test_img = img_ud .* repmat(double(cur_region),[1,1,3]);
        
        
                
        
        % find the closest point to the current mask that extends out from
        % the current mask
        
    
    
    

    
    search_img = img_ud .* repmat(double(searchRegion),[1,1,3]);
    
    
    
    epiLines = epipolarLine(F, ext_pts{iView});   % start with the direct view
    numEdgePts = size(epiLines,1);
    
    % find the indices of all epipolar lines that don't have a match in the
    % other view
    epiLines_to_check = [];
    num_epiLines_without_match = 0;
    for ii = 1 : numEdgePts
        
        lineValue = epiLines(ii,1) * ext_pts{otherView}(:,1) + ...
                    epiLines(ii,2) * ext_pts{otherView}(:,2) + epiLines(ii,3);

        [intersect_idx, isLocalExtremum] = detectCircularZeroCrossings(lineValue);
        
        if ~any(intersect_idx)
            % no intersections between the epipolar line and the other paw
            % region. Need to look for where the paw is likely to be...
            num_epiLines_without_match = num_epiLines_without_match + 1;
            epiLines_to_check(num_epiLines_without_match) = ii;
        end
        
    end
    if num_epiLines_without_match == 0; continue; end
        
    % create projection masks to look for the paw
    epiMask = false(h,w);
    for i_line = 1 : num_epiLines_without_match
        epiMask = epiMask | mask_along_epiLine( epiLines(epiLines_to_check(i_line),:), pawMask{otherView} );
    end
            
            

    
end    % for iView...

end    % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function epiMask = mask_along_epiLine( epiLine, pawMask, varargin )
pawDilate = 50;
max_dist_from_line = 1;

for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'pawdilate'
            pawDilate = varargin{iarg + 1};
        case 'maxdistfromline'
            max_dist_from_line = varargin{iarg + 1};
    end
end

searchMask = imdilate(pawMask,strel('disk',pawDilate));
[y_pawMask,x_pawMask] = find(searchMask);

% find points close to the epipolarLine
testValues = epiLine(1) * x_pawMask + epiLine(2) * y_pawMask + epiLine(3);
epi_pts_idx = find(abs(testValues) < max_dist_from_line);

epiMask = false(size(pawMask));

for ii = 1 : length(epi_pts_idx) 
    epiMask(y_pawMask(epi_pts_idx(ii)),x_pawMask(epi_pts_idx(ii))) = true;
end

end