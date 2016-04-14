function showTracking(image_ud,fullMask, varargin)

bbox = [];
if nargin == 3
    bbox = varargin{3};
end

figure(1)
imshow(image_ud)

edge_pts = cell(1,2);

if iscell(fullMask)
    for iView = 1 : 2
        mask_outline = bwmorph(fullMask{iView},'remove');
        [y,x] = find(mask_outline);
        edge_pts{iView} = [x,y];
    end
else
    mask_outline = bwmorph(fullMask,'remove');
    [y,x] = find(mask_outline);
    edge_pts = [x,y];
end

hold on
if ~isempty(bbox)
    rectangle('position',bbox(1,:));
    rectangle('position',bbox(2,:));
end
if iscell(edge_pts)
    plot(edge_pts{1}(:,1),edge_pts{1}(:,2),'marker','.','linestyle','none')
    plot(edge_pts{2}(:,1),edge_pts{2}(:,2),'marker','.','linestyle','none')
else
    plot(edge_pts(:,1),edge_pts(:,2),'marker','.','linestyle','none')
end