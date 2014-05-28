% Matt Gaidica, mgaidica@med.umich.edu
% Leventhal Lab, University of Michigan
% --- release: beta ---

% Matlab's hull function sometimes makes multiple points that over-define a hull-polygon, this removes
% those points (in a way, compressing the data)
function hull=cleanHull(hull)
    hull = unique(round(hull),'rows');
    hullIndexes = convhull(hull(:,1),hull(:,2),'simplify',true);
    hull = hull(hullIndexes,:);
end