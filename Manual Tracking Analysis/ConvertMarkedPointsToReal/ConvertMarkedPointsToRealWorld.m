%Titus John
%Leventhal Lab, University of Michigan
%9/1/15
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This call the diffrent CV function in order to convert the marked points
%into real world points

%Input
%This takes in the real 



%Output
%Outputs the triangulated 3 poitns 

%Flow of code from the raw input
% 1.) Take the image points from the dorsum view 
% 2.) Take the new orgin calculated using the undistort function and normalize the points
% 3.) Normalize the points to homogeneous points
% 4.) Shoot into triangulate_DL.

<<<<<<< HEAD
function   [points3d,reprojectedPoints,errors]= ConvertMarkedPointsToRealWorld
    load('cameraParameters.mat');
    
    x1 = [1101.151996	595.9071792
1121.499822	601.5593532
1136.760692	610.6028314
1078.543301	591.9506575
1094.369388	605.5158749
1107.369388	626.4289184


];

    x2= [1880.773196	574.8494036
1911.994127	588.3784733
1914.075522	602.4278919
1906.270289	576.9307989
1934.369127	583.174985
1947.377848	597.7447524
];

%     %Undistort the points
    x1 = undistortPoints(x1,cameraParams);
    x2 = undistortPoints(x2,cameraParams);
    
    %Create homogenous  verions of the points    
    x1_hom = [x1, ones(size(x1,1),1)]';
    x2_hom = [x2, ones(size(x2,1),1)]';

=======
function  [points3d,reprojectedPoints,errors] = ConvertMarkedPointsToRealWorld(x1,x2)
    load('cameraParameters.mat');

    %Undistort the points
    x1 = undistortPoints(x1,cameraParams);
    x2 = undistortPoints(x2,cameraParams);
    
    %Create homogenous  verions of the points
    x1_hom = [x1, ones(size(x1,1),1)]';
    x2_hom = [x2, ones(size(x2,1),1)]';
>>>>>>> origin/master
    
    %Grab the intrsic matrix
    k = cameraParams.IntrinsicMatrix;
  
    
    %Calculate the fundemental matrix
    F = fundMatrix_mirror(x1_hom, x2_hom);
    
    %Calculate the essential matric
    E = k * F *k';
    
    %Calculate the rotation and translation matrix
    [rot,t] = EssentialMatrixToCameraMatrix(E);
    
    %Select correct rot and t 
    [cRot,cT,correct] = SelectCorrectEssentialCameraMatrix_mirrorTJ(rot,t,x1_hom,x2_hom,k);
   
    %Create the projection matricies
     P1= eye(4,3);% P1 stays constants 4x3 matrix
     P2= [cRot;cT'];
    
     
     %Use the triangulation function 
    [points3d,reprojectedPoints,errors] = triangulate_DL(x1, x2, P1, P2)
<<<<<<< HEAD
    
=======
>>>>>>> origin/master

end






