function [points3d,reprojectedPoints,errors] = triangulate_DL(mp1, mp2, P1, P2, varargin)
%
% modified from matlab's computer vision toolbox to perform nonlinear
% optimization of reprojection errors after initial closed form solutions
% are found

refine_estimates = true;

for iarg = 1 : 2 : nargin - 4
    switch lower(varargin{iarg})
        case 'refineestimates',
            refine_estimates = varargin{iarg + 1};
    end
end

points2d = cat(3, mp1, mp2);
numPoints = size(points2d, 1);
cameraMatrices = cat(3, P1, P2);

points3d = zeros(numPoints, 3, 'like', points2d);
reprojectedPoints = zeros(numPoints, 2, 2, 'like', points2d);
reprojectionErrors = zeros(numPoints, 1, 'like', points2d);

for iPoint = 1 : numPoints
    [points3d(iPoint, :), reprojection, errors] = ...
        triangulateOnePoint_DL(cameraMatrices, squeeze(points2d(iPoint, :, :))',refine_estimates);
    reprojectionErrors(iPoint) = mean(hypot(errors(:, 1), errors(:, 2)));
    reprojectedPoints(iPoint,:,1) = reprojection(1,:);
    reprojectedPoints(iPoint,:,2) = reprojection(2,:);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [finalPoint, reprojectedPoints, reprojectionErrors] = ...
    triangulateOnePoint_DL(cameraMatrices, matchingPoints,refine_estimates)

% do the triangulation
numViews = size(cameraMatrices, 3);
A = zeros(numViews * 2, 4);
for i = 1:numViews
    P = cameraMatrices(:,:,i)';
    A(2*i - 1, :) = matchingPoints(i, 1) * P(3,:) - P(1,:);
    A(2*i    , :) = matchingPoints(i, 2) * P(3,:) - P(2,:);
end

[~,~,V] = svd(A);
X = V(:, end);
X = X/X(end);

point3d = X(1:3)';

if ~refine_estimates
    reprojectedPoints = zeros(size(matchingPoints), 'like', matchingPoints);
    for i = 1:numViews
        reprojectedPoints(i, :) = projectPoints_DL(point3d, cameraMatrices(:, :, i));
    end
    reprojectionErrors = reprojectedPoints - matchingPoints;
    finalPoint = point3d;
else
    finalPoint = refinePoint(point3d, cameraMatrices, matchingPoints);

    reprojectedPoints = zeros(size(matchingPoints), 'like', matchingPoints);
    for i = 1:numViews
        reprojectedPoints(i, :) = projectPoints_DL(finalPoint, cameraMatrices(:, :, i));
    end

    reprojectionErrors = reprojectedPoints - matchingPoints;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function finalPoint = refinePoint(initPoint, cameraMatrices, matchingPoints)

numViews = size(cameraMatrices, 3);

options = optimoptions('lsqnonlin','display','off','algorithm','levenberg-marquardt');
[finalPoint,resnorm,residual,exitflag] = lsqnonlin(@reprojError,initPoint,[],[],options);

    function errors = reprojError(point3d)

        for i = 1:numViews
            reprojectedPoints(i, :) = projectPoints_DL(point3d, cameraMatrices(:, :, i));
        end
        errors = reprojectedPoints - matchingPoints;
        errors = sqrt(sum(errors.^2,2));
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function points2d = projectPoints_DL(points3d, P)

points3dHomog = [points3d, ones(size(points3d, 1), 1, 'like', points3d)];
points2dHomog = points3dHomog * P;
points2d = bsxfun(@rdivide, points2dHomog(:, 1:2), points2dHomog(:, 3));

end

