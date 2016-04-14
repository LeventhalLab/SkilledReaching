function [new_points, idx] = arrangeBorderClockwise(ext_pts)
%
% INPUTS:
%   ext_pts - m x 2 array where each row is an (x,y) pair
%
% OUTPUTS:
%   new_points - m x 2 array where each row is an (x,y) pair, now sorted in
%       the clockwise direction
%   idx - indices of points in ext_pts in the order of new_points

new_points = zeros(size(ext_pts));
numPoints  = size(ext_pts,1);
idx = zeros(numPoints,1);

new_points(1,:) = ext_pts(1,:);
idx(1) = 1;

connectivity = 8;

for ii = 1 : numPoints - 1
    
    % find all connected points to the current point
    [~,poss_idx] = findAdjacentPoints(ext_pts, new_points(ii,:), connectivity);
    poss_idx = find(poss_idx);
    if ii > 1
        poss_idx = poss_idx(~ismember(poss_idx,idx(1:ii)));
    end
    
    if length(poss_idx) == 1
        valid_idx = poss_idx;
    elseif ii == 1    % need to figure out how to make sure the first point starts the movement in the clockwise direction
        % pick the highest point first; if still more than one candidate, pick the rightmost point
        high_idx = poss_idx(ext_pts(poss_idx,2) == min(ext_pts(poss_idx,2)));
        if length(high_idx) == 1
            valid_idx = high_idx;
        else
            right_idx = high_idx(ext_pts(high_idx,1) == max(ext_pts(high_idx,1)));
            valid_idx = right_idx;
        end
    else
        % what if there are 2 neighboring points that haven't been assigned
        % yet?
        
        valid_idx = selectNextPoint(ext_pts, valid_idx, idx, connectivity);
        % in above line, valid_idx in the selectNextPoint arguments is from
        % the previous iteration

    end

    idx(ii+1) = valid_idx;
    new_points(ii+1,:) = ext_pts(valid_idx,:);
    
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function next_pt_idx = selectNextPoint(ext_pts, current_idx, assigned_idx, connectivity)

numPossNextPoints = 0;
foundNextPoint = false;
% pts_to_exclude = assigned_idx;
% currentTestPoint = current_idx;

% find all adjacent points to the current point
[~, poss_idx] = findAdjacentPoints(ext_pts, ...
                                   ext_pts(current_idx,:), ...
                                   connectivity);
poss_idx = find(poss_idx);
poss_idx = poss_idx(~ismember(poss_idx,assigned_idx));

for ii = 1 : length(poss_idx)
    % if the current poss_idx point has no adjacent points that either
    % haven't already been assigned or are another possible next point
    % around the perimeter, we've found the next point

    [~, next_poss_idx] = findAdjacentPoints(ext_pts, ...
                                            ext_pts(poss_idx(ii),:), ...
                                            connectivity);
	next_poss_idx = find(next_poss_idx);
    next_poss_idx = next_poss_idx(~ismember(next_poss_idx,[assigned_idx; current_idx; poss_idx]));
    if isempty(next_poss_idx)
        numPossNextPoints = numPossNextPoints + 1;
        possNextPoints_idx(numPossNextPoints) = poss_idx(ii);
%         next_pt_idx = poss_idx(ii);
    elseif length(next_poss_idx) == 1
        % if there is exactly one adjacent point, does that point have any
        % adjacent points that haven't already been accounted for. If not,
        % then poss_idx(ii) must be the next point around the perimeter
        [~,next_next_poss_idx] = findAdjacentPoints(ext_pts, ...
                                                    ext_pts(next_poss_idx,:), ...
                                                    connectivity);
        next_next_poss_idx = find(next_next_poss_idx);
        next_next_poss_idx = next_next_poss_idx(~ismember(next_next_poss_idx,...
                                                [assigned_idx; poss_idx; current_idx; next_poss_idx]));
        if isempty(next_next_poss_idx)
            numPossNextPoints = numPossNextPoints + 1;
            possNextPoints_idx(numPossNextPoints) = poss_idx(ii);
%             next_pt_idx = poss_idx(ii);
        end
    end
end

if numPossNextPoints == 1
    next_pt_idx = possNextPoints_idx;
    foundNextPoint = true;
else
    numAdjacentPossPoints = zeros(numPossNextPoints, 1);
    for ii = 1 : numPossNextPoints
        [~,final_poss_idx] = findAdjacentPoints(ext_pts, ...
                                                ext_pts(possNextPoints_idx(ii),:), ...
                                                connectivity);
        final_poss_idx = find(final_poss_idx);
        final_poss_idx = final_poss_idx(~ismember(final_poss_idx,[assigned_idx;current_idx]));
        numAdjacentPossPoints(ii) = length(final_poss_idx);
    end
    temp_pt_idx = possNextPoints_idx(numAdjacentPossPoints==1);
    if length(temp_pt_idx) == 1
        next_pt_idx = temp_pt_idx;
        foundNextPoint = true;
    end
end

if foundNextPoint; return; end

% all of the potential adjacent points have 2 more potential adjacent
% points next to them. in that case, pick the possible point that is
% closest to the current point. 

% NEED TO THINK CAREFULLY ABOUT THIS - WHAT IF THE TWO ADJACENT POINTS ARE
% ON A DIAGONAL? ONE IDEA IS TO LOOK FOR POINTS THAT LIE ALONG THE SAME
% LINE?


xy_diff_adjacent_points = bsxfun(@minus, ext_pts(poss_idx,:), ext_pts(current_idx,:));
dist_adjacent_points = sqrt(sum(xy_diff_adjacent_points.^2,2));
next_pt_idx = poss_idx(dist_adjacent_points == min(dist_adjacent_points));

end

