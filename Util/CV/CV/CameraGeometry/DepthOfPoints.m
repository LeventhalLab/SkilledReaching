function d = DepthOfPoints(x3D,rot,t)
% Computes the depth of points
%
% Input:
%       - x3D are the 3D points.
%
%       - rot is a 3x3 rotation matrix
%
%       - t is a 3x1 traslation matrix.
%
% Output:
%       - d is a 1xn vector with the depth of points.
%
%----------------------------------------------------------
%
% From 
%    Book: "Multiple View Geometry in Computer Vision",
% Authors: Hartley and Zisserman, 2006, [HaZ2006]
% Section: "Depth of points", 
% Chapter: 6
%    Page: 162
%
%----------------------------------------------------------
%      Author: Diego Cheda
% Affiliation: CVC - UAB
%        Date: 11/06/2008
%----------------------------------------------------------

[k,r,c] = DecomposeCameraMatrix([rot t]); 

x3D = HomogeneousCoordinates(x3D,'3D');

rnorm = norm(rot(3,:));
sign_detrot = sign(det(rot));
for i=1:size(x3D,2)
    w = rot(3,:) * (x3D(1:3,i) - c(1:3,:));
    
    depth = (sign_detrot * w) / (x3D(4,i) * rnorm);
    
    d(i) = depth(1,1);
end
