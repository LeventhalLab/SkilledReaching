function plotTracks(tracks, image_ud, mask_bbox)

figure(1)
set(gcf,'name','direct view mask')
digitMasks = false(size(tracks(2).digitmask1));
for ii = 2 : 5
    digitMasks = digitMasks | tracks(ii).digitmask1;
end
imshow(digitMasks);
hold on
for ii = 2 : 5
    scatter(tracks(ii).currentDigitMarkers(1,:,1), tracks(ii).currentDigitMarkers(2,:,1));
end    


figure(2)
set(gcf,'name','mirror view mask')
digitMasks = false(size(tracks(2).digitmask2));
for ii = 2 : 5
    digitMasks = digitMasks | tracks(ii).digitmask2;
end
imshow(digitMasks);
hold on
for ii = 2 : 5
    scatter(tracks(ii).currentDigitMarkers(1,:,2), tracks(ii).currentDigitMarkers(2,:,2));
end   

figure(3);
imshow(image_ud);
hold on
for ii = 2 : 5
    temp_x = tracks(ii).currentDigitMarkers(1,:,1) + mask_bbox(1,1);
    temp_y = tracks(ii).currentDigitMarkers(2,:,1) + mask_bbox(1,2);
    scatter(temp_x, temp_y);
    
    temp_x = tracks(ii).currentDigitMarkers(1,:,2) + mask_bbox(2,1);
    temp_y = tracks(ii).currentDigitMarkers(2,:,2) + mask_bbox(2,2);
    scatter(temp_x, temp_y);
end   