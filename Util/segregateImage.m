function mask = segregateImage(linePoints, ptInRegion, imSize)
%
% usage:
%
% function to segregate an image into two regions. Given two points in the
% image, this function draws a line between those points to segregate the
% image. It then takes all points on the same side of the line as
% ptInRegion and sets them to true; the other region is false.
%
% INPUTS:
%    linePoints - 2 x 2 array, each row is an x,y pair designating a point
%    ptInRegion - 
%    imSize - 1 x 2 array containing image height and width, respectively
%
% OUTPUTS:

% find the border points for the line connecting the two linePoints
% % calculate slope
% m = diff(linePoints(:,2))/diff(linePoints(:,1));
% % calculate y-intercept
% b = linePoints(1,2) - m * linePoints(1,1);
A = -diff(linePoints(:,2));
B = diff(linePoints(:,1));
C = -A*linePoints(1,1) - B*linePoints(1,2);

testValue = A*ptInRegion(1) + B*ptInRegion(2) + C;
cornerPts = [1         1            % top left
             1         imSize(1)    % bottom left
             imSize(2) imSize(1)    % bottom right
             imSize(2) 1];          % top right
cornerValues = A*cornerPts(:,1) + B*cornerPts(:,2) + C;
cornerIdx = (testValue * cornerValues) > 0;    % find corners on the same side of the boundary line as testValue
borderPts = lineToBorderPoints([A,B,C],imSize);
borderPts = [borderPts(1:2);borderPts(3:4)];
% constrain border points to y values >= 1
topEdgeBorderIdx = find(borderPts(:,2) < 1);
if ~isempty(topEdgeBorderIdx)
    borderPts(topEdgeBorderIdx,1) = (-B-C) / A;
    borderPts(topEdgeBorderIdx,2) = 1;
end
% constrain border points to y values <= imSize(1)
botEdgeBorderIdx = find(borderPts(:,2) > imSize(1));
if ~isempty(botEdgeBorderIdx)
    borderPts(botEdgeBorderIdx,1) = (-B*imSize(1)-C) / A;
    borderPts(botEdgeBorderIdx,2) = imSize(1);
end
% constrain border points to x values >= 1
leftEdgeBorderIdx = find(borderPts(:,1) < 1);
if ~isempty(leftEdgeBorderIdx)
    borderPts(leftEdgeBorderIdx,1) = 1;
    borderPts(leftEdgeBorderIdx,2) = (-A-C) / B;
end
% constrain border points to x values <= imSize(2)
rightEdgeBorderIdx = find(borderPts(:,1) > imSize(2));
if ~isempty(rightEdgeBorderIdx)
    borderPts(rightEdgeBorderIdx,1) = imSize(2);
    borderPts(rightEdgeBorderIdx,2) = (-A*imSize(2)-C) / B;
end

% create a polygon containing the corners on the same side as the test
% point and the border points
polyCorners = [cornerPts(cornerIdx,:); borderPts];
% sort the corners going clockwise, starting from the first point in the
% polyCorners matrix
polyCenter = mean(polyCorners, 1);
% calculate angles between center point, first point, and the other points
polyRef = [polyCorners(:,1) - polyCenter(1), polyCorners(:,2) - polyCenter(2)];   % corner points in a coordinate system centered on the average of the corners
polyAngles = angle(polyRef(:,1) + 1i*polyRef(:,2));
[~, sortIdx] = sort(polyAngles);
polyCorners = polyCorners(sortIdx,:);

mask = poly2mask(polyCorners(:,1), polyCorners(:,2), imSize(1), imSize(2));

end