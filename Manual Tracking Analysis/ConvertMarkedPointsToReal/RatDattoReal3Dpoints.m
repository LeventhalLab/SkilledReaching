%Titus John
%Leventhal Lab, University of Michigan
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This scripts will take the X1 and the X2 matricies and push them to the
%conver markter poiints to real worl in order to spit out the 3d points for
%a given trial and frame

function [all3dPoints] = RatDatatoReal3Dpoints(RatData)
    all3dPoints=[];
    
    [X1,X2] = RatDataToMPMatrcies(RatData);

    for i=2%:length(X1(:,1))
        for j= 1:5
            x1 = X1{i,j};
            x2 = X2{i,j};
             [points3d,reprojectedPoints,errors] = ConvertMarkedPointsToRealWorld(x1,x2);
             all3dPoints{i,j} = points3d;
        end
        
           
    end


   
end



for i =2%:length(all3dPoints)
    for j=1:5
        currentFrame = all3dPoints{i,j};
        x = currentFrame(:,1);
        y = currentFrame(:,2);
        z = currentFrame(:,3);
        figure(j)
        scatter3(x,y,z)
    end
end
    