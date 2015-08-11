%Titus John
%Leventhal Lab
%8/6/15
% This program takes in the Rat Dat from diffrent days during training and produces comparison information

%% Master function for calling the differnct rat data structures into the functio
function sessionKinematicComparison
    N3 = 'R0027Session20140512PawPointFiles.mat';
    N5 = 'R0027Session20140514PawPointFiles.mat';
    N7 = 'R0027Session20140516PawPointFiles.mat';
    
    load(N3)
    [N3Velocities, ]= analyzeManualTrialData(RatData);
    %[N3avgIndexVelocity, N3stdIndexVelocity, N3avgMiddleVelocity, N3stdMiddleVelocity,N3avgRingVelocity, N3stdRingVelocity, N3avgPinkyVelocity, N3stdPinkyVelocity ] = getAverageVelocities(N3Velocities);
    
    
    load(N5)
    [N5Velocities]= analyzeManualTrialData(RatData);
    %[N5avgIndexVelocity, N5stdIndexVelocity,N5avgMiddleVelocity, N5stdMiddleVelocity,N5avgRingVelocity, N5stdRingVelocity, N5avgPinkyVelocity, N5stdPinkyVelocity ] = getAverageVelocities(N5Velocities);
    
    
    load(N7)
    [N7Velocities]= analyzeMaynualTrialData(RatData)
    %[N7avgIndexVelocity, N7stdIndexVelocity,N7avgMiddleVelocity, N7stdMiddleVelocity,N7avgRingVelocity, N7stdRingVelocity, N7avgPinkyVelocity, NstdPinkyVelocity ] = getAverageVelocities(N7Velocities);


    plotKinematicComparisons(N3avgIndexVelocity, N5avgIndexVelocity, N7avgIndexVelocity,N3stdIndexVelocity,N5stdIndexVelocity, N7stdIndexVelocity)
    
    
    plotPawAngle(N3Velocities)
    
end
     
      
      
function [avgIndexVelocity, stdIndexVelocity,avgMiddleVelocity, stdMiddleVelocity, avgRingVelocity, stdRingVelocity, avgPinkyVelocity, stdPinkyVelocity] = getAverageVelocities(currentDayVelocities)

        %Take all the velocities for Day 3
        indexVelocities = cell2mat(currentDayVelocities(1));  
        middleVelocities = cell2mat(currentDayVelocities(2));
        ringVelocities =  cell2mat(currentDayVelocities(3));
        pinkyVelocities = cell2mat(currentDayVelocities(4));

        for i = 1:length(indexVelocities(1,:))
            avgIndexVelocity(i) = sum(indexVelocities(:,i))./ sum(indexVelocities(:,i)~=0);
            stdIndexVelocity(i) = std(indexVelocities(:,i)) ;
        end     
        
           for i = 1:length(middleVelocities(1,:))
            avgMiddleVelocity(i) = sum(middleVelocities(:,i))./ sum(middleVelocities(:,i)~=0);
            stdMiddleVelocity(i) = std(middleVelocities(:,i)) ;
           end     
        
              for i = 1:length(ringVelocities(1,:))
            avgRingVelocity(i) = sum(ringVelocities(:,i))./ sum(ringVelocities(:,i)~=0);
            stdRingVelocity(i) = std(ringVelocities(:,i)) ;
              end     
        
                 for i = 1:length(pinkyVelocities(1,:))
            avgPinkyVelocity(i) = sum(pinkyVelocities(:,i))./ sum(pinkyVelocities(:,i)~=0);
            stdPinkyVelocity(i) = std(pinkyVelocities(:,i)) ;
        end     
        
end
    

function plotKinematicComparisons(Day3Velocities, Day5Velocities, Day7Velocities, Day3STD, Day5STD,Day7STD)
    frames= 1:4;
    hold on 
    errorbar(frames, Day3Velocities, Day3STD,'r')
    errorbar(frames, Day5Velocities, Day5STD,'b')
    errorbar(frames, Day7Velocities, Day7STD,'g')
end

function plotPawAngle()

end