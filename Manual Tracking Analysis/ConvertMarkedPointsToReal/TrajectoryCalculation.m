%Titus John 
%Leventhal Lab, University of Michgian
%9/4/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This scripts takes in the 3d points using the triangulation_dl method and
%creates trajectory plots along with standard deviations of the ho the
%centroide of the paw moves through space after leaving ther center of the
%box




function  [allCentroids,averagedCentroids, euclidianDistDiff,  euclidianDistDiffMean, euclidianDistDiffStd]= TrajectoryCalculation(all3dPoints,score,RatID,day,fig_num_avg,fig_num_all,sucessRate,totalNumReaches)


    for i = 1:length(all3dPoints(:,1))
        for j =1:5
            currentFrame = all3dPoints{i,j};
            
             x = currentFrame(:,1);
             y = currentFrame(:,2);
             z = currentFrame(:,3);
                
            
             rubX = x(end-6:end-1);
             rubY = y(end-6:end-1);
             rubZ = z(end-6:end-1);
                
             pelX = x(end);
             pelY = y(end);
             pelZ = z(end);
                
            
            
            currentFrame = currentFrame(1:end-7,:);
            filteredAll3dPoints{i,j} = currentFrame;
        end 
    end
    
    [allCentroids] = calculateCentroid(filteredAll3dPoints);
    
    averagedCentroids = averageCentroids(allCentroids,score,day,fig_num_avg,sucessRate,RatID,totalNumReaches);
        
    [euclidianDistDiff,  euclidianDistDiffMean, euclidianDistDiffStd] = calculateVariance(allCentroids,averagedCentroids);

    [averagedCentroidsDisp] = calculatePositionChange3D(averagedCentroids)
    
   % [Velocity, Acceleration, Jerk] = KinematicCalc (averagedCentroidsDisp)
    
    plotCentroidTrajectories(allCentroids,score,day,fig_num_all,sucessRate,RatID,totalNumReaches);
    
    

end

function  [allCentroid] = calculateCentroid(filteredAll3dPoints)

size(filteredAll3dPoints)

    for i = 1:length(filteredAll3dPoints(:,1));
        for j =1:length(filteredAll3dPoints(1,:));
            
            x = [];
            y = [];
            z = [];
            
           
             currentFrame = filteredAll3dPoints{i,j};
             

             
             if size(currentFrame) > 0
                 x = currentFrame(:,1);
                 y = currentFrame(:,2);
                 z = currentFrame(:,3);
                 allCentroid{i,j} = [mean(x), mean(y), mean(z)];
             else
                allCentroid{i,j} = [];
             end
        end
    end
end

function  [averagedCentroids] = averageCentroids(allCentroids,score,day,fig_num_avg,sucessRate,RatID,totalNumReaches)

x_std = [];
y_std = [];
z_std = [];
            
            for i =1:5
                averagedCentroids{i} = nanmean(cell2mat(allCentroids(:,i)));
                stdCentroids{i} = nanstd(cell2mat(allCentroids(:,i)));
            end
            
            
           
            
           for k = 1:5
                    currentFrameAVG = averagedCentroids{k};
                
                    if size(currentFrameAVG) == [1, 3]
                        x_avg(k) = currentFrameAVG(:,1);
                        y_avg(k) = currentFrameAVG(:,2);
                        z_avg(k) = currentFrameAVG(:,3);

                        currentFrameSTD = stdCentroids{k};
                        x_std(k) = currentFrameSTD(:,1);
                        y_std(k) = currentFrameSTD(:,2);
                        z_std(k) = currentFrameSTD(:,3);
                    end
           end
            
           figure(fig_num_avg)
           hold on
           
%            for k = 1:4
%                [x,y,z] = calculate3DcirclePoints(x_avg(k),y_avg(k),z_avg(k),x_std(k), y_std(k),z_std(k), averagedCentroids(k), averagedCentroids(k+1));
%            end
           
         TF = exist('x_avg');
         
         if TF == 1
         
           if score == 1 
            plot3(x_avg,z_avg,y_avg,'r')
           elseif score ==7
            plot3(x_avg,z_avg,y_avg,'b')
           end
         end
                 
%            xlim([-5 25]);
%            zlim([-2, 10]);
%            ylim([170, 190]);
           
            xlabel('x');
            ylabel('z');
            zlabel('y');
            titleString  = strcat('Rat:', num2str(RatID), ' Day:',num2str(day),' Sucess Rate:',num2str(sucessRate,2), ' Total Reaches: ', num2str(totalNumReaches));
            title(titleString)
        
            
            az = -160;
            el = 42;
            view(az, el);
            set(gca,'zdir','reverse');
           
            
            
            
end

function [euclidianDistDiff,  euclidianDistDiffMean, euclidianDistDiffStd] = calculateVariance(allCentroids,averagedCentroids)
    for i =1:length(allCentroids(:,1))
        for j=1:5
            if size(allCentroids{i,j}) ~= [0,0]
                euclidianDistDiff{i,j} = abs(averagedCentroids{1,j} - allCentroids{i,j});
            else
                euclidianDistDiff{i,j} = [];
            end
        end
    end
    
    for i=1:length(euclidianDistDiff(1,:))
       i 
        euclidianDistDiffMean(:,i) = nanmean(cell2mat(euclidianDistDiff(:,i)));
        euclidianDistDiffStd(:,i) = std(cell2mat(euclidianDistDiff(:,i)))/sqrt(length(euclidianDistDiff(:,i)));
        
    end
end

function plotCentroidTrajectories(allCentroid,score,day,fig_num_all,sucessRate,RatID,totalNumReaches)
    
check = 0 ; %This is a check to stop plotting if NaN exisit     

    for i =1:length(allCentroid(:,1))
        
                    x = [];
                    y = [];
                    z = [];
                    
        check = 0;
        
        for j = 1:5
             currentFrame = allCentroid{i,j};
              
             
             if size(currentFrame)> 0
                 TF = 0;
             else
                 TF = 1;
             end
             
             if TF == 0 && check == 0;
                   
                    
                    x(j) = currentFrame(:,1);
                    y(j) = currentFrame(:,2);
                    z(j) = currentFrame(:,3);
                    
             elseif TF == 1
                check =1; 
             end
             
             
        end
        
        hold on
        
        figure(fig_num_all)
           if score == 1 
            plot3(x,z,y,'r')
           elseif score ==7
            plot3(x,z,y,'b')
           end
           
%            xlim([-5 25]);
%            zlim([-2, 10]);
%            ylim([170, 190]);
%            
            xlabel('x');
            ylabel('z');
            zlabel('y');
            titleString  = strcat('Rat:', num2str(RatID), ' Day:',num2str(day),' Sucess Rate:',num2str(sucessRate,2),' Total Reaches: ', num2str(totalNumReaches));
            title(titleString)
        
        az = -160;
        el = 42;
        view(az, el);
        set(gca,'zdir','reverse');
    end
end

%% Calculate the displacment in 3D 
function [averagedCentroidsDisp] = calculatePositionChange3D(averagedCentroids)
averagedCentroidsDisp= [];

        for k =1:4 %number of frames
                
            
                currentFrame = cell2mat(averagedCentroids(1,k));
                nextFrame = cell2mat(averagedCentroids(1,k+1));
                
                tf1 = sum( size(currentFrame) == [1,3]) ;
                tf2 = sum(size(nextFrame) == [1,3]);
                
                if (tf1 == 2 && tf2 == 2)
                    currentDispIndex = sqrt((currentFrame(1)-nextFrame(1))^2+(currentFrame(2)-nextFrame(2))^2+(currentFrame(3)-nextFrame(3))^2) ;
                    averagedCentroidsDisp(1,k) = currentDispIndex;
                end
        end

end

%% Calculate the Jerk (aka the 4th derivative of the position vector
function [Velocity, Acceleration, Jerk] = KinematicCalc (averagedCentroidsDisp)

    ts = 1/300;
    frames = 0:8:40;
    time = frames*ts;

    Velocity = [];
    Acceleration = [];
    Jerk = [];
    

        for j = 1:length(averagedCentroidsDisp(1,:))
            Velocity(1,j) = averagedCentroidsDisp(1,j)/ts ;%4 frames x by number of reaches 
        end

    for j = 1:length(Velocity(:,1))
        for i = 1:length(Velocity(1,:))-1%Number of colums remains constant
                Acceleration (j,i) = (Velocity(j,i+1)-Velocity(j,i))/ts  ;  
        end
    end
    
    TF = sum(size(Acceleration))
    
  if TF ==4 
     for j = 1:length(Acceleration(:,1))
        for i = 1:length(Acceleration(1,:))-1%Number of colums remains constant
                Jerk(j,i) = (Acceleration(j,i+1)-Acceleration(j,i))/ts;   
        end
     end
  end

end