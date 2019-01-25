function [F,maxError] = refineFundMatrixMirror(mp1,mp2,imSize,varargin)

matchTolerance = 5;    % pixels
maxIterations = 50;

maxError = matchTolerance + 1;
numIterations = 0;

cur_mp1 = mp1;
cur_mp2 = mp2;
while maxError > matchTolerance && numIterations < maxIterations
    
    F = fundMatrix_mirror(cur_mp1, cur_mp2);
    
    try
    epiLines = epipolarLine(F,cur_mp1);
    catch
        keyboard
    end
    borderPts = lineToBorderPoints(epiLines,imSize);
    
    distFromEpiLine = zeros(size(epiLines,1),1);
    
    for i_mp = 1 : size(cur_mp1,1)
        distFromEpiLine(i_mp) = distanceToLine(borderPts(i_mp,[1,2]),borderPts(i_mp,[3,4]),cur_mp2(i_mp,:));
    end
    
    cur_mp1 = cur_mp1(distFromEpiLine < matchTolerance,:);
    cur_mp2 = cur_mp2(distFromEpiLine < matchTolerance,:);
    
    maxError = max(distFromEpiLine);
end

end