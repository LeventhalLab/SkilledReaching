function points3d = triangulateOneTrial(sr_ratInfo, processedDir, session_srCal, cameraParams, trialNum)

switch sr_ratInfo.pawPref
    case 'right',
        pawDorsumView = 2;
        P_idx = 1;
    case 'left',
        pawDorsumView = 3;
        P_idx = 2;
end

K = cameraParams.IntrinsicMatrix;

pawData = load_pawTrackData(processedDir, trialNum);

P = squeeze(session_srCal.P(:,:,P_idx));

nanidx = find(isnan(pawData(:,1,1)));
center_pts = NaN(size(pawData,1),size(pawData,2));
mirror_pts = NaN(size(pawData,1),size(pawData,2));

for ii = 1 : size(center_pts,1)
    % WORKING HERE - NEED TO ONLY UNDISORT POINTS THAT EXIST - SKIP NANs

center_pts = undistortPoints(squeeze(pawData(:,:,1)), cameraParams);
mirror_pts = undistortPoints(squeeze(pawData(:,:,pawDorsumView)), cameraParams);

center_norm = normalize_points(center_pts, K);
mirror_norm = normalize_points(mirror_pts, K);

points3d = triangulate_DL(center_norm,mirror_norm, eye(4,3), P);

points3d = points3d * session_srCal.scale(P_idx);