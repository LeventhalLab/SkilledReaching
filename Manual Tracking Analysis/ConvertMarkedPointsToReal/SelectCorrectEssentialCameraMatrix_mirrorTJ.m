function [cRot,cT,correct] = SelectCorrectEssentialCameraMatrix_mirrorTJ(rot,t,x1,x2,k)
% Of four possible camera matrices that complement P = eye(3,4) as the
% camera matrix for the direct view, pick out the one that keeps
% triangulated points in front of both the real camera and virtual mirror
% camera. Note, if we had 2 cameras, we would want depth to be positive for
% both camers. However, since one of our views is a mirror and the
% identified points have not been reversed, the triangulated points should
% actually appear BEHIND the mirror but in front of the real camera. Assume
% the second "camera" is the mirror view
%  
% Input:
%       - rot and t are the four rotation and traslation matrice retrieved 
%         form the essential matrix.
%         rot is a 3x3x4 matrix where the last dimension corresponds
%         to the different camera matrices and 3x3 are rotation matrices.
%         t is a 3x1x4 matrix where the last dimension corresponds
%         to the different camera matrices and 3x1 are traslation matrices.
%
%       - x1 and x2 are the matched points from each view in the format
%           2 x N where N is the number of points 
%         
%
% Output:
%       - cRot and cT are the correct rotation and translation of the
%       second camera matrix from 4 possible solutions. We test with a
%       single point to determine if it is in front of both cameras is
%       sufficient to decide between the four different solutions for the
%       camera matrix (pag. 259). 
%
%       - correct is the index of the correct solution.
%
%----------------------------------------------------------
%      Author: Diego Cheda
% Affiliation: CVC - UAB
%        Date: 16/06/2008
%
%       Modified by Dan Leventhal, 8/2015 to account for mirrors
        %Modified by Titus John 9/2015 for manual marking of code
%----------------------------------------------------------
% 
 nx1 = x1;
 nx2 = x2;

x3D = zeros(4,size(x1,2),4);
for i=1:4
    x3D(:,:,i) = LinearTriangulation(nx1, nx2, rot(:,:,i), t(:,:,i));
    x3D(:,:,i) = HomogeneousCoordinates(x3D(:,:,i),'3D');
end

correct = 0;
depth = zeros(size(x1,2),2);
for i=1:4    
    % compute the depth & sum the sign
    depth(i,1) = sum(sign(DepthOfPoints(x3D(:,:,i),eye(3),zeros(3,1)))); %using canonical camera
    depth(i,2) = sum(sign(DepthOfPoints(x3D(:,:,i),rot(:,:,i),t(:,:,i)))); % using the recovered camera
end

if(depth(1,1)>0 && depth(1,2)<0)
    correct = 1;
elseif(depth(2,1)>0 && depth(2,2)<0)
    correct = 2;
elseif(depth(3,1)>0 && depth(3,2)<0)
    correct = 3;
elseif(depth(4,1)>0 && depth(4,2)<0)
    correct = 4;
end;

if ~correct
    %error('No projection matrix have all triangulated points in front of them.')
     correct = 1;
    
end

% return the selected solution
cRot = rot(:,:,correct);
cT = t(:,correct);