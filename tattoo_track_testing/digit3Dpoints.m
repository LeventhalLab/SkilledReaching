function tracks = digit3Dpoints(trackingBoxParams, tracks, mask_bbox)
% INPUTS:
%   trackingBoxParams - 
%   tracks - tracks structures containing only the 4 digits (index 1 is
%       index finger, index 4 is pinky)
%   mask_bbox - 2 x 4 array, where each row is a standard bounding box
%       vector [x,y,w,h]

currentDigitMarkers = zeros(length(tracks),2,3,2);
numDigits = length(tracks);
for iDigit = 1 : numDigits
    currentDigitMarkers(iDigit,:,:,:) = tracks(iDigit).currentDigitMarkers;
end

markers3D = currentDigitMarkersTo3D(currentDigitMarkers, trackingBoxParams, mask_bbox);

for iDigit = 1 : numDigits
    tracks(iDigit).markers3D = squeeze(markers3D(iDigit,:,:));
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%