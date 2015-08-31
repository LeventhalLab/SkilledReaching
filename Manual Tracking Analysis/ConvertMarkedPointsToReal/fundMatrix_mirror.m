function F = fundMatrix_mirror(x1, x2)
%
% usage: F = fundMatrix_mirror(x1, x2)
%
% function to compute the fundamental matrix for direct camera and mirror
% image views, taking advantage of the fact that F is skew-symmetric in
% this case
%
% INPUTS:
%   x1 - n x 2 vector containing the points in the direct image
%   x2 - n x 2 vector containing matching points in the mirror image

% construct "A" matrix (constraint matrix), given that the fundamental
% matrix for the direct camera view and its mirror image is skew symmetric
% (that is, F' = -F). Constraint equation is derived from the defining
% equation of the fundamental matrix, subject to constraint of skew-symmetry:
%       x2' * F * x1 = 0
%

A = zeros(size(x1, 1), 3);

A(:,1) = (x2(:,1).*x1(:,2)-x1(:,1).*x2(:,2));
A(:,2) = (x2(:,1)-x1(:,1));
A(:,3) = (x2(:,2)-x1(:,2));

% solve the linear system of equations A * [f12,f13,f23]' = 0
[~,~,vA] = svd(A,0);
F = zeros(3);
fvec = vA(:,end);

% put the solutions to the constraint equation into F
F(1,2) = fvec(1);
F(1,3) = fvec(2);
F(2,3) = fvec(3);
F(2,1) = -F(1,2);
F(3,1) = -F(1,3);
F(3,2) = -F(2,3);

end