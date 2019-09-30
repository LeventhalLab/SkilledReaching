function aperture = determinePawAperture(interp_trajectory,bodyparts)
%
% INPUTS
%   
%
% OUTPUTS
%
%
[~,~,digIdx,~] = findReachingPawParts(bodyparts,pawPref);

% aperture is the distance between the first and fourth digits
dig1_trajectory = squeeze(interp_trajectory(:,:,digIdx(1)));
dig4_trajectory = squeeze(interp_trajectory(:,:,digIdx(4)));

app_3D = dig4_trajectory - dig1_trajectory;

aperture = sqrt(sum(app_3D.^2,2));