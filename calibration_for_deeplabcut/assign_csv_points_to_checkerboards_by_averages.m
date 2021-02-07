function [new_directChecks, new_mirrorChecks] = assign_csv_points_to_checkerboards_by_averages(known_directChecks, ROIs, newPoints, anticipatedBoardSize, mirrorOrientation)
%
% INPUTS
%   ROIs - regions of interest in which to find the direct view of the
%       cube, and each mirror view in the format [x,y,w,h] where x is the
%       left x-coordinate, y is the top y-coordinate, and w and h are the 
%       width and height, respectively. First row is for direct cube view, 
%       second row top mirror, third row left mirror, fourth row right 
%       mirror
%   newPoints - m x 2 array where each row is an (x,y) pair for a marked
%       point
%
% OUTPUTS
%   new_directChecks, new_mirrorChecks

% boards are numbered 1 - top checkerboard, 2 - left checkerboard, 3 -
%   right checkerboard

% assume points come in groups of points_per_board
if isempty(newPoints)
    % no new points identified, leave new_directChecks and new_mirrorChecks
    % as all NaN's, which will 
    return;
end

points_per_board = prod(anticipatedBoardSize-1);
num_new_points = size(newPoints, 1);
num_new_boards = num_new_points / points_per_board;

if num_new_boards ~= floor(num_new_boards)
    error(sprintf('number of marked points is not a multiple of %d', points_per_board))
end

numDirectBoards = 3;
numMirrorBoards = 3;
new_directChecks = NaN(prod(anticipatedBoardSize-1), 2, numDirectBoards);
new_mirrorChecks = NaN(prod(anticipatedBoardSize-1), 2, numMirrorBoards);

board_points = NaN(prod(anticipatedBoardSize-1), 2, num_new_boards);
for i_board = 1 : num_new_boards
    
    start_idx = (i_board-1) * points_per_board + 1;
    end_idx = i_board * points_per_board;
    
    board_points(:,:,i_board) = newPoints(start_idx:end_idx,:);

end

% find mean point for each board
mean_points = squeeze(mean(board_points));
if ~isrow(mean_points)
    mean_points = mean_points';
end

is_pt_in_direct_view = false(num_new_boards,1);
for i_board = 1 : num_new_boards
    
    % first check if the average point is in the ROI for one of the mirrors
    cur_pt = mean_points(i_board,:);
    
    if is_pt_in_ROI(ROIs(1,:), cur_pt)
        % point is in the direct view
        is_pt_in_direct_view(i_board) = true;
    else
        for i_mirror = 1 : 3
            if is_pt_in_ROI(ROIs(i_mirror+1,:), cur_pt)
                new_mirrorChecks(:,:,i_mirror) = board_points(:,:,i_board);
            end
        end
    end
end

% figure out which points were in which direct view checkerboard
new_mean_direct_pts = mean_points(is_pt_in_direct_view,:);
new_direct_pts_idx = find(is_pt_in_direct_view);
known_direct_mean_pts = NaN(3,2);
for i_directBoard = 1 : 3
    known_direct_mean_pts(i_directBoard,:) = mean(squeeze(known_directChecks(:,:,i_directBoard)));
end
known_direct_mean_pts = known_direct_mean_pts(~isnan(known_direct_mean_pts));
all_mean_direct_pts = [new_mean_direct_pts; known_direct_mean_pts];

% is one of the newly checked boards the top checkerboard?
for i_new_direct_pt = 1 : size(new_mean_direct_pts,1)
    if new_mean_direct_pts(i_new_direct_pt,2) == min(all_mean_direct_pts(:,2))
        % this must be the top checkerboard
        new_directChecks(:,:,1) = board_points(:,:,new_direct_pts_idx(i_new_direct_pt));
    end
end

% is one of the newly checked boards the left checkerboard?
for i_new_direct_pt = 1 : size(new_mean_direct_pts,1)
    if new_mean_direct_pts(i_new_direct_pt,1) == min(all_mean_direct_pts(:,1))
        % this must be the top checkerboard
        new_directChecks(:,:,2) = board_points(:,:,new_direct_pts_idx(i_new_direct_pt));
    end
end

% is one of the newly checked boards the right checkerboard?
for i_new_direct_pt = 1 : size(new_mean_direct_pts,1)
    if new_mean_direct_pts(i_new_direct_pt,1) == max(all_mean_direct_pts(:,1))
        % this must be the top checkerboard
        new_directChecks(:,:,3) = board_points(:,:,new_direct_pts_idx(i_new_direct_pt));
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function in_ROI = is_pt_in_ROI(ROI, pt)

if (pt(1) >= ROI(1) && pt(1) <= ROI(1) + ROI(3)) &&...
        (pt(2) >= ROI(2) && pt(2) <= ROI(2) + ROI(4))
    in_ROI = true;
else
    in_ROI = false;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%