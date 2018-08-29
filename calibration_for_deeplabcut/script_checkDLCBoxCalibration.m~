% script to check if calibration points are appropriately triangulated

% calImageDir = '/Users/dan/Box Sync/Leventhal Lab/Skilled Reaching Project/Calibration Images';
% calImageDir = '/Users/dleventh/Box Sync/Leventhal Lab/Skilled Reaching Project/Calibration Images';
% calImageDir = '/Users/dleventh/Documents/deeplabcut images/cal images to review';
calImageDir = '/Volumes/Tbolt_01/Skilled Reaching/calibration_images';

cd(calImageDir);
colList = 'rgb';
matList = dir('SR_boxCalibration_*.mat');
P = eye(4,3);
% close all
for iMat = 1 : length(matList)
    
    load(matList(iMat).name);
    K = cameraParams.IntrinsicMatrix;
    
    numBoards = size(directChecks,3);
    numImg = size(directChecks,4);
    
    points3d = NaN(size(directChecks,1),3,size(directChecks,3),size(directChecks,4));
    scaled_points3d = NaN(size(points3d));
    mean_sf = mean(scaleFactor,2);   % single scale factor for each board, averaged across images
    for iBoard = 1 : numBoards
        
        for iImg = 1 : numImg
            
            curDirectChecks = squeeze(directChecks(:,:,iBoard,iImg));
            curMirrorChecks = squeeze(mirrorChecks(:,:,iBoard,iImg));
            
            if any(isnan(curDirectChecks(:))) || any(isnan(curMirrorChecks(:)))
                continue;
            end
            
            curDirectChecks_norm = normalize_points(curDirectChecks,K);
            curMirrorChecks_norm = normalize_points(curMirrorChecks,K);
            
            curP = squeeze(Pn(:,:,iBoard));
            [points3d(:,:,iBoard,iImg),reprojectedPoints,errors] = triangulate_DL(curDirectChecks_norm, curMirrorChecks_norm, P, curP);
            scaled_points3d(:,:,iBoard,iImg) = points3d(:,:,iBoard,iImg) * mean_sf(iBoard);
            
            figure(iImg)
            hold on
            toPlot = squeeze(scaled_points3d(:,:,iBoard,iImg));
            scatter3(toPlot(:,1),toPlot(:,2),toPlot(:,3),colList(iBoard))
            xlabel('x')
            ylabel('y')
            zlabel('z')
        end
    end
end