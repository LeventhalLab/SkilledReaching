%Titus John
%Leventhal Lab, University of Michigan
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This scripts will take the X1 and the X2 matricies and push them to the
%conver markter poiints to real worl in order to spit out the 3d points for
%a given trial and frame

function [all3dPoints] = RatDatatoReal3Dpoints(RatData)
    load('r27514x1.mat');
    load('r27514x2.mat');
    load pxToMm

    all3dPoints=[];
    
    
    [X1,X2] = RatDataToMPMatrcies(RatData);

    for i=1:length(X1(:,1))
        for j= 1:5
            x1 = X1{i,j};
            x2 = X2{i,j};
            
            x1= vertcat(x1,r27514x1);
            x2= vertcat(x2,r27514x2);
    
          if size(x1) > 1
                [points3d,reprojectedPoints,errors,pxToMm] = ConvertMarkedPointsToRealWorld(x1,x2);
                all3dPoints{i,j} = points3d*pxToMm;
          else
               all3dPoints{i,j} = [];
          end
             
        end          
    end


        
%     colors = ['r','b','g','k','c'];
%         
%     for i = 1:length(all3dPoints(:,1))
%         figure(i)
%         for j=1:5
%             
%             
%            currentFrame = cell2mat(all3dPoints(i,j));
%            
%             if size(currentFrame) ~= [0,0]
%                 x = currentFrame(:,1);
%                 y = currentFrame(:,2);
%                 z = currentFrame(:,3);
%                 scatter3(x,y,z,colors(j))
%                 xlabel('x');ylabel('y');zlabel('z');
%                 %xlim([0,.05]);ylim([0 .05]),zlim([-1,1]);
%                 hold on
%                 
%                 az = 0;
%                 el = -90;
%                 view(az, el);
%             end
%         end
%     end
    
end





%sqrt((points3d(6,1)-points3d(5,1))^2+(points3d(6,2)-points3d(5,2))^2)