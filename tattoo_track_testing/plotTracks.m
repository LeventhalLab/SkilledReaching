function plotTracks(tracks, image_ud, mask_bbox, frontPanelCoords)

colList = {'r','g','b','y'};
figure(1)
hold off
set(gcf,'name','direct view mask')
digitMasks = false(size(tracks(2).digitmask1));
for ii = 1 : 5
    digitMasks = digitMasks | tracks(ii).digitmask1;
end
imshow(digitMasks);
hold on
for ii = 2 : 5
    plot(tracks(ii).currentDigitMarkers(1,:,1), tracks(ii).currentDigitMarkers(2,:,1),...
         'linestyle','none','marker','o','color',colList{ii-1});
end    
hold off

figure(2)
hold off
set(gcf,'name','mirror view mask')
digitMasks = false(size(tracks(2).digitmask2));
for ii = 1 : 5
    digitMasks = digitMasks | tracks(ii).digitmask2;
end
imshow(digitMasks);
hold on
frontPanel_x = frontPanelCoords(1,:) - mask_bbox(2,1);
frontPanel_y = frontPanelCoords(2,:) - mask_bbox(2,2);
plot(frontPanel_x,frontPanel_y,'color','m');
for ii = 2 : 5
    plot(tracks(ii).currentDigitMarkers(1,:,2), tracks(ii).currentDigitMarkers(2,:,2),...
        'linestyle','none','marker','o','color',colList{ii-1});
end   
hold off

figure(3);
hold off
imshow(image_ud);
hold on
[y1,x1] = find(bwmorph(tracks(1).digitmask1,'remove'));
y1 = y1 + mask_bbox(1,2);
x1 = x1 + mask_bbox(1,1);
plot(x1,y1,'k','linestyle','none','marker','.','markersize',1);
[y2,x2] = find(bwmorph(tracks(1).digitmask2,'remove'));
y2 = y2 + mask_bbox(2,2);
x2 = x2 + mask_bbox(2,1);
plot(x2,y2,'k','linestyle','none','marker','.','markersize',1);
for ii = 2 : 5
    temp_x = tracks(ii).currentDigitMarkers(1,:,1) + mask_bbox(1,1);
    temp_y = tracks(ii).currentDigitMarkers(2,:,1) + mask_bbox(1,2);
    plot(temp_x, temp_y,...
        'linestyle','none','marker','o','color',colList{ii-1});
    
    temp_x = tracks(ii).currentDigitMarkers(1,:,2) + mask_bbox(2,1);
    temp_y = tracks(ii).currentDigitMarkers(2,:,2) + mask_bbox(2,2);
    plot(temp_x, temp_y,...
        'linestyle','none','marker','o','color',colList{ii-1});
end   
hold off