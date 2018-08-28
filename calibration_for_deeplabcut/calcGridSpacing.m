function gridSpacing = calcGridSpacing(worldPoints, boardSize)

% INPUTS
%   worldPoints - set of points in 2D or 3D space arranged in a grid

% calculate how many adjacent points there are based on boardSize
% number of "horizontal" distances
num_horizontal_spacings = (boardSize(1) - 1) * boardSize(2);
% number of "vertical" distances
num_vertical_spacings = (boardSize(2) - 1) * boardSize(1);

totalSpacings = num_horizontal_spacings + num_vertical_spacings;

% calculate distance between each point and every other point
numPoints = size(worldPoints, 1);
numDistances = numPoints * (numPoints - 1) / 2;
all_distances = zeros(numDistances,1);

startIdx = 1;
for ii = 1 : numPoints-1
    axes_diffs = worldPoints(ii,:) - worldPoints(ii+1:numPoints,:);
    new_distances = sqrt(sum(axes_diffs.^2,2));
    
    all_distances(startIdx : startIdx + length(new_distances) - 1) = new_distances;
    
    startIdx = startIdx + length(new_distances);
end

% now find the smallest totalSpacings values
all_distances = sort(all_distances);
gridSpacing = all_distances(1:totalSpacings);

end