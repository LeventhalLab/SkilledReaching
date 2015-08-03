function [imagePoints, worldPoints] = clockwisePointCorrespondence(imPoints)
% assume 4 x 4 grid of points

% find the top left square corners
[~, sortIdx] = sort(imPoints(:,2));
imPoints = imPoints(sortIdx,:);

imRow = zeros(4,2,4);
for iRow = 1 : 4
    startIdx = (iRow - 1) * 4 + 1;
    temp = imPoints(startIdx:startIdx + 3, :);
    % now arrange from left to right
    [~,sortIdx] = sort(temp(:,1));
    imRow(:,:,iRow) = temp(sortIdx,:);
end

imagePoints(1:3,:,1) = imRow(1:3,:,1);
imagePoints(4:6,:,1) = imRow(1:3,:,2);

imagePoints(1,:,2) = imRow(4,:,1);
imagePoints(2,:,2) = imRow(4,:,2);
imagePoints(3,:,2) = imRow(4,:,3);
imagePoints(4,:,2) = imRow(3,:,1);
imagePoints(5,:,2) = imRow(3,:,2);
imagePoints(6,:,2) = imRow(3,:,3);

imagePoints(1:3,:,3) = imRow(4:-1:2,:,4);
imagePoints(4:6,:,3) = imRow(4:-1:2,:,3);

imagePoints(1,:,4) = imRow(1,:,4);
imagePoints(2,:,4) = imRow(1,:,3);
imagePoints(3,:,4) = imRow(1,:,2);
imagePoints(4,:,4) = imRow(2,:,4);
imagePoints(5,:,4) = imRow(2,:,3);
imagePoints(6,:,4) = imRow(2,:,2);

worldPoints = [00 00
               08 00
               16 00
               00 08
               08 08
               16 08];
               