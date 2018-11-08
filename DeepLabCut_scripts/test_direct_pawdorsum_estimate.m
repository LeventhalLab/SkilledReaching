frameRate = 300;


bodypartColor.dig = [1 0 0;
                     1 0 1;
                     1 1 0;
                     0 1 0];
bodypartColor.otherPaw = [0 1 1];
bodypartColor.paw_dorsum = [0 0 1];
bodypartColor.pellet = [0 0 0];
bodypartColor.nose = [0 0 0];

        ROIs = vidROI(1:2,:);
        Pn = squeeze(boxCal.Pn(:,:,2));
        scaleFactor = mean(boxCal.scaleFactor(2,:));
        F = squeeze(boxCal.F(:,:,2));

[mcp_idx,pip_idx,digit_idx,pawdorsum_idx,nose_idx,pellet_idx,otherpaw_idx] = group_DLC_bodyparts(bodyparts,pawPref);

for iFrame = 291:310
    
    video.CurrentTime = iFrame/frameRate;
    
    curFrame = readFrame(video);
    
    curFrame_ud = undistortImage(curFrame,boxCal.cameraParams);
    
    figure(1)
    
    imshow(curFrame_ud)
    
    hold on
    
    for i_bp = 1 : 16
        
        markerColor = getMarkerColor(bodyparts{i_bp}, bodypartColor, pawPref);
        
        cur_direct_pts = squeeze(direct_pts(i_bp,iFrame,:));
        
        cur_mirror_pts = squeeze(mirror_pts(i_bp,iFrame,:));
        
        cur_mirror_pts(1) = cur_mirror_pts(1) + ROIs(2,1) - 1;
        cur_mirror_pts(2) = cur_mirror_pts(2) + ROIs(2,2) - 1;
    
        cur_direct_pts(1) = cur_direct_pts(1) + ROIs(1,1) - 1;
        cur_direct_pts(2) = cur_direct_pts(2) + ROIs(1,2) - 1;
        
        cur_direct_pts = undistortPoints(cur_direct_pts',boxCal.cameraParams);
        cur_mirror_pts = undistortPoints(cur_mirror_pts',boxCal.cameraParams);
        
        scatter([cur_direct_pts(1);cur_mirror_pts(1)],...
                [cur_direct_pts(2);cur_mirror_pts(2)], 36, markerColor);
            
    
    end
    
    scatter(final_directPawDorsum_pts(iFrame,1),final_directPawDorsum_pts(iFrame,2),50,'*')
    set(gcf,'name',sprintf('frame number %d',iFrame));
end