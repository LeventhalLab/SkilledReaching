function [ boardSize ] = determineCheckerboardSize( X )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%
% INPUTS
%   X - m x 2 array of points
%
% OUTPUTS
%   boardSize = 1 x 2 array of checkerboard size (height, width). By matlab
%   convention, it is the number of squares in the checkerboard, not the
%   number of points. For example, a 5 x 4 board has 5 rows of squares, so
%   4 points between those rows. In other words, boardSize = [5,4] means
%   there are 4 x 3 points in the array
%
% assume points are already ordered. find the first point that is far away
% from the line connecting the first two points

numPts = size(X,1);
dist_to_line = zeros(numPts-2, 1);

for iPt = 1 : numPts
    dist_to_line(iPt) = distanceToLine(X(1,:),X(2,:),X(iPt,:));
end

% calculate variance of distances to line for different group sizes
withinVar = zeros(floor(numPts/2),1);
for groupSize = 3 : floor(numPts/2)
    
    numGroups = numPts / groupSize;
    if numGroups ~= round(numGroups)
        continue;
    end
    
    testDist = reshape(dist_to_line, [groupSize,numGroups]);
    withinVar(groupSize) = mean(var(testDist,0,1));
end

% find minimum nonzero within group variance of distance from the line
% connecting the first two points based on how big the groups of points are
testVal = min(withinVar(withinVar > 0));
board_w = find(withinVar == testVal) + 1;
board_h = (numPts / (board_w-1)) + 1;
boardSize = [board_h,board_w];
    

end

