function [min_d,ptIdx] = findPointsClosestToBlob(pts,mask,varargin)
%
%

d = zeros(size(pts,1),1);
for ii = 1 : size(pts,1)
    d(ii) = distFromBlob(mask,pts(ii,:));
end
min_d = min(d);
ptIdx = (d==min_d);
