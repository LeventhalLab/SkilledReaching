function plotTracks(tracks, image_ud, mask_bbox)

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
for ii = 2 : 5
    plot(tracks(ii).currentDigitMarkers(1,:,2), tracks(ii).currentDigitMarkers(2,:,2),...
        'linestyle','none','marker','o','color',colList{ii-1});
end   
hold off

figure(3);
hold off
imshow(image_ud);
hold on
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