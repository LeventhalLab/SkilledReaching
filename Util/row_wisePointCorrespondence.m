function [imagePoints, worldPoints] = row_wisePointCorrespondence(imPoints)
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
imagePoints = zeros(8,2,2);
imagePoints(1:4,:,1) = imRow(1:4,:,1);
imagePoints(5:8,:,1) = imRow(1:4,:,2);

imagePoints(1:4,:,2) = imRow(1:4,:,3);
imagePoints(5:8,:,2) = imRow(1:4,:,4);


worldPoints = [00 00
               08 00
               16 00
               24 00
               00 08
               08 08
               16 08
               24 08];
               