%This script is for taking the groos trajectory point centroids and running
%it through the triungualation methodology

%Input
%Load the gross trajectory files or the days 3,5,7 and the csv score

%Output
%The filtered version of the x,y,z and paw centers

%
function [x_avg,x_var,x_new,y_avg,y_var,y_new,z_avg,z_var,z_new,diffrenceFrames,pelletTouches,barrierBreaks] =  plotGrossTrajectoryTriangulation(x,y,z,Scores,ScorestoReturn)%,FigAll,FigSucessFail)

           x_temp = [];
           x_avg = [];
           x_new = [];
           
           
           
           y_temp = [];
           y_avg = [];
           y_new = [];

  
           z_temp = [];
           z_avg = [];
           z_new = [];
           
           

   for i =1:length(x)
       for j = 1:length(cell2mat(x(1,i)))
           x_temp = cell2mat(x(1,i));
           x_temp(x_temp == 0) = NaN;
           x_new(i,j)= x_temp(j);
           x_new(x_new == 0) = NaN;
           
           y_temp = cell2mat(y(1,i));
           y_temp(y_temp == 0) = NaN;
           y_new(i,j)= y_temp(j);
           y_new(y_new == 0) = NaN;
           
           z_temp = cell2mat(z(1,i));
           z_temp(z_temp == 0) = NaN;
           z_new(i,j)= z_temp(j);
           z_new(z_new == 0) = NaN;
           
       end
   end
   
  %Find the times when the paw crosses the front of the box
  barrierBreaks= findPawCrossing(z_new);
  
  %Find the time when the paw center is closest to the pellet center
  load('pellet3dpoint.mat');
  pelletTouches = findPelletTouch(x_new,y_new,z_new,pelletpoints3d,barrierBreaks) %Putting this for the left pellet location for now
  
   
 
  diffrenceFrames = pelletTouches- barrierBreaks;
  
   for i=1: length(pelletTouches)
       currentStartFrame = pelletTouches(i);
       
       if currentStartFrame >= 20 && (currentStartFrame+70) < length(x_new(i,:))
           currentTrialX = x_new(i,:);
           holdX = currentTrialX(currentStartFrame-19:currentStartFrame+70);


           currentTrialY = y_new(i,:);
           holdY = currentTrialY(currentStartFrame-19:currentStartFrame+70);


           currentTrialZ = z_new(i,:);
           holdZ = currentTrialZ(currentStartFrame-19:currentStartFrame+70);
       else
           disp(i)
           holdX = 0 ;
           holdY = 0;
           holdZ = 0;
       end
       
       for j = 1:length(holdX)
           x_adjusted(i,j) = holdX(j); 
           y_adjusted(i,j) = holdY(j); 
           z_adjusted(i,j) = holdZ(j); 
       end
   end
   
           %Replace 0 with NaNs
           x_adjusted(x_adjusted == 0) = NaN
           y_adjusted(y_adjusted == 0) = NaN;
           z_adjusted(z_adjusted == 0) = NaN;

           %Set back to the original matrix
            x_new = x_adjusted;
            y_new = y_adjusted;
            z_new = z_adjusted;
           
           counterSucess = 1;
           counterFail = 1;  
           
            x_sucess = [];
            y_sucess = [];
            z_sucess = [];
 
            
            
           length(x_new(:,1))
           length(Scores)
           
           
   for i=1:length(x_new(:,1))
       if Scores(i) == 1
            x_sucess(counterSucess,:) = x_new(i,:);
            y_sucess(counterSucess,:) = y_new(i,:);
            z_sucess(counterSucess,:) = z_new(i,:);
            counterSucess = counterSucess + 1;
        elseif Scores(i) == 4 || Scores(i)  == 7  || Scores(i) == 2
            x_fail(counterFail,:) = x_new(i,:);
            y_fail(counterFail,:) = y_new(i,:);
            z_fail(counterFail,:) = z_new(i,:);
            counterFail = counterFail + 1;
        end      
   end
   
   
  checkXsuccess =  size(x_sucess);
   
   if checkXsuccess ~= [0,0]
      for i=1:length(x_sucess(1,:))
           x_avg_sucess(i) = nanmean(x_sucess(:,i));
           y_avg_sucess(i) = nanmean(y_sucess(:,i));
           z_avg_sucess(i) = nanmean(z_sucess(:,i));

           x_var_sucess(i) =  nanvar(x_sucess(:,i));
           y_var_sucess(i) =  nanvar(y_sucess(:,i));
           z_var_sucess(i) =  nanvar(z_sucess(:,i));
      end
   end
   
    
      
      
   
     for i=1:length(x_fail(1,:))
       x_avg_fail(i) = nanmean(x_fail(:,i));
       y_avg_fail(i) = nanmean(y_fail(:,i));
       z_avg_fail(i) = nanmean(z_fail(:,i));
       
       x_var_fail(i) =  nanvar(x_fail(:,i));
       y_var_fail(i) =  nanvar(y_fail(:,i));
       z_var_fail(i) =  nanvar(z_fail(:,i));
     end

     
     
     if ScorestoReturn == 1 
         if checkXsuccess ~= [0,0]
             x_avg = x_avg_sucess;
             x_var = x_var_sucess;

             y_avg = y_avg_sucess;
             y_var = y_var_sucess;

             z_avg = z_avg_sucess;
             z_var = z_var_sucess;
         else
             
             x_avg = zeros(1,90);
             x_var = zeros(1,90);

             y_avg = zeros(1,90);
             y_var = zeros(1,90);

             z_avg = zeros(1,90);
             z_var = zeros(1,90);
             
         end
     elseif ScorestoReturn == 7
         x_avg = x_avg_fail;
         x_var = x_var_fail;
        
         y_avg = y_avg_fail;
         y_var = y_var_fail;
       
         z_avg = z_avg_fail;
         z_var = z_var_fail;
    
     end
     
%      %Convert to SD
%      x_var = sqrt(x_var);
%      y_var = sqrt(y_var);
%      z_var = sqrt(z_var);
%      
   
%      
%      figure(FigAll)
%      hold on
%      for i=1:length(x)
%       
%         current_x = cell2mat(x(i)); 
%         current_y = cell2mat(y(i));
%         current_z = cell2mat(z(i)) ;
%        
%          TF =isempty(current_x);
%         if TF == 0
%             colormapline(current_x,current_z,-current_y);
%         end
%         
%      end
%    
%    
%      figure(FigSucessFail)
%      hold on
%     plot3(x_avg_sucess,z_avg_sucess,-y_avg_sucess,'r')
%     plot3(x_avg_fail,z_avg_fail,-y_avg_fail,'b')
   
end