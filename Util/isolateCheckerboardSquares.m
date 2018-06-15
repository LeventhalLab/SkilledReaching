function [newMask, erodedMask, numIterations] = isolateCheckerboardSquares(oldMask, boardSize, varargin)
%
% INPUTS
%
% OUTPUTS
%   newMask = binary image with checkerboard points separated

minArea = 150;   % pixels
minSolidity = 0.9;

for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'minarea'
            minArea = varargin{iarg + 1};
        case 'minsolidity'
            minSolidity = varargin{iarg + 1};
    end
end 

% remove any objects smaller than minArea

curMask = false(size(oldMask));
rstats = regionprops(oldMask,'area');
L = bwlabel(oldMask);
for iObj = 1 : length(rstats)
    if rstats(iObj).Area > minArea
        curMask = curMask | (L == iObj);
    end
end

cur_L = bwlabel(curMask);
numRegions = max(cur_L(:));
numIterations = 0;
erodedMask = false(size(curMask));
while numRegions < prod(boardSize) / 2
    numIterations = numIterations + 1;
    checkProps = regionprops(curMask,'solidity');
    
    curMask = false(size(curMask));
    for iObj = 1 : length(checkProps)
        
        testMask = (cur_L == iObj);
        
        if checkProps(iObj).Solidity < minSolidity
            % if more than one check, erode by 1
            erodedMask = erodedMask | testMask;
            testMask = imerode(testMask,strel('disk',1));
        end
        curMask = curMask | testMask;
        
    end
            
    cur_L = bwlabel(curMask);
    numRegions = max(cur_L(:));
end

newMask = curMask;

% identify which regions in newMask were eroded
erodedMask = newMask & erodedMask;