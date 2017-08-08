clear all;


cb_size = [4, 5]; % expected CB size
num_pts = 12; % expected points detected
views.top = true;
views.right = true;
views.left = true;

im = imread('GridCalibration_20170528_1.png'); % cube calibration image
im = imresize(im, 0.5);
imshow(im);
title('Click point on direct view cube');

[h_center, v_center] = ginput(1); % center point on direct view cube
%[v_len, h_len, ~] = size(im);
%h_center=h_len/2;
%v_center=v_len/2;
h_center = 2*round(h_center/2); % make even for indexing
v_center = 2*round(v_center/2); % make even for indexing


% detect checkerboard points
if views.left
    
    % left mirror
    % black out rest of image to detect only left mirror checkerboard points
    left_mir = im;
    left_mir(1:v_center/2,:,:) = 0;
    left_mir(:,h_center/2:end,:) = 0;
    left_mir(v_center+round(v_center/4):end,:,:) = 0;
    %figure;
    imshow(left_mir);
    detect_size = [0,0];
    
    % adjust brightness until correct amount of points are detected
    x = 1;
    while x > 0.25 && ~all(detect_size == cb_size)
        left_mir_bright = imadjust(left_mir, [0 x], [0 1]);
        [pts.left_mir, detect_size] = detectCheckerboardPoints(left_mir_bright);
        x = x - 0.05;
    end
    
    if ~all(detect_size == cb_size)
        success.left_mir = 0;
    else
        success.left_mir = 1;
    end
    
    % left direct
    left_dir = im;
    left_dir(1:v_center-30,:,:) = 0;
    left_dir(:,1:h_center/2,:) = 0;
    left_dir(:,h_center+30:end,:) = 0;
    %figure;
    imshow(left_dir);
    detect_size = [0,0];
    
    x = 1;
    while x > 0.25 && ~all(detect_size == cb_size)
        left_dir_bright = imadjust(left_dir, [0 x], [0 1]);
        [pts.left_dir, detect_size] = detectCheckerboardPoints(left_dir_bright);
        x = x - 0.05;
    end
    
    if ~all(detect_size == cb_size)
        success.left_dir = 0;
    else
        success.left_dir = 1;
    end
    
end


if views.top
    
    % top mirror
    top_mir = im;
    top_mir(:,1:3*round(h_center/4),:) = 0;
    top_mir(:,h_center+round(h_center/4):end,:) = 0;
    top_mir(v_center/2+round(v_center/4):end,:,:) = 0;
    %figure;
    imshow(top_mir);
    detect_size = [0,0];
    
    x = 1;
    while x > 0.25 && ~all(detect_size == cb_size)
        top_mir_bright = imadjust(top_mir, [0 x], [0 1]);
        [pts.top_mir, detect_size] = detectCheckerboardPoints(top_mir_bright);
        x = x - 0.05;
    end
    
    if ~all(detect_size == cb_size)
        success.top_mir = 0;
    else
        success.top_mir = 1;
    end
    
    
    % top direct
    top_dir = im;
    top_dir(1:v_center/2,:,:) = 0;
    top_dir(v_center:end,:,:) = 0;
    top_dir(:,1:3*round(h_center/4),:) = 0;
    top_dir(:,h_center+round(h_center/4):end,:) = 0;
    %figure;
    imshow(top_dir);
    detect_size = [0,0];
    
    x = 1;
    while x > 0.25 && ~all(detect_size == cb_size)
        top_dir_bright = imadjust(top_dir, [0 x], [0 1]);
        [pts.top_dir, detect_size] = detectCheckerboardPoints(top_dir_bright);
        x = x - 0.05;
    end
    
    if ~all(detect_size == cb_size)
        success.top_dir = 0;
    else
        success.top_dir = 1;
    end
    
end

if views.right
    
    % right mirror
    right_mir = im;
    right_mir(1:v_center/2,:,:) = 0;
    right_mir(:,1:h_center+h_center/2,:) = 0;
    right_mir(v_center+round(v_center/2):end,:,:) = 0;
    %figure;
    imshow(right_mir);
    detect_size = [0,0];
    
    x = 1;
    while x > 0.25 && ~all(detect_size == cb_size)
        right_mir_bright = imadjust(right_mir, [0 x], [0 1]);
        [pts.right_mir, detect_size] = detectCheckerboardPoints(right_mir_bright);
        x = x - 0.05;
    end
    
    if ~all(detect_size == cb_size)
        success.right_mir = 0;
    else
        success.right_mir = 1;
    end
    
    
    % right direct
    right_dir = im;
    right_dir(1:v_center-30,:,:) = 0;
    right_dir(:,1:h_center-30,:) = 0;
    right_dir(:,h_center+h_center/2:end,:) = 0;
    %figure;
    imshow(right_dir);
    detect_size = [0,0];
    
    x = 1;
    while x > 0.25 && ~all(detect_size == cb_size)
        right_dir_bright = imadjust(right_dir, [0 x], [0 1]);
        [pts.right_dir, detect_size] = detectCheckerboardPoints(right_dir_bright);
        x = x - 0.05;
    end
    
    if ~all(detect_size == cb_size)
        success.right_dir = 0;
    else
        success.right_dir = 1;
    end
end


close all;

imshow(im);
hold on;
good = true;
names = fieldnames(pts);
for i=1:length(names)
    if success.(names{i})
        plot(pts.(names{i})(:,1), pts.(names{i})(:,2), 'ro', 'MarkerSize', 4)
        disp(['correct number of points detected: ' names{i}]);
    else
        disp(['incorrect number of points detected: ' names{i}]);
        good = false;
    end
end

if ~good
    disp('incorrect number of points detected for one or more views - cannot match points');
    return
end



% put matched points into p: num_pts x 2 x views matrix
% p = [left direct view
%      left mirror view
%      top direct view
%      top mirror view
%      right direct view
%      right mirror view];
num_ims = 1;
p = zeros(num_pts,2,length(fieldnames(success)));

if views.left
    if success.left_mir && success.left_dir
        [ordered.left_dir, ordered.left_mir] = matchCorrespondingPoints(pts.left_dir, pts.left_mir, true);
        p(:,:,num_ims) = ordered.left_dir;
        p(:,:,num_ims+1) = ordered.left_mir;
        num_ims=num_ims+2;
    else
        views.left=false;
    end
end

if views.top
    if success.top_dir && success.top_mir
        [ordered.top_dir, ordered.top_mir] = matchCorrespondingPoints(pts.top_dir, pts.top_mir, false);
        p(:,:,num_ims) = ordered.top_dir;
        p(:,:,num_ims+1) = ordered.top_mir;
        num_ims=num_ims+2;
    else
        views.top=false;
    end
end

if views.right
    if success.right_dir && success.right_mir
        [ordered.right_dir, ordered.right_mir] = matchCorrespondingPoints(pts.right_dir, pts.right_mir, true);
        p(:,:,num_ims) = ordered.right_dir;
        p(:,:,num_ims+1) = ordered.right_mir;
        num_ims=num_ims+2;
    else
        views.right=false;
    end
end

num_ims = num_ims-1;

for i=1:num_ims
    for j=1:num_pts
        plot(ordered.(names{i})(j,1), ordered.(names{i})(j,2), 'ws','MarkerSize',6,'MarkerFaceColor','w');
        text(ordered.(names{i})(j,1), ordered.(names{i})(j,2), num2str(j), 'HorizontalAlignment','center', 'FontSize', 6);
    end
end

load('camParams.mat');
K=params.IntrinsicMatrix;

if num_ims == 6
    [scale, F, P1, P2, P3, wpts, reproj] = calculate_sr_box_3Dparameters_3Views(K, p, [3,4]);
elseif num_ims == 4
    [scale, F, P1, P2, wpts, reproj] = calculate_sr_box_3Dparameters_V2(K, p, [3,4]);
end

n = fieldnames(reproj);
j=1;
for i=1:length(n)
    unnorm.(names{j}) = unnormalize_points(reproj.(n{i})(:,:,1), K);
    unnorm.(names{j+1}) = unnormalize_points(reproj.(n{i})(:,:,2), K);
    j=j+2;
end

figure;
imshow(im);
hold on;
for i=1:length(names)
        detected=plot(pts.(names{i})(:,1), pts.(names{i})(:,2), 'o', 'Color', 'g', 'MarkerSize', 4, 'DisplayName', 'detected');
        hold on;
end
for i=1:num_ims
    reprojected=plot(unnorm.(names{i})(:,1), unnorm.(names{i})(:,2), '.','Color','r',  'MarkerSize', 8, 'DisplayName', 'reprojected');    
end

legend([detected reprojected]);





%% match corresponding mirror-direct view checkerboard points

function [ordered_dir, ordered_mir] = matchCorrespondingPoints(pts_dir, pts_mir, side_mirrors)
%
% INPUTS:
% pts_dir: nx2 array of n points in direct view
% pts_mir: nx2 array of n points in corresponding mirror view
% side_mirrors: boolean, indicates side view (left or right = true, top = false)
%
% OUTPUTS:
% ordered_dir: nx2 array of n points in direct view
% ordered_mir: nx2 array of n points in corresponding mirror view
% ordered arrays are ordered so that direct and mirror view
% points correspond at each index
% ex: ordered_dir(3,1) corresponds to ordered_mir(3,1)
%

j=1;
array_dir = zeros(4,3,2);
array_mir = zeros(4,3,2);
ordered_dir = zeros(12,2);
ordered_mir = zeros(12,2);

for i=1:4 % pts to array in shape of checkerboard
    array_dir(i,:,1) = pts_dir(j:j+2,1);
    array_dir(i,:,2) = pts_dir(j:j+2,2);
    array_mir(i,:,1) = pts_mir(j:j+2,1);
    array_mir(i,:,2) = pts_mir(j:j+2,2);
    j=j+3;
end

% find 3 max points in mirror and direct = matching
corresp = zeros(3,2,2);
temp_mir = array_mir;
temp_dir = array_dir;
if side_mirrors % left or right
    for i=1:3
        [~, corresp(i,1,1)] = max(max(temp_dir(:,:,2)));
        [~, corresp(i,1,2)] = max(temp_dir(:,corresp(i,1,1),2));
        temp_dir(:,corresp(i,1,1),2) = 0;
        
        [~, corresp(i,2,1)] = max(max(temp_mir(:,:,2)));
        [~, corresp(i,2,2)] = max(temp_mir(:,corresp(i,2,1),2));
        temp_mir(:,corresp(i,2,1),2) = 0;
    end
else % top
    for i=1:3
        [~, corresp(i,1,1)] = max(max(temp_dir(:,:,1)));
        [~, corresp(i,1,2)] = max(temp_dir(:,corresp(i,1,1),1));
        temp_dir(:,corresp(i,1,1),1) = 0;
        
        [~, corresp(i,2,1)] = max(max(temp_mir(:,:,1)));
        [~, corresp(i,2,2)] = max(temp_mir(:,corresp(i,2,1),1));
        temp_mir(:,corresp(i,2,1),1) = 0;
    end
end

% order points
count=1;
for i=1:3 % cols
    for j=1:4 % rows
        if corresp(i,1,2) == 1 % edge 1
            ordered_dir(count, 1) = array_dir(j, corresp(i,1,1),1);
            ordered_dir(count, 2) = array_dir(j, corresp(i,1,1),2);
        else % edge 4
           ordered_dir(count, 1) = array_dir(corresp(i,1,2)-(j-1), corresp(i,1,1),1);
           ordered_dir(count, 2) = array_dir(corresp(i,1,2)-(j-1), corresp(i,1,1),2);
        end
        if corresp(i,2,2) == 1 % edge 1
            ordered_mir(count, 1) = array_mir(j, corresp(i,2,1),1);
            ordered_mir(count, 2) = array_mir(j, corresp(i,2,1),2);
        else % edge 4
           ordered_mir(count, 1) = array_mir(corresp(i,2,2)-(j-1), corresp(i,2,1),1);
           ordered_mir(count, 2) = array_mir(corresp(i,2,2)-(j-1), corresp(i,2,1),2);
        end
        count = count+1;
    end
end

end






