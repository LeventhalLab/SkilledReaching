%%
figure(1)
for ii = 1 : length(points3d)
    hold on
    if isempty(points3d{ii}); continue; end
    plot3(points3d{ii}(:,1),points3d{ii}(:,2),points3d{ii}(:,3),'marker','.','linestyle','none');
end
xlabel('x');ylabel('y');zlabel('z');

%%
figure(4);
ii = 398;
plot3(points3d{ii}(:,1),points3d{ii}(:,2),points3d{ii}(:,3),'marker','.','linestyle','none');
xlabel('x');ylabel('y');zlabel('z');

%%
iView = 1;
% ii = ii + 3
ii=2
figure(1)
hold on

% plot(ext_pts{1}(1:ii,1),ext_pts{1}(1:ii,2),'color','g','marker','o')
% plot(ext_pts{1}(ii,1),ext_pts{1}(ii,2),'color','r','marker','o')

% plot the direct view
plot(squeeze(matchedPoints{iView}(1:ii,1,1)),squeeze(matchedPoints{iView}(1:ii,2,1)),'color','g','marker','o')
plot(matchedPoints{iView}(ii,1,1),matchedPoints{iView}(ii,2,1),'color','r','marker','o')

% plot the mirror view
plot(squeeze(matchedPoints{iView}(1:ii,1,2)),squeeze(matchedPoints{iView}(1:ii,2,2)),'color','g','marker','o')
plot(matchedPoints{iView}(ii,1,2),matchedPoints{iView}(ii,2,2),'color','r','marker','o')

figure(2)
hold on
plot3(points3d{iView}(1:ii,1),points3d{iView}(1:ii,2),points3d{iView}(1:ii,3),'marker','o','linestyle','none','color','g')
plot3(points3d{iView}(ii,1),points3d{iView}(ii,2),points3d{iView}(ii,3),'marker','o','linestyle','none','color','k')

%%
for iView = 1 : 2
    proj_pts{iView} = project3d_to_2d(points3d{iView},boxCalibration,pawPref);
    
    figure(1)
    hold on
    if iView == 1
        plotCol = 'g';
    else
        plotCol = 'r';
    end
    plot(squeeze(proj_pts{iView}(:,1,1)),squeeze(proj_pts{iView}(:,2,1)),'color',plotCol,'marker','.','linestyle','none')
    plot(squeeze(proj_pts{iView}(:,1,2)),squeeze(proj_pts{iView}(:,2,2)),'color',plotCol,'marker','.','linestyle','none')
end