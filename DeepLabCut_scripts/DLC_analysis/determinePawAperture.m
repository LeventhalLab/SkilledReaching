function [aperture,firstValidFrame] = determinePawAperture(interp_trajectory,bodyparts,pawPref)
%
% INPUTS
%   interp_trajectory - numFrames x 3 x num_bodyparts array containing
%       x,y,z points for each bodypart in each frame
%   bodyparts - cell array with names of bodyparts corresponding to the
%       third dimension in interp_trajectory
%
% OUTPUTS
%
%
[~,~,digIdx,~] = findReachingPawParts(bodyparts,pawPref);

% aperture is the distance between the first and fourth digits
dig1_trajectory = squeeze(interp_trajectory(:,:,digIdx(1)));
dig4_trajectory = squeeze(interp_trajectory(:,:,digIdx(4)));

validFrames = ~isnan(dig1_trajectory(:,1)) & ~isnan(dig4_trajectory(:,1));
firstValidFrame = find(validFrames,1,'first');

% if isempty(firstValidFrame)
%     aperture = 

app_3D = dig4_trajectory(firstValidFrame:end,:) - dig1_trajectory(firstValidFrame:end,:);

aperture = sqrt(sum(app_3D.^2,2));