function [new_points, idx] = arrangeBorderClockwise(mask_ext)


new_points = zeros(size(mask_ext));
idx = zeros(size(mask_ext,1));

new_points(1,:) = mask_ext(1,:);
idx(1) = 1;

for ii = 1 : length(mask_ext) - 1
    % find the 2 points closest to the current point. one of them will be
    % the next point, one of them will be the previous point (if we've
    % gotten that far - meaning ii > 2)
    xy_diff = bsxfun(@minus, mask_ext, new_points(ii,:));
    dist_from_current_point = sqrt(sum(xy_diff.^2,2));
    
    % find at least the 2 closest points (maybe more if there's a third
    % point the same distance away as the first two)
    [sorted_dist, sorted_idx] = sort(dist_from_current_point);
    poss_idx = sorted_idx(2:3);
    additional_poss_idx = (sorted_dist(4:end) == sorted_dist(3));
    if any(additional_poss_idx)
        poss_idx = [poss_idx; sorted_idx(find(additional_poss_idx)+3)];
    end
    
    % first, eliminate any indices that have already been used
    
    % WORKING HERE - NOW NEED TO ELIMINATE THE ONE POINT THAT HAS ALREADY
    % BEEN USED, THEN PICK BETWEEN THE OTHER TWO SOMEHOW...
    
    if any(idx(1:ii) == poss_idx(1))
        valid_idx = poss_idx(2);
    else
        valid_idx = poss_idx(1);
    end
    
    idx(ii+1) = valid_idx;
    new_points(ii+1,:) = mask_ext(valid_idx,:);
    
end