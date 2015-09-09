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

function  [points3d,reprojectedPoints,errors] = ConvertMarkedPointsToRealWorld(x1,x2)
    load('cameraParameters.mat');
    I = imread('rubiksCalibration.png');
    
    
    %Undistort the points
    x1 = undistortPoints(x1,cameraParams);
    x2 = undistortPoints(x2,cameraParams);

    figure(1)
    hold on
    scatter(x1(:,1),x1(:,2),'r')
    scatter(x2(:,1),x2(:,2),'b') 
    
    
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
    
    
     
    hold on

    
    scatter(x1_norm(:,1),x1_norm(:,2),'r');
    scatter(x2_norm(:,1),x2_norm(:,2),'b');
    
  
    %Calculate the fundemental matrix
    F = fundMatrix_mirror(x1, x2)
 
    
    %Calculate the essential matrix
    E = k * F *k';
    
    %Calculate the rotation and translation matrix
    [rot,t] = EssentialMatrixToCameraMatrix(E);

    
    %Select correct rot and t 
    [cRot,cT,correct] = SelectCorrectEssentialCameraMatrix_mirrorTJ(rot,t,x1_norm,x2_norm);
   
    %Create the projection matrices
    P1= eye(4,3);% P1 stays constants 4x3 matrix
    P2= [cRot;cT'];
    

     
    %Use the triangulation function 
    [points3d,reprojectedPoints,errors] = triangulate_DL(x1_norm, x2_norm, P1, P2); 
  
    figure(3)
%     [J,newOrigin] = undistortImage(I,cameraParams);
%     imshow(J)
%     hold on
%     
    
    x1_reprojected = reprojectedPoints(:,:,1);
    x2_reprojected = reprojectedPoints(:,:,2);
    
    x1_rp_hom = [x1_reprojected,ones(size(x1_reprojected,1),1)];
    x2_rp_hom = [x2_reprojected,ones(size(x2_reprojected,1),1)];
    x1_scaled = (k'* x1_rp_hom')';
    x2_scaled = (k'* x2_rp_hom')';
    x1_scaled = bsxfun(@rdivide,x1_scaled(:,1:2),x1_scaled(:,3));
    x2_scaled = bsxfun(@rdivide,x2_scaled(:,1:2),x2_scaled(:,3));
    
    figure(1)
    hold on
    scatter(x1_scaled(:,1),x1_scaled(:,2))
    scatter(x2_scaled(:,1),x2_scaled(:,2))
    
    
    
    
end






