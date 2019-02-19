function digitMidpoint = findDigitsMidpoint(digitPoints,validIdx)
%
% function to find the presumed midpoint of a set of identified digits from
% deeplabcut. Algorithm is as follows:
%   1. If the 2nd and 3rd digits were identified, the output is the
%      average location of those 2 digits.
%   2. If the 1st and 4th digits are identified (but not the 2nd and
%      3rd), take the average of the 1st and 4th digits
%   3. If the 2nd OR 3rd digit is identified (but not the 1st and 4th),
%      take that digit
%   4. If only the 1st or 4th digit is identified, take that one
%
% INPUTS:
%   digitPoints: 4 x 2 array where each row is an (x,y) pair indicating the
%       location of the digit points (designed to be all identified MCPs,
%       PIPs, or digit tips)
%   validIdx: 4-element boolean vector where true elements indicate that
%       the point is valid (i.e., not low probability per DLC, not manually
%       marked invalid, etc.)
%
% OUTPUTS:
%   digitMidpoint - midpoint of the digits as determined by the above
%       algorithm

if ~any(validIdx)
    digitMidpoint = [];
    return;
end
if all(validIdx(2:3))
    digitMidpoint = mean(digitPoints(2:3,:),1);
    return
end

if all(validIdx([1,4]))
    digitMidpoint = mean(digitPoints([1,4],:),1);
    return
end

if validIdx(2)
    digitMidpoint = digitPoints(2,:);
    return;
end

if validIdx(3)
    digitMidpoint = digitPoints(3,:);
    return;
end

digitMidpoint = digitPoints(validIdx,:);