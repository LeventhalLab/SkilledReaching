function matchedPoints = findSilhouetteCorrespondences(direct_mask,mirror_mask,bboxes, fundmat)
%
% INPUTS:
%   
%   

% WORKING HERE - GIVEN A MIRROR BLOB AND A DIRECT VIEW BLOB, FIGURE OUT
% WHICH ONE IS MORE INCLUSIVE BASED ON THE TANGENT EPIPOLAR LINES, THEN
% FIGURE OUT HOW BIG THE "REAL" OBJECT MIGHT BE INCLUDING HIDDEN BITS...


matchedPoints = [];

direct_edge = bwmorph(direct_mask,'remove');
mirror_edge = bwmorph(mirror_mask,'remove');

s_direct = regionprops(direct_mask,'Centroid');
s_mirror = regionprops(mirror_mask,'Centroid');

[direct_y, direct_x] = find(direct_edge);
[mirror_y, mirror_x] = find(mirror_edge);

direct_points = sortClockWise(s_direct.Centroid, [direct_x,direct_y]);
mirror_points = sortClockWise(s_mirror.Centroid, [mirror_x,mirror_y]);

direct_points = bsxfun(@plus,direct_points, bboxes(1,1:2));
mirror_points = bsxfun(@plus,mirror_points, bboxes(2,1:2));

% direct_y = direct_y + bboxes(1,2);
% direct_x = direct_x + bboxes(1,1);
% 
% mirror_y = mirror_y + bboxes(2,2);
% mirror_x = mirror_x + bboxes(2,1);

epiLines = epipolarLine(fundmat, direct_points);

for ii = 1 : length(direct_x)
    
    % find points in the mirror view that are on the epipolar line for the
    % current point in the direct view
    
    lineValue_mirror = epiLines(ii,1) * mirror_points(:,1) + ...
                       epiLines(ii,2) * mirror_points(:,2) + epiLines(ii,3);
                   
    lineValue_direct = epiLines(ii,1) * direct_points(:,1) + ...
                       epiLines(ii,2) * direct_points(:,2) + epiLines(ii,3);
    
    % crossing points occur when lineValue changes sign
    mirror_intersect_idx = detectZeroCrossings(lineValue_mirror);
    direct_intersect_idx = detectZeroCrossings(lineValue_direct);
    
    if length(direct_intersect_idx) == 1
        
       disp('blah') 
    end
    
    if length(direct_intersect_idx) == 0
        
       disp('blah') 
    end
    
    if isempty(mirror_intersect_idx)
        % epipolar line doesn't pass through the mirror blob
        
    else
        % epipolar line passes through the mirror blob, need to figure out
        % which point corresponds to the current point in the direct view
        
        % first, figure out where the other intersection with the direct
        % mask blob edge is
        for i_int = 1 : length(mirror_intersect_idx)
            
        end
        
    end
            
    
end

end