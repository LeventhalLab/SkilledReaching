q = squeeze(directChecks(:,:,2,:));

Fold = squeeze(boxCal.F(:,:,2));
Fnew = squeeze(boxCal_fromVid.F(:,:,2));

imSize = [1024 2040];

for ii = 1 : 3
    
    figure(ii)
    imshow(A{ii})
    hold on
    
    cur_direct = squeeze(q(:,:,ii));
    scatter(cur_direct(:,1),cur_direct(:,2),'markerfacecolor','b');
    scatter(cur_mirror(:,1),cur_mirror(:,2),'markerfacecolor','b');
    
    epilines_old = epipolarLine(Fold, cur_direct);
    epilines_new = epipolarLine(Fnew, cur_direct);
    
    borderPts_old = lineToBorderPoints(epilines_old,imSize);
    borderPts_new = lineToBorderPoints(epilines_new,imSize);
    
    line(borderPts_old(:,[1,3])',borderPts_old(:,[2,4])','color','b');
    line(borderPts_new(:,[1,3])',borderPts_new(:,[2,4])','color','r');

end

ii = 1;

   imshow(A{ii})
    hold on
    
dist_from_old_line = zeros(size(mp_direct,1),1);
dist_from_new_line = zeros(size(mp_direct,1),1);
for iPoint = 1 : size(mp_direct,1)
    cur_direct = mp_direct(iPoint,:);
    cur_mirror = mp_mirror(iPoint,:);
    
%     imshow(A{ii})
%     hold on
    

    epilines_old = epipolarLine(Fold, cur_direct);
    epilines_new = epipolarLine(Fnew, cur_direct);
    
    borderPts_old = lineToBorderPoints(epilines_old,imSize);
    borderPts_new = lineToBorderPoints(epilines_new,imSize);
    
%     line(borderPts_old(:,[1,3])',borderPts_old(:,[2,4])','color','b');
%     line(borderPts_new(:,[1,3])',borderPts_new(:,[2,4])','color','r');
    
    dist_from_old_line(iPoint) = distanceToLine(borderPts_old([1,2]),borderPts_old([3,4]),cur_mirror);
    dist_from_new_line(iPoint) = distanceToLine(borderPts_new([1,2]),borderPts_new([3,4]),cur_mirror);
    
%     bp_idx(iPoint)
    
end