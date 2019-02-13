function [farthestDist,ptsIdx]= findFarthestPoints(X)
%
% INPUTS
%   X - m x n matrix containing m points of dimension n
%
%
% OUTPUTS
%   farthestDist - farthest euclidean distance between any 2 points in X
%   ptsIdx - indices of rows containing farthest separated points

farthestDist = 0;
if sum(~isnan(X(:,1))) < 2
    ptsIdx = false(size(X,1),1);
    return;
end
for iRow = 1 : size(X,1)
    
    currentPt = X(iRow,:);
    otherPts = X;
    for jj = 1 : size(X,1)
        if isnan(otherPts(jj,1))
            
            % if a row is NaNs, set it equal to the current point so the
            % distance between it and the reference point will be zero
            otherPts(jj,:) = currentPt;
        end
    end
    [currentMaxDist, currentIdx] = findFarthestPoint(X(iRow,:),otherPts);
    
    if currentMaxDist > farthestDist
        farthestDist = currentMaxDist;
        
        ptsIdx = false(size(X,1),1);
        ptsIdx(iRow) = true;
        ptsIdx(currentIdx) = true;
        
    end
    
end