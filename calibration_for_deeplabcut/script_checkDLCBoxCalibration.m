% script to check if calibration points are appropriately triangulated

% allParams = setParams;

% rootDir = '/Volumes/LL EXHD #2/calibration_images';
rootDir = '/Volumes/Untitled/DLC_output/calibration_images';

% weird that datetime uses 'MM' for month but datestring uses 'mm'
start_month = datetime('202012','inputformat','yyyyMM');
last_month = datetime('202012','inputformat','yyyyMM');
current_month = start_month;

while current_month.Month <= last_month.Month
    current_month
    
    % month_to_analyze = '201704';
    month_to_analyze = datestr(current_month, 'yyyymm');
    year_to_analyze = month_to_analyze(1:4);
    calImageDir = fullfile(rootDir,year_to_analyze,...
        [month_to_analyze '_calibration'],[month_to_analyze '_original_images']);
    autoImageDir = fullfile(rootDir,year_to_analyze,...
        [month_to_analyze '_calibration'],[month_to_analyze '_auto_marked']);
    manuallyMarkedDir = fullfile(rootDir,year_to_analyze,...
        [month_to_analyze '_calibration'],[month_to_analyze '_manually_marked']);
    allMarkedDir = fullfile(rootDir,year_to_analyze,...
        [month_to_analyze '_calibration'],[month_to_analyze '_all_marked']);
    calFileDir = fullfile(rootDir,year_to_analyze,...
        [month_to_analyze '_calibration'],[month_to_analyze '_calibration_files']);

    colList = 'rgb';
    cd(calFileDir)
    matList = dir('SR_boxCalibration_*.mat');
    P = eye(4,3);
    % close all

    cd(calImageDir);
    imgList = dir('GridCalibration_*.png');
    [imFiles_from_same_date, img_dateList] = groupCalibrationImagesbyDate(imgList);

    for iMat = 1 : length(matList)

        cd(calFileDir)
        load(matList(iMat).name);
        % curDate is stored in the .mat file
    %     if ~any(strcmp({'20180319'}, curDate))
    %         continue;
    %     end

        K = cameraParams.IntrinsicMatrix;

        numBoards = size(directChecks,3);
        numImg = size(directChecks,4);

        close all
        cd(calImageDir)
        % imFileList is stored in the .mat file
        for iImg = 1 : numImg
            img = imread(imFileList{iImg},'png');
            img = undistortImage(img,cameraParams);
            figure(iImg + numImg);
            imshow(img);
            hold on
        end

        points3d = NaN(size(directChecks,1),3,size(directChecks,3),size(directChecks,4));
        scaled_points3d = NaN(size(points3d));
        mean_sf = mean(scaleFactor,2);   % single scale factor for each board, averaged across images

        for iBoard = 1 : numBoards

            for iImg = 1 : numImg

                curDirectChecks = squeeze(directChecks(:,:,iBoard,iImg));
                curMirrorChecks = squeeze(mirrorChecks(:,:,iBoard,iImg));

                figure(iImg + numImg)
                hold on
                scatter(curDirectChecks(1,1),curDirectChecks(1,2));
                scatter(curMirrorChecks(1,1),curMirrorChecks(1,2));

                if any(isnan(curDirectChecks(:))) || any(isnan(curMirrorChecks(:)))
                    continue;
                end

                curDirectChecks_norm = normalize_points(curDirectChecks,K);
                curMirrorChecks_norm = normalize_points(curMirrorChecks,K);

                curP = squeeze(Pn(:,:,iBoard));
                [points3d(:,:,iBoard,iImg),reprojectedPoints,errors] = triangulate_DL(curDirectChecks_norm, curMirrorChecks_norm, P, curP);
                scaled_points3d(:,:,iBoard,iImg) = points3d(:,:,iBoard,iImg) * mean_sf(iBoard);

                h_fig(iImg) = figure(iImg);
                set(h_fig(iImg),'position',[100+(iImg-1)*450,100,400,400])
                hold on
                toPlot = squeeze(scaled_points3d(:,:,iBoard,iImg));
                scatter3(toPlot(:,1),toPlot(:,2),toPlot(:,3),colList(iBoard))
                scatter3(toPlot(1,1),toPlot(1,2),toPlot(1,3))

                xlabel('x')
                ylabel('y')
                zlabel('z')
                set(gca,'zdir','reverse','ydir','reverse')
                figName = sprintf('%s, image %d',matList(iMat).name,iImg);
                set(gcf,'name',figName)
                view(15,45)
            end
        end
        keyboard
        close all
    end
    
    current_month.Month = current_month.Month + 1;
    
end