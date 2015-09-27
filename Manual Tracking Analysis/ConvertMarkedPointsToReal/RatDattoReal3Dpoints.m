%Titus John
%Leventhal Lab, University of Michigan
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This scripts will take the X1 and the X2 matricies and push them to the
%conver markter poiints to real worl in order to spit out the 3d points for
%a given trial and frame

function [all3dPoints] = RatDatatoReal3Dpoints(RatData,score)
   load rubiksX1
   load rubiksX2
   load rubiksX3
   
   
   r1 = rubiksX1;
   r2 = rubiksX3;
   
%    
%    pel1 = [1053 626];
%    pel2 = [154 595];

pel1 = [932 735];
pel2 = [1917 660];
   
   all3dPoints=[];
    
    
    [X1,X2] = RatDataToMPMatrcies(RatData,score);

    for i=1:length(X1(:,1))
        for j= 1:5
            x1 = X1{i,j};
            x2 = X2{i,j};
            
            x1= vertcat(x1,r1,pel1);
            x2= vertcat(x2,r2,pel2);
    
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
%                
%                 
%                 digitsX = x(1:end-7);
%                 digitsY = y(1:end-7);
%                 digitsZ = z(1:end-7);
%                 
%                
%                 rubX = x(end-6:end-1);
%                 rubY = y(end-6:end-1);
%                 rubZ = z(end-6:end-1);
%                 
%                 pelX = x(end);
%                 pelY = y(end);
%                 pelZ = z(end);
%                 
%                 
%                 scatter3(digitsX,digitsY,digitsZ,colors(j))
%                 
%                 hold on
%                 scatter3(pelX,pelY,pelZ,'k','filled')
%                 
%                 hold on
%                 scatter3(rubX,rubY,rubZ,'k','filled')
%                 
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

