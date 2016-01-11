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

% 1.) Normalize the points to homogeneous points
% 2.) Shoot into triangulate_DL.

function  [points3d,reprojectedPoints,errors] = ConvertMarkedPointsToRealWorldOneFundemental(x1,x2,P1,P2)
    load cameraParameters.mat;
    
    %Undistort the points
    x1 = undistortPoints(x1,cameraParams);
    x2 = undistortPoints(x2,cameraParams);
    
    %Grab the intrsic matrix
    k = cameraParams.IntrinsicMatrix;
    
    %Create homogenous  verions of the points
    x1_hom = [x1, ones(size(x1,1),1)]';
    x2_hom = [x2, ones(size(x2,1),1)]';
    
    %Normalize points
    x1_norm = (k' \ x1_hom)';   
    x2_norm = (k' \ x2_hom)';   
    
        
    %remove the homogenous from normalized points
    x1_norm(:,3) = [];
    x2_norm(:,3) = [];
    
 
     
    %Use the triangulation function 
    [points3d,reprojectedPoints,errors] = triangulate_DL(x1_norm, x2_norm, P1, P2); 
  
    
end
