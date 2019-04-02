function aperture = calcAperture(trajectory,bodyparts,pawPref)
%
% calculate the digit aperture (distance between tips of 1st and 4th 
% digits)
%
% INPUTS
%   trajectory - numFrames x 3 x number of bodyparts array containing
%       trajectory data for this trial. bodypart indices need to match with
%       labels in bodyparts array
%   bodyparts - cell array containing the names of bodyparts labeled by DLC
%   pawPref - 'left' or 'right'
%
% OUTPUTS
%   aperture - numFrames x 3 array where each row is the difference in
%       (x,y,z) coordinates between the tips of the first and fourth digits

[~,~,digIdx,~] = findReachingPawParts(bodyparts,pawPref);

numFrames = size(trajectory,1);

aperture = NaN(numFrames,3);

for iFrame = 1 : numFrames
    
    cur_digCoords = [squeeze(trajectory(iFrame,:,digIdx(1)));
                     squeeze(trajectory(iFrame,:,digIdx(3)))];
    if ~isnan(cur_digCoords(1,1)) && ~isnan(cur_digCoords(2,1))
        % both 1st and 4th digit tips were found in this frame
        aperture(iFrame,:) = diff(cur_digCoords,1,1);
    end
    
end