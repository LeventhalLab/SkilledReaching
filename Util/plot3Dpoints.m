function plot3Dpoints(points3d)

if iscell(points3d)
    numViews = length(points3d);
else
    numViews = 1;
    points3d = {points3d};
end

figure(2)
for iView = 1 : numViews
    
    plot3(points3d{iView}(:,1),points3d{iView}(:,2),points3d{iView}(:,3),'marker','.','linestyle','none');
    hold on
    
end

xlabel('x');ylabel('y');zlabel('z')