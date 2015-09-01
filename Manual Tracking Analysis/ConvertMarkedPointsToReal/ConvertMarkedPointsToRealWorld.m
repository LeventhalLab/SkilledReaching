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

function ConvertMarkedPointsToRealWorld
    load('cameraParameters.mat');
    
    x1 = [973.7055562	635.1111006
966.035991	571.0154484
919.4707736	567.7284919
929.3316432	565.5371875
945.7664258	571.0154484
916.1838171	584.1632745
929.8794693	595.6676223
947.409904	602.7893615
918.3751214	602.2415354
922.209904	611.5545788
933.1664258	619.2241441

];

    x2= [68.81985942	602.7868894
106.1068159	564.3347155
148.8314536	561.6158749
131.7415985	560.8390633
111.5444971	562.7810923
151.9387	570.937614
130.1879754	575.9868894
113.4865261	579.4825416
153.1039174	589.1926865
146.8894246	588.8042807
135.6256565	593.4651503
];

%     %Undistort the points
%     x1 = undistortPoints(x1,cameraParams);
%     x2 = undistortPoints(x2,cameraParams);
    
    %Create homogenous  verions of the points
    x1 = [x1, ones(size(x1,1),1)]';
    x2 = [x2, ones(size(x2,1),1)]';
    
    %Grab the intrsic matrix
    k = cameraParams.IntrinsicMatrix;
  
    
    %Calculate the fundemental matrix
    F = fundMatrix_mirror(x1, x2);
    
    %Calculate the essential matric
    E = k * F *k';
    
    %Calculate the rotation and translation matrix
    [rot,t] = EssentialMatrixToCameraMatrix(E);
    
    %Select correct rot and t 
    [cRot,cT,correct] = SelectCorrectEssentialCameraMatrix_mirrorTJ(rot,t,x1,x2,k);
   
    %Create the projection matricies
     P1= eye(4,3);% P1 stays constants 4x3 matrix
     P2= [cRot;cT'];
    
     
     %Use the triangulation function 
    [points3d,reprojectedPoints,errors] = triangulate_DL(x1', x2', P1, P2)
    

end






