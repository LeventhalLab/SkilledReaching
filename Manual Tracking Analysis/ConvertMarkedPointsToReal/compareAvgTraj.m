function compareAvgTraj(averagedCentroidsSuccess,averagedCentroidsFail,VelocitySuccess,VelocityFail,AccelerationSuccess, AccelerationFail,JerkSuccess, JerkFail,day, RatID)

[euclidDiffAvgTraj] = calcEuclidianDiffBetweenAvgTraj(averagedCentroidsSuccess,averagedCentroidsFail,day,RatID);


% [velocityDiffAvgTraj] = calcVelocityDiffBetweenAvgTraj(VelocitySuccess,VelocityFail,day);
% [accelDiffAvgTraj] = calcAccelDiffBetweenAvgTraj(AccelerationSuccess, AccelerationFail,day);
% [jerkDiffAvgTraj] = calcJerkDiffBetweenJerkTraj(JerkSuccess,JerkFail,day);

end





function [euclidDiffAvgTraj] = calcEuclidianDiffBetweenAvgTraj(averagedCentroidsSuccess,averagedCentroidsFail,day,RatID)

    for i = 1:5
        currentframeSuccess = cell2mat(averagedCentroidsSuccess(i));
        currentframeFail = cell2mat(averagedCentroidsFail(i));
        
         tf1 = sum( size(currentframeSuccess) == [1,3]) ;
         tf2 = sum(size(currentframeFail) == [1,3]);
        
        
         if (tf1 == 2 && tf2 == 2)
                euclidDiffAvgTraj(i) = sqrt((currentframeSuccess(1)-currentframeFail(1))^2+(currentframeSuccess(2)-currentframeFail(2))^2+(currentframeSuccess(3)-currentframeFail(3))^2);
         end
    end
    
    frames = 1:length(euclidDiffAvgTraj);
    
    
    figure(7)  
    titleString = strcat('Euclidian Diffrence Average Rat ',num2str(RatID))
    title(titleString)
    hold on

    
    if day  == 3
        scatter(frames,euclidDiffAvgTraj,'k')
        plot(frames,euclidDiffAvgTraj,'-k') 
    elseif day == 5
        scatter(frames,euclidDiffAvgTraj,'b')
        plot(frames,euclidDiffAvgTraj,':b') 
    else 
        scatter(frames,euclidDiffAvgTraj,'g')
        plot(frames,euclidDiffAvgTraj,'-.g') 
    end

end

function velocityDiffAvgTraj = calcVelocityDiffBetweenAvgTraj(VelocitySuccess,VelocityFail,day)
    
    velocityDiffAvgTraj = abs(VelocitySuccess-VelocityFail);


    
    figure(8)
    hold on
    title('Velocity')
    frames = 1:4;

        scatter(frames,VelocitySuccess,'r')
        scatter(frames,VelocityFail,'b')


    if day  == 3
        plot(frames,VelocitySuccess,'-k') 
        plot(frames,VelocityFail,'-k')
    elseif day == 5
        plot(frames,VelocitySuccess,':b') 
        plot(frames,VelocityFail,':b')
    else 
        plot(frames,VelocitySuccess,'-.g') 
        plot(frames,VelocityFail,'-.g')
     end
   
    


end

function accelDiffAvgTraj = calcAccelDiffBetweenAvgTraj(AccelerationSuccess, AccelerationFail,day)

    accelDiffAvgTraj= abs(AccelerationSuccess-AccelerationFail);
     
     figure(9)
     hold on
     title('Acceleration')
     frames = 1:3;
     
   
        scatter(frames,AccelerationSuccess,'r')
        scatter(frames,AccelerationFail,'b')
    
    
    if day  == 3
        plot(frames,AccelerationSuccess,'-k') 
        plot(frames,AccelerationFail,'-k')
    elseif day == 5
        plot(frames,AccelerationSuccess,':b') 
        plot(frames,AccelerationFail,':b')
    else 
        plot(frames,AccelerationSuccess,'-.g') 
        plot(frames,AccelerationFail,'-.g')
    end
    
end


function  jerkDiffAvgTraj = calcJerkDiffBetweenJerkTraj(JerkSuccess,JerkFail, day)
     
    jerkDiffAvgTraj = abs(JerkSuccess-JerkFail)
    
     figure(10)
     hold on
     title('Jerk')
     frames = 1:2;
   
     
        scatter(frames,JerkSuccess,'r')
        scatter(frames,JerkFail,'b')
 
    if day  == 3
        plot(frames,JerkSuccess,'-k') 
        plot(frames,JerkFail,'-k')
    elseif day == 5
        plot(frames,JerkSuccess,':b') 
        plot(frames,JerkFail,':b')
    else 
        plot(frames,JerkSuccess,'-.g') 
        plot(frames,JerkFail,'-.g')
    end

end 