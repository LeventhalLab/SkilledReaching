function d = distFromBlob(mask,pt)

% if mask(pt(2),pt(1))
%     d = 0;
%     return;
% end
% 
% ext_pts = bwmorph(mask,'remove');
[y,x] = find(mask);

[d,~] = findNearestNeighbor(pt,[x,y]);    