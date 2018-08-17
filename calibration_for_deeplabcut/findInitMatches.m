function initMatchIdx = findInitMatches(directPoints, mirrorPoints, mirrorView)

% INPUTS
%   mirrorPoints - m x 2 array of (x,y) points in the mirror view
%   directPoints - m x 2 array of (x,y) points in the direct view
%   mirrorView - 'left','right', or 'top'

initMatchIdx = zeros(2,2);
switch mirrorView
    case {'left','right'}
        % the top and bottom points should match
        initMatchIdx(1,1) = find(directPoints(:,2) == min(directPoints(:,2)));
        initMatchIdx(2,1) = find(directPoints(:,2) == max(directPoints(:,2)));
        initMatchIdx(1,2) = find(mirrorPoints(:,2) == min(mirrorPoints(:,2)));
        initMatchIdx(2,2) = find(mirrorPoints(:,2) == max(mirrorPoints(:,2)));

    case 'top'
        % left-most and right-most points should match.
        initMatchIdx(1,1) = find(directPoints(:,1) == min(directPoints(:,1)));
        initMatchIdx(2,1) = find(directPoints(:,1) == max(directPoints(:,1)));
        initMatchIdx(1,2) = find(mirrorPoints(:,1) == min(mirrorPoints(:,1)));
        initMatchIdx(2,2) = find(mirrorPoints(:,1) == max(mirrorPoints(:,1)));
        
end

end
