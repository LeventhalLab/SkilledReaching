%This script is for taking the gross trajectory point centroids and running
%it through the triangualation methodology

%Input
%Put the left and center paw centers for an indicidual video

%Output
%The filtered version of the x,y,z and paw centers

%
function  [xfilt, yfilt, zfilt] = triangulateOneReach(side, center, P1,P2,pxToMm)

%Indicies for storing 
indexRealData= []; 
countData = 1;
 
    for i = 1:length(center)
        TFL = sum(isnan(side(i,:)));
        TFC = sum(isnan(center(i,:)));
        
           if TFL == 0 && TFC == 0
               
              indexRealData(countData) =  i;
              countData = countData + 1 ;
           end
    end

    
   all3dPoints=[];
   

   
   for i =1:length(indexRealData)
       FrameName = strcat('Frame : ',num2str(i));
       disp(FrameName)
       
      x1Side = center(indexRealData(i),:);
      x2Side = side(indexRealData(i),:);

     [points3d,reprojectedPoints,errors] = ConvertMarkedPointsToRealWorldOneFundemental(x1Side,x2Side,P1,P2);
     all3dPoints{i} = points3d*pxToMm;    
   end

   
   for i= 1:length(all3dPoints)
             currentFrame = all3dPoints{i};
             x(i) = currentFrame(:,1);
             y(i) = currentFrame(:,2);
             z(i) = currentFrame(:,3);
             
   end
   
        checkX = exist('x');
         
       if checkX == 1
             xfilt = smoothn(x,2,'robust');
             yfilt = smoothn(y,2,'robust');
             zfilt = smoothn(z,2,'robust');  
             
       else
           xfilt = [];
           yfilt = [];
           zfilt = [];
       end
end            
             
            
