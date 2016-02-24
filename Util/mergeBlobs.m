function [bw2, n] = mergeBlobs(bw1)

n = 0;
s = regionprops(bw1,'area');
if isempty(s)
    bw2 = false(size(bw1));
    return;
end
bw2 = bw1;
while length(s) > 1
%     bw1 = bwmorph(bw1,'thicken',1);
    bw2 = imdilate(bw2,strel('disk',1));
    
    s = regionprops(bw2,'area');
    n = n + 1;
end

% fill any holes
bw2 = imfill(bw2,'holes');