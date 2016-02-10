function showTracking(image_ud,fullMask, bbox)

figure(1)
imshow(image_ud)

edge_pts = cell(1,2);

    for iView = 1 : 2
        mask_outline = bwmorph(fullMask{iView},'remove');
        [y,x] = find(mask_outline);
        edge_pts{iView} = [x,y];
    end
    
    hold on
    rectangle('position',bbox(1,:));
    rectangle('position',bbox(2,:));
    plot(edge_pts{1}(:,1),edge_pts{1}(:,2),'marker','.','linestyle','none')
    plot(edge_pts{2}(:,1),edge_pts{2}(:,2),'marker','.','linestyle','none')