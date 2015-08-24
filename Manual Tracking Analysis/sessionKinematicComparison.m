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
    [index_x3,index_y3,index_z3,middle_x3,middle_y3,middle_z3,ring_x3,ring_y3,ring_z3,pinky_x3,pinky_y3,pinky_z3]= analyzeManualTrialData(RatData);
    %[N3avgIndexVelocity, N3stdIndexVelocity, N3avgMiddleVelocity, N3stdMiddleVelocity,N3avgRingVelocity, N3stdRingVelocity, N3avgPinkyVelocity, N3stdPinkyVelocity ] = getAverageVelocities(N3Velocities);
    
    
    load(N5)
    [index_x5,index_y5,index_z5,middle_x5,middle_y5,middle_z5,ring_x5,ring_y5,ring_z5,pinky_x5,pinky_y5,pinky_z5]= analyzeManualTrialData(RatData);
    
    %[N5avgIndexVelocity, N5stdIndexVelocity,N5avgMiddleVelocity, N5stdMiddleVelocity,N5avgRingVelocity, N5stdRingVelocity, N5avgPinkyVelocity, N5stdPinkyVelocity ] = getAverageVelocities(N5Velocities);
    
    
    load(N7)
	[index_x7,index_y7,index_z7,middle_x7,middle_y7,middle_z7,ring_x7,ring_y7,ring_z7,pinky_x7,pinky_y7,pinky_z7]= analyzeManualTrialData(RatData);

    %[N7avgIndexVelocity, N7stdIndexVelocity,N7avgMiddleVelocity, N7stdMiddleVelocity,N7avgRingVelocity, N7stdRingVelocity, N7avgPinkyVelocity, NstdPinkyVelocity ] = getAverageVelocities(N7Velocities);
    
    
    
    
    
    
    figure('Name','Index')
    plotXYZanalysis(index_x3,index_y3,index_z3,'r') 
    plotXYZanalysis(index_x5,index_y5,index_z5,'k')
    plotXYZanalysis(index_x7,index_y7,index_z7,'b') 
  

    
    figure('Name','Middle')
    plotXYZanalysis(middle_x3,middle_y3,middle_z3,'r')
    plotXYZanalysis(middle_x5,middle_y5,middle_z5,'k')
    plotXYZanalysis(middle_x7,middle_y7,middle_z7,'b') 


    
    
    figure('Name','Ring')
    plotXYZanalysis(ring_x3,ring_y3,ring_z3,'r') 
    plotXYZanalysis(ring_x5,ring_y5,ring_z5,'k')
   plotXYZanalysis(ring_x7,ring_y7,ring_z7,'b') 

    
    figure('Name','Pinky')
    plotXYZanalysis(pinky_x3,pinky_y3,pinky_z3,'r') 
    plotXYZanalysis(pinky_x5,pinky_y5,pinky_z5,'k')
     plotXYZanalysis(pinky_x7,pinky_y7,pinky_z7,'b') 
  



    %plotKinematicComparisons(N3avgIndexVelocity, N5avgIndexVelocity, N7avgIndexVelocity,N3stdIndexVelocity,N5stdIndexVelocity, N7stdIndexVelocity)
%     
%     plotDistalDistancetoPellet(N3distalDistancetoPellet,N3SemDistalDistancestoPellet)
%     plotDistalDistancetoPellet(N5distalDistancetoPellet,N5SemDistalDistancestoPellet)
%     plotDistalDistancetoPellet(N7distalDistancetoPellet,N7SemDistalDistancestoPellet)
end


function plotXYZanalysis(currentDay_x,currentDay_y,currentDay_z,color) 
    
    for i =1:length(currentDay_x(1,:))

        avgIndex_x(i) = mean(nonzeros(currentDay_x(:,i)));
        varIndex_x(i)= std(nonzeros(currentDay_x(:,i)));

        avgIndex_y(i) = mean(nonzeros(currentDay_y(:,i)));
        varIndex_y(i) = std(nonzeros(currentDay_y(:,i)));

        avgIndex_z(i) = mean(nonzeros(currentDay_z(:,i)));
        varIndex_z(i) = std(nonzeros(currentDay_z(:,i)));
    end
 
    
        
        
        frames=1:5;

        hold on
        subplot(3,1,1)
        errorbar(frames,avgIndex_x,varIndex_x,color);
        xlabel('frames');
        ylabel('x-pos');
        ylim([800 1200])
        
        hold on
        subplot(3,1,2)
        errorbar(frames,avgIndex_y,varIndex_y,color);
        xlabel('frames');
        ylabel('y-pos');
        ylim([400 800])
        
        hold on
        subplot(3,1,3)
        errorbar(frames,avgIndex_z,varIndex_z,color);
        xlabel('frames');
        ylabel('z-pos');
        ylim([-200 2500])
        
     legend('Day 3', 'Day 5', 'Day 7');
   


        
       
end

function plotDistalDistancetoPellet(currentDayDistances,semCurrentDayDistances)
        indexDistToPellet = cell2mat(currentDayDistances(1));  
        middleDistToPellet = cell2mat(currentDayDistances(2));
        ringDistToPellet =  cell2mat(currentDayDistances(3));
        pinkyDistToPellet = cell2mat(currentDayDistances(4));
        
        indexSemDistToPellet = cell2mat(semCurrentDayDistances(1));  
        middleSemDistToPellet = cell2mat(semCurrentDayDistances(2));
        ringSemDistToPellet =  cell2mat(semCurrentDayDistances(3));
        pinkySemDistToPellet = cell2mat(semCurrentDayDistances(4));
        
        
        
        
        figure
        frames=1:5;
        hold on
        errorbar(frames,indexDistToPellet, indexSemDistToPellet,'r')
        errorbar(frames,middleDistToPellet, middleSemDistToPellet,'b')
        errorbar(frames,ringDistToPellet,ringSemDistToPellet,'g')
        errorbar(frames,pinkyDistToPellet,pinkySemDistToPellet,'k')

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

