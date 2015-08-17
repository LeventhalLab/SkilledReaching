% %%
% pawPref = lower(rat_metadata.pawPref);
% if iscell(pawPref)
%     pawPref = pawPref{1};
% end
% 
% lft_ctrPoints = boxMarkers.cbLocations.left_center_cb;
% rgt_ctrPoints = boxMarkers.cbLocations.right_center_cb;
% switch pawPref
%     case 'left',
%         dMirrorIdx = 3;   % index of mirror with dorsal view of paw
%         F_side = boxMarkers.F.right;
% %         mirrorPoints = boxMarkers.cbLocations.right_mirror_cb;
%         centerPoints = boxMarkers.cbLocations.right_center_cb;
%         numCBrows = boxMarkers.cbLocations.num_right_mirror_cb_rows;
%     case 'right',
%         dMirrorIdx = 1;   % index of mirror with dorsal view of paw
%         F_side = boxMarkers.F.left;
% %         mirrorPoints = boxMarkers.cbLocations.left_mirror_cb;
%         centerPoints = boxMarkers.cbLocations.left_center_cb;
%         numCBrows = boxMarkers.cbLocations.num_left_mirror_cb_rows;
% end
% 
% points_per_row = size(mirrorPoints,1) / numCBrows;
% 
% % mirrorPoints(:,1) = mirrorPoints(:,1) - boxMarkers.register_ROI(dMirrorIdx,1) + 1;
% % % flip left/right
% % mirrorPoints(:,1) = boxMarkers.register_ROI(dMirrorIdx,3) - mirrorPoints(:,1) + 1;
% % mirrorPoints(:,2) = mirrorPoints(:,2) - boxMarkers.register_ROI(dMirrorIdx,2) + 1;
% 
% lft_ctrPoints(:,1) = lft_ctrPoints(:,1) - boxMarkers.register_ROI(2,1) + 1;
% lft_ctrPoints(:,2) = lft_ctrPoints(:,2) - boxMarkers.register_ROI(2,2) + 1;
% 
% rgt_ctrPoints(:,1) = rgt_ctrPoints(:,1) - boxMarkers.register_ROI(2,1) + 1;
% rgt_ctrPoints(:,2) = rgt_ctrPoints(:,2) - boxMarkers.register_ROI(2,2) + 1;
% %%
% imPoints = zeros(8,2,4);
% imPoints(:,:,1) = lft_ctrPoints(1:8,:);
% imPoints(:,:,2) = lft_ctrPoints(9:16,:);
% imPoints(:,:,3) = rgt_ctrPoints(1:8,:);
% imPoints(:,:,4) = rgt_ctrPoints(9:16,:);
%%
mp = matchBoxMarkers(boxMarkers);
imPoints = mp(7:end,:,:);

worldPoints = zeros(16,2);
pprow = 4;
for ii = 1 : 4
    startIdx = (ii-1)*pprow + 1;
    endIdx = ii*pprow;
    
    worldPoints(startIdx:endIdx,1) = 0:8:24;
    worldPoints(startIdx:endIdx,2) = 8 * (ii-1);
end

%%
K = createIntrinsicMatrix();
[cparams,imUsed,estErrors] = estimateCameraParameters(imPoints, worldPoints);
Kprime = cparams.IntrinsicMatrix;
mp_norm = zeros(size(mp,1),3,size(mp,3));
for ii = 1 : 4
    mp_hom = [squeeze(mp(:,:,ii)),ones(size(mp,1),1)];
    mp_norm(:,:,ii) = (inv(K) * mp_hom')';
end
 