function [meanShift,stdev] = findShift(folderPath)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    matLookup = dir(fullfile(folderPath,'_xyzData','*.mat'));
    load(fullfile(folderPath,'_xyzData',matLookup(1).name));
    
    shift = zeros(size(allXyzDistPawCenters));
    for i = 1:numel(allXyzDistPawCenters)
        for shiftIndex=1:numel(allXyzDistPawCenters{i})
            if(allXyzDistPawCenters{i}(shiftIndex) < 15) % distance threshold
               shift(i) = shiftIndex;
               break
            end
        end
    end
    
    meanShift = mean(shift);
    stdev = std(shift);
    
end

