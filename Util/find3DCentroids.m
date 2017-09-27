function mean3Dtrajectory = find3DCentroids(points3d)

numFrames = length(points3d);
mean3Dtrajectory = NaN(numFrames, 3);
gridSpacing = 0.2;

for iFrame = 1 : numFrames
    
    if isempty(points3d{iFrame}); continue; end
    if isempty(points3d{iFrame}{1}); continue; end
    if isempty(points3d{iFrame}{2}); continue; end
    
    ptList = [points3d{iFrame}{1};points3d{iFrame}{2}];
    
    cvxHull = convhull(ptList);
    shp = alphaShape(ptList(cvxHull,1),ptList(cvxHull,2),ptList(cvxHull,3));
    
    % find points that are inside shp
    
    % create array of points for the query
    xLims = [min(shp.Points(:,1)),max(shp.Points(:,1))];
    yLims = [min(shp.Points(:,2)),max(shp.Points(:,2))]; 
    zLims = [min(shp.Points(:,3)),max(shp.Points(:,3))];
    x = xLims(1):gridSpacing:xLims(2);
    y = yLims(1):gridSpacing:yLims(2);
    z = zLims(1):gridSpacing:zLims(2);
    [X,Y,Z] = meshgrid(x,y,z);
    
    tf_ptsInShape = inShape(shp,X,Y,Z);
    ptsInShape = [X(tf_ptsInShape),Y(tf_ptsInShape),Z(tf_ptsInShape)];
    mean3Dtrajectory(iFrame,:) = mean(ptsInShape,1);
    
end