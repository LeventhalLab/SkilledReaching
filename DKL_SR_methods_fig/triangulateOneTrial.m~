function points3d_norm = triangulateOneTrial(sr_ratInfo, session_srCal, cameraParams, pawData)
%
%
switch sr_ratInfo.pawPref
    case 'right',
        pawDorsumView = 2;
        P_idx = 1;
    case 'left',
        pawDorsumView = 3;
        P_idx = 2;
end

K = cameraParams.IntrinsicMatrix;

% pawData = load_pawTrackData(processedDir, trialNum);

points3d_norm = NaN(size(pawData,1),3);

P = squeeze(session_srCal.P(:,:,P_idx));

numidx_direct = ~isnan(pawData(:,1,1));
numidx_mirror = ~isnan(pawData(:,1,pawDorsumView));
numidx = numidx_direct & numidx_mirror;
if ~any(numidx)    % no points to triangulate
    return;
end

center_pts = NaN(size(pawData,1),size(pawData,2));
mirror_pts = NaN(size(pawData,1),size(pawData,2));

% for ii = 1 : length(numidx)
    center_pts(numidx,:) = undistortPoints(squeeze(pawData(numidx,:,1)), cameraParams);
    mirror_pts(numidx,:) = undistortPoints(squeeze(pawData(numidx,:,pawDorsumView)), cameraParams);
% end
    
    % WORKING HERE - NEED TO ONLY UNDISORT POINTS THAT EXIST - SKIP NANs


center_norm = NaN(size(center_pts));
mirror_norm = NaN(size(mirror_pts));

center_norm(numidx,:) = normalize_points(center_pts(numidx,:), K);
mirror_norm(numidx,:) = normalize_points(mirror_pts(numidx,:), K);


points3d_norm(numidx,:) = triangulate_DL(center_norm(numidx,:),mirror_norm(numidx,:), eye(4,3), P);

% points3d = points3d * session_srCal.scale(P_idx);