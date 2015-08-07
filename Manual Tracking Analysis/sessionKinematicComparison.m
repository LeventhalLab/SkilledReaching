%Titus John
%Leventhal Lab
%8/6/15
%% This program takes in the Rat Dat from diffrent days during training and produces 
%comparison information

%% Master function for calling the differnct rat data structures into the functio


    
    N3 = 'R0027Session20140512PawPointFiles.mat';
    N5 = 'R0027Session20140512PawPointFiles.mat';
    N7 = 'R0027Session20140512PawPointFiles.mat';
    

    
    
%This data 
    load(N3)
    [N3Velocities]= analyzeManualTrialData(RatData)
    
    load(N5)
    [N5Velocities]= analyzeManualTrialData(RatData)
    
    load(N7)
    [N7Velocities]= analyzeManualTrialData(RatData)
     
     
 %Take all the velocities for the given day in 
    for i=1:length(N3)
      
      indexVelocities = cell2mat(N3Velocities(1))  
      middleVelocities =  cell2mat(N3Velocities(2))
      ringVelocities =  cell2mat(N3Velocities(3))
      pinkyVelocities = cell2mat(N3Velocities(4))
      
    end
    
 %Take a
    