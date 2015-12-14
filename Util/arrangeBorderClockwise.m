function [new_points, idx] = arrangeBorderClockwise(mask_ext)


new_points = zeros(size(mask_ext));
numPoints  = size(mask_ext,1);
idx = zeros(numPoints,1);

new_points(1,:) = mask_ext(1,:);
idx(1) = 1;

connectivity = 8;

for ii = 1 : numPoints - 1
    % find all connected points to the current point
    [~,poss_idx] = findAdjacentPoints(mask_ext, new_points(ii,:), connectivity);
    poss_idx = find(poss_idx);
    if ii > 1
        poss_idx = poss_idx(~ismember(poss_idx,idx(1:ii)));
    end
    
    if length(poss_idx) == 1
        valid_idx = poss_idx;
    elseif ii == 1
        valid_idx = poss_idx(1);
    else
        % what if there are 2 neighboring points that haven't been assigned
        % yet?
        
        valid_idx = selectNextPoint(mask_ext, valid_idx, idx, connectivity);
        % in above line, valid_idx in the selectNextPoint arguments is from
        % the previous iteration

    end

    idx(ii+1) = valid_idx;
    new_points(ii+1,:) = mask_ext(valid_idx,:);
    
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function next_pt_idx = selectNextPoint(mask_ext, current_idx, assigned_idx, connectivity)

foundNextPoint = false;
% pts_to_exclude = assigned_idx;
% currentTestPoint = current_idx;

% find all adjacent points to the current point
[~, poss_idx] = findAdjacentPoints(mask_ext, ...
                                   mask_ext(current_idx,:), ...
                                   connectivity);
poss_idx = find(poss_idx);
poss_idx = poss_idx(~ismember(poss_idx,assigned_idx));

for ii = 1 : length(poss_idx)
    % if the current poss_idx point has no adjacent points that either
    % haven't already been assigned or are another possible next point
    % around the perimeter, we've found the next point

    [~, next_poss_idx] = findAdjacentPoints(mask_ext, ...
                                            mask_ext(poss_idx(ii),:), ...
                                            connectivity);
	next_poss_idx = find(next_poss_idx);
    next_poss_idx = next_poss_idx(~ismember(next_poss_idx,[assigned_idx; poss_idx]));
    if isempty(next_poss_idx)
        foundNextPoint = true;
        next_pt_idx = poss_idx(ii);
    elseif length(next_poss_idx) == 1
        % if there is exactly one adjacent point, does that point have any
        % adjacent points that haven't already been accounted for. If not,
        % then poss_idx(ii) must be the next point around the perimeter
        [~,next_next_poss_idx] = findAdjacentPoints(mask_ext, ...
                                                    mask_ext(next_poss_idx,:), ...
                                                    connectivity);
        next_next_poss_idx = find(next_next_poss_idx);
        next_next_poss_idx = next_next_poss_idx(~ismember(next_next_poss_idx,...
                                                [assigned_idx; poss_idx; next_poss_idx]));
        if isempty(next_next_poss_idx)
            foundNextPoint = true;
            next_pt_idx = poss_idx(ii);
        end
    end
end
if foundNextPoint; return; end

% all of the potential adjacent points have 2 more potential adjacent
% points next to them. in that case, pick the possible point that is
% closest to the current point. 

% NEED TO THINK CAREFULLY ABOUT THIS - WHAT IF THE TWO ADJACENT POINTS ARE
% ON A DIAGONAL? ONE IDEA IS TO LOOK FOR POINTS THAT LIE ALONG THE SAME
% LINE?


xy_diff_adjacent_points = bsxfun(@minus, mask_ext(poss_idx,:), mask_ext(current_idx,:));
dist_adjacent_points = sqrt(sum(xy_diff_adjacent_points.^2,2));
next_pt_idx = poss_idx(dist_adjacent_points == min(dist_adjacent_points));

end

