function project_3dpoints_on_video(video, points3d, track_metadata,pawPref,proj_3d_vid_name)

markerSize = 1;

boxCalibration = track_metadata.boxCalibration;
cameraParams = boxCalibration.cameraParams;

iFrame = 0;

w_vid = VideoWriter(proj_3d_vid_name, 'motion jpeg avi');
w_vid.FrameRate = video.FrameRate;
open(w_vid);

colList = {'red','blue'};

while video.hasFrame
    
    iFrame = iFrame + 1;
    
    frm = readFrame(video);

    frm_ud = undistortImage(frm,cameraParams);
    
    cur_3dpoints = points3d{iFrame};
    
    if isempty(cur_3dpoints)
        continue;
    end
    if isempty(cur_3dpoints{1})
        continue;
    end
    
    for i_matchDir = 1 : 2
        proj_pts = project3d_to_2d(cur_3dpoints{i_matchDir},boxCalibration,pawPref);

        for iView = 1 : 2

            toPlot = squeeze(proj_pts(:,:,iView));


            frm_ud = insertMarker(frm_ud, toPlot,'o',...
                                  'size', markerSize, ...
                                  'color',colList{i_matchDir});

        end
        
    end
    
    writeVideo(w_vid,frm_ud);
    
end

close(w_vid);


end