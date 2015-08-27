function [R,T] = extrinsicsPlanar_normCoord(imagePoints, worldPoints)
% copied from matlab toolbox so I can see where things seem to be going
% wrong...

% Compute homography.
H = fitgeotrans(worldPoints, imagePoints, 'projective');

H = H.T';
h1 = H(:, 1);
h2 = H(:, 2);
h3 = H(:, 3);

lambda = 1 / norm(h1);
% lambda = 1 / norm(A \ h1);

% Compute rotation
r1 = h1 / lambda;
r2 = h2 / lambda;
r3 = cross(r1, r2);
R = [r1'; r2'; r3'];

% r1 = A \ (lambda * h1);
% r2 = A \ (lambda * h2);
% r3 = cross(r1, r2);
% R = [r1'; r2'; r3'];

% R may not be a true rotation matrix because of noise in the data.
% Find the best rotation matrix to approximate R using SVD.
[U, ~, V] = svd(R);
R = U * V';

% Compute translation vector.
T = (h3 / lambda)';