%Titus John
%Leventhal Lab
%7/19/2015
%% About analyze manual trial data
%This program will take in the manual paw data (ie. the xy coordinates)
%for the three given prespectives and spit out analysis 
%Paramaters read in from Paw_Points Tracking Data file

%Each of these is take in for the prespectives Left, Right, Center

%Pellet Center

%Center of Back Surface of Paw

%Thumb Proximal
%Thumb Distal

% Index proximal
% Index middle
% Index distal
% 
% Middle proximal
% Middle middle
% Middle distal
% 
% Ring proximal
% Ring middle
% Ring distal
% 
% Pinky proximal
% Pinky middle
% Pinky distal


%% Master function for calling all the seperate functions written into script
%Feed in the master 
function  [allDistalDistancestoPellet]= analyzeManualTrialData(RatData)
    
    allPawData = [];
    Scores=[RatData.VideoFiles.Score]';
    
   

    j= 1;
    for i=1:length(Scores)
        if Scores(i) == 1
            tempAllPawData = RatData.VideoFiles(i).Paw_Points_Tracking_Data;
            
            counter = 1; %This is the counter that represents the actual length of filled data
            for k =1:length(tempAllPawData)
                if sum(cell2mat(tempAllPawData(k,1))) > 0
                    filteredPawData(counter,:) = tempAllPawData(k,:);
                    
                    counter = counter + 1;
                end
            end         
            allPawData{j}= filteredPawData; 
            j = j+1;
        end
    end
    
   
    
    allPawSpreadDistPICenter = [];
    allPawSpreadDistRICenter = [];
    allPawSpreadDistMICenter = [];
    
   for i = 1:length(allPawData)
        pawPointsData = allPawData{1,i};
        [pelletCenter, pawBackCenter, thumbProx, thumbDist, indexProx, indexMid, indexDist, middleProx, middleMid, middleDist, ringProx, ringMid, ringDist, pinkyProx, pinkyMid, pinkyDist] = readDataFromPawPoints (pawPointsData);
        
        [indexDistLeft, indexDistCenter, indexDistRight,middleDistLeft, middleDistCenter, middleDistRight,ringDistLeft, ringDistCenter, ringDistRight, pinkyDistLeft, pinkyDistCenter, pinkyDistRight, pelletCenterLeft, pelletCenterCenter, pelletCenterRight] = normalizeData(pelletCenter, pawBackCenter, indexDist, middleDist,  ringDist, pinkyDist);
        [indexProxLeft, indexProxCenter, indexProxRight,middleProxLeft, middleProxCenter, middleProxRight,ringProxLeft, ringProxCenter, ringProxRight, pinkyProxLeft, pinkyProxCenter, pinkyProxRight, pelletCenterLeft, pelletCenterCenter, pelletCenterRight] = normalizeData(pelletCenter, pawBackCenter,indexProx, middleProx,  ringProx, pinkyProx);
        [indexMidLeft, indexMidCenter, indexMidRight,middleMidLeft, middleMidCenter, middleMidRight,ringMidLeft, ringMidCenter, ringMidRight, pinkyMidLeft, pinkyMidCenter, pinkyMidRight, pelletCenterLeft, pelletCenterCenter, pelletCenterRight] = normalizeData(pelletCenter, pawBackCenter, indexMid, middleMid,  ringMid, pinkyMid);
        

        
        
        allIndexProxCenter{i} = indexProxCenter;
        allMiddleProxCenter{i} = middleProxCenter; 
        allRingProxCenter{i} = ringProxCenter;
        allPinkyProxCenter{i} = pinkyProxCenter;
        
        allIndexMidCenter{i} = indexMidCenter;
        allMiddleMidtCenter{i} = middleMidCenter; 
        allRingMidCenter{i} = ringMidCenter;
        allPinkyMidCenter{i} = pinkyMidCenter;
        
        
        allIndexDistCenter{i} = indexDistCenter;
        allMiddleDistCenter{i} = middleDistCenter; 
        allRingDistCenter{i} = ringDistCenter;
        allPinkyDistCenter{i} = pinkyDistCenter;
        

             
           
           [pinkyProx3] = create3Dpoints (pinkyProxLeft,pinkyProxCenter, pinkyProxRight);
           [middleProx3] = create3Dpoints (middleProxLeft,middleProxCenter, middleProxRight);
           [ringProx3] = create3Dpoints (ringProxLeft,ringProxCenter, ringProxRight);
           [indexProx3] = create3Dpoints (indexProxLeft,indexProxCenter, indexProxRight);
 
           
           [pinkyMid3] = create3Dpoints (pinkyMidLeft,pinkyMidCenter, pinkyMidRight);
           [middleMid3] = create3Dpoints (middleMidLeft,middleMidCenter, middleMidRight);
           [ringMid3] = create3Dpoints (ringMidLeft,ringMidCenter, ringMidRight);
           [indexMid3] = create3Dpoints (indexMidLeft,indexMidCenter, indexMidRight);

           
           [pinkyDist3] = create3Dpoints (pinkyDistLeft,pinkyDistCenter, pinkyDistRight);
           [middleDist3] = create3Dpoints (middleDistLeft,middleDistCenter, middleDistRight);
           [ringDist3] = create3Dpoints (ringDistLeft,ringDistCenter, ringDistRight);
           [indexDist3] = create3Dpoints (indexDistLeft,indexDistCenter, indexDistRight);
           
          
           [pellet3] = create3Dpoints(pelletCenterLeft,pelletCenterCenter,pelletCenterRight);
           
           

         for k = 1:length(pinkyDist3)
            
            allPinkyProx3(i,k) = pinkyProx3(k);
            allPinkyMid3(i,k)  = pinkyMid3 (k);
            allPinkyDist3(i,k) = pinkyDist3(k);
     
            allIndexProx3(i,k) = indexProx3(k);
            allIndexMid3(i,k)  = indexMid3 (k);
            allIndexDist3(i,k) = indexDist3(k);
       

            allMiddleProx3(i,k) = middleProx3(k);
            allMiddleMid3(i,k)  = middleMid3 (k);
            allMiddleDist3(i,k) = middleDist3(k);
        
         
            allRingProx3(i,k) = ringProx3(k);
            allRingMid3(i,k)  = ringMid3 (k);
            %allRingDist3(i,k) = ringDist3(k) this isnt the same length as
            %all the others
         end 
         
         for k = 1:length(ringDist3)
            allRingDist3(i,k) = ringDist3(k);
         end
         
         for k =1:length(pellet3)
             allPellet3(i,k) = pellet3(k);
         end

   end
   
   
    [dispIndex,dispMiddle,dispRing,dispPinky] = calculatePositionChange(allIndexDistCenter);%, allMiddleDistCenter, allRingDistCenter, allPinkyDistCenter)
    PI3DistanceSeperation = calc3DistancePawSpread (allPinkyDist3 , allIndexDist3);
   
  
    plot3DistancePawSpread (PI3DistanceSeperation);
    
 plot3DModelofPaw (allIndexMid3,allMiddleMid3,allRingMid3,allPinkyMid3,allIndexProx3,allMiddleProx3,allRingProx3,allPinkyProx3,allIndexDist3,allMiddleDist3,allRingDist3,allPinkyDist3)
   
   
    [dispIndexDist3D] = calculatePositionChange3D(allIndexDist3);
    [dispMiddleDist3D] = calculatePositionChange3D(allMiddleDist3);
    [dispRingDist3D] = calculatePositionChange3D(allRingDist3);
    [dispPinkyDist3D] = calculatePositionChange3D(allPinkyDist3);
   
    [indexDistVelocity , indexDistAcceleration, indexDistJerk] = KinematicCalc (dispIndexDist3D);
    [middleDistVelocity , middleDistAcceleration, middleDistJerk] = KinematicCalc (dispMiddleDist3D);
    [ringDistVelocity , ringDistAcceleration, ringDistJerk] = KinematicCalc (dispRingDist3D);
    [pinkyDistVelocity , pinkyDistAcceleration, pinkyDistJerk] = KinematicCalc (dispPinkyDist3D);
    
    
    
   [distanceIndexDisttoPellet, distanceMiddleDisttoPellet, distanceRingDisttoPellet,distancePinkyDisttoPellet] = calcDistancetoPellet(allIndexDist3,allMiddleDist3,allRingDist3,allPinkyDist3,allPellet3);
    
    allVelocity{1} = indexDistVelocity;
    allVelocity{2} = middleDistVelocity;
    allVelocity{3} = ringDistVelocity;
    allVelocity{4} = pinkyDistVelocity;
    
    
    allDistalDistancestoPellet{1} = distanceIndexDisttoPellet;
    allDistalDistancestoPellet{2} = distanceMiddleDisttoPellet;
    allDistalDistancestoPellet{3} = distanceRingDisttoPellet;
    allDistalDistancestoPellet{4} = distancePinkyDisttoPellet;
end

%% Function to read the data from the rat data array structure into indciudal arrays
function [pelletCenter, pawBackCenter, thumbProx, thumbDist, indexProx, indexMid, indexDist, middleProx, middleMid, middleDist, ringProx, ringMid, ringDist, pinkyProx, pinkyMid, pinkyDist] = readDataFromPawPoints (pawPointsData)

pelletCenter = [];
pawBackCenter = [];

thumbProx = [];
thumbDist = [];

indexProx = [];
indexMid = [];
indexDist= [];

middleProx= [];
middleMid = [];
middleDist= [];

ringProx = [];
ringMid= [];
ringDist = [];

pinkyProx = [];
pinkyMid = [];
pinkyDist = [];





overallCounter = 1;

    for i=1:5
        for j=1:3
            for k=overallCounter:(overallCounter+15) 
                if overallCounter<241
                    
                     %Pellet Center 
                     if mod(overallCounter,16) == 1
                        pelletCenter{i,j} = [pawPointsData(k,7),pawPointsData(k,8)];
                     end
                     %Back of paw
                     if mod(overallCounter,16) == 2
                        pawBackCenter{i,j} = [pawPointsData(k,7),pawPointsData(k,8)];
                     end

                     %Thumb
                     if mod(overallCounter,16) == 3
                        thumbProx{i,j} = [pawPointsData(k,7),pawPointsData(k,8)];
                     end

                     if mod(overallCounter,16) == 4
                        thumbDist{i,j} = [pawPointsData(k,7),pawPointsData(k,8)];
                     end
                     
                     
                     %Index
                     if mod(overallCounter,16) == 5
                        indexProx{i,j} = [pawPointsData(k,7),pawPointsData(k,8)];
                     end
                     
                     if mod(overallCounter,16) == 6
                        indexMid{i,j} = [pawPointsData(k,7),pawPointsData(k,8)];
                     end

                     if mod(overallCounter,16) == 7
                        indexDist{i,j} = [pawPointsData(k,7),pawPointsData(k,8)];
                     end

                     %Middle
                     if mod(overallCounter,16) == 8
                        middleProx{i,j} = [pawPointsData(k,7),pawPointsData(k,8)];
                     end


                     if mod(overallCounter,16) == 9
                        middleMid{i,j} = [pawPointsData(k,7),pawPointsData(k,8)];
                     end

                      if mod(overallCounter,16) == 10
                        middleDist{i,j} = [pawPointsData(k,7),pawPointsData(k,8)];
                      end

                
                     %Ring
                     if mod(overallCounter,16) == 11
                        ringProx{i,j} = [pawPointsData(k,7),pawPointsData(k,8)];
                     end


                     if mod(overallCounter,16) == 12
                        ringMid{i,j} = [pawPointsData(k,7),pawPointsData(k,8)];
                     end


                      if mod(overallCounter,16) == 13
                        ringDist{i,j} = [pawPointsData(k,7),pawPointsData(k,8)];
                      end


                     %Pinky
                     if mod(overallCounter,16) == 14
                        pinkyProx{i,j} = [pawPointsData(k,7),pawPointsData(k,8)];
                     end


                     if mod(overallCounter,16) == 15
                        pinkyMid{i,j} = [pawPointsData(k,7),pawPointsData(k,8)];
                     end


                      if mod(overallCounter,16) == 0
                        pinkyDist{i,j} = [pawPointsData(k,7),pawPointsData(k,8)];
                      end

                    
                    overallCounter = overallCounter + 1;
                end
            end
        end
    end
    
end

%% Plot ball stick models of the data
function plotBallStick
    for i= 1:5
        for j =1:3
        pawBackCenter_xy = cell2mat(pawBackCenter{1,1});
      
        indexProx_xy = cell2mat(indexProx{i,j});
        middleProx_xy = cell2mat(middleProx{i,j});
        ringProx_xy = cell2mat(ringProx{i,j});
        pinkyProx_xy = cell2mat(pinkyProx{i,j});
        
    
        indexMid_xy = cell2mat(indexMid{i,j});
        middleMid_xy = cell2mat(middleMid{i,j});
        ringMid_xy = cell2mat(ringMid{i,j});
        pinkyMid_xy = cell2mat(pinkyMid{i,j});
        
        indexDist_xy = cell2mat(indexDist{i,j});
        middleDist_xy = cell2mat(middleDist{i,j});
        ringDist_xy = cell2mat(ringDist{i,j});
        pinkyDist_xy = cell2mat(pinkyDist{i,j});

 
       
        
        figure(1)
        hold on
        scatter(pawBackCenter_xy(1),pawBackCenter_xy(2))
        
        
        scatter(indexProx_xy(1), indexProx_xy(2),'r')
        scatter(middleProx_xy(1), middleProx_xy(2),'r')
        scatter(ringProx_xy(1), ringProx_xy(2),'r')
        scatter(pinkyProx_xy(1), pinkyProx_xy(2),'r')
        
        line([pawBackCenter_xy(1),indexProx_xy(1)],[pawBackCenter_xy(2),indexProx_xy(2)],'color','r')
        line([pawBackCenter_xy(1),middleProx_xy(1)],[pawBackCenter_xy(2),middleProx_xy(2)],'color','r')
        line([pawBackCenter_xy(1),ringProx_xy(1)],[pawBackCenter_xy(2),ringProx_xy(2)],'color','r')
        line([pawBackCenter_xy(1),pinkyProx_xy(1)],[pawBackCenter_xy(2),pinkyProx_xy(2)],'color','r')
        
        scatter(indexMid_xy(1), indexMid_xy(2),'b')
        scatter(middleMid_xy(1), middleMid_xy(2),'b')
        scatter(ringMid_xy(1), ringMid_xy(2),'b')
        scatter(pinkyMid_xy(1), pinkyMid_xy(2),'b')
        
        
        line([indexMid_xy(1),indexProx_xy(1)],[indexMid_xy(2),indexProx_xy(2)],'color','b')
        line([middleMid_xy(1),middleProx_xy(1)],[middleMid_xy(2),middleProx_xy(2)],'color','b')
        line([ringMid_xy(1),ringProx_xy(1)],[ringMid_xy(2),ringProx_xy(2)],'color','b')
        line([pinkyMid_xy(1),pinkyProx_xy(1)],[pinkyMid_xy(2),pinkyProx_xy(2)],'color','b')
        
        scatter(indexDist_xy(1), indexDist_xy(2),'g')
        scatter(middleDist_xy(1), middleDist_xy(2),'g')
        scatter(ringDist_xy(1), ringDist_xy(2),'g')
        scatter(pinkyDist_xy(1), pinkyDist_xy(2),'g')
        
        line([indexMid_xy(1),indexDist_xy(1)],[indexMid_xy(2),indexDist_xy(2)],'color','g')
        line([middleMid_xy(1),middleDist_xy(1)],[middleMid_xy(2),middleDist_xy(2)],'color','g')
        line([ringMid_xy(1),ringDist_xy(1)],[ringMid_xy(2),ringDist_xy(2)],'color','g')
        line([pinkyMid_xy(1),pinkyDist_xy(1)],[pinkyMid_xy(2),pinkyDist_xy(2)],'color','g')


        
        end
    end
end


%% Normalize Data 
function   [indexLeft, indexCenter, indexRight,middleLeft, middleCenter, middleRight,ringLeft, ringCenter, ringRight, pinkyLeft, pinkyCenter, pinkyRight,pelletLeft, pelletCenter, pelletRight] = normalizeData(pellet, pawBack, index, middle,  ring, pinky)
     for i= 1:5
            for j =1:3
            pelletCenter_xy{i,j} = cell2mat(pellet{i,j});
            pawBackCenter_xy{i,j} = cell2mat(pawBack{i,j});


            index_xy{i,j} = cell2mat(index{i,j});
            middle_xy{i,j} = cell2mat(middle{i,j});
            ring_xy{i,j} = cell2mat(ring{i,j});
            pinky_xy{i,j} = cell2mat(pinky{i,j});

        end
     end
             temp = cell2mat(pelletCenter_xy);
             pelletLeft(:,1)  = temp(:,1);
             pelletLeft(:,2) = temp(:,2);
             pelletCenter(:,1) = temp(:,3);
             pelletCenter(:,2) = temp(:,4);
             pelletRight(:,1) = temp(:,5);
             pelletRight(:,2) = temp(:,6);
             
%              temp = cell2mat(pawBackCenter_xy)
%              pawBackLeft(:,1)  = temp(:,1);
%              pawBackLeft(:,2) = temp(:,2);
%              pawBackCenter(:,1) = temp(:,3);
%              pawBackCenter(:,2) = temp(:,4);
%              pawBackRight(:,1) = temp(:,5);
%              pawBackRight(:,2) = temp(:,6);

    
%This a temporary fix for the point not exisiting the dataset
%              pawBackLeft(:,1)  = [];
%              pawBackLeft(:,2) = [];
%              pawBackCenter(:,1) = [];
%              pawBackCenter(:,2) = [];
%              pawBackRight(:,1) = [];
%              pawBackRight(:,2) = [];
     

      
     
             temp = cell2mat(ring_xy);
             ringLeft(:,1)  = temp(:,1);
             ringLeft(:,2) = temp(:,2);
             ringCenter(:,1) = temp(:,3);
             ringCenter(:,2) = temp(:,4);
             ringRight(:,1) = temp(:,5);
             ringRight(:,2) = temp(:,6);
            
                
             temp = cell2mat(middle_xy);
             middleLeft(:,1)  = temp(:,1);
             middleLeft(:,2) = temp(:,2);
             middleCenter(:,1) = temp(:,3);
             middleCenter(:,2) = temp(:,4);
             middleRight(:,1) = temp(:,5);
             middleRight(:,2) = temp(:,6);



             temp = cell2mat(index_xy);
             indexLeft(:,1)  = temp(:,1);
             indexLeft(:,2) = temp(:,2);
             indexCenter(:,1) = temp(:,3);
             indexCenter(:,2) = temp(:,4);
             indexRight(:,1) = temp(:,5);
             indexRight(:,2) = temp(:,6);



             temp = cell2mat(pinky_xy);
             pinkyLeft(:,1)  = temp(:,1);
             pinkyLeft(:,2) = temp(:,2);
             pinkyCenter(:,1) = temp(:,3);
             pinkyCenter(:,2) = temp(:,4);
             pinkyRight(:,1) = temp(:,5);
             pinkyRight(:,2) = temp(:,6);
 
end
 
%% This Function is for measuring the spread between the distal knucles of the index finger and pink
function [pawSpreadDistPILeft,pawSpreadDistPICenter,pawSpreadDistPIRight,pawSpreadDistMILeft,pawSpreadDistMICenter,pawSpreadDistMIRight,pawSpreadDistRILeft,pawSpreadDistRICenter,pawSpreadDistRIRight] = calc2DistancePawSpread(pinkyDistLeft, indexDistLeft, pinkyDistCenter, indexDistCenter, pinkyDistRight, indexDistRight, middleDistLeft, middleDistCenter, middleDistRight,ringDistLeft, ringDistCenter, ringDistRight)

     pawSpreadDistPILeft = [];
     pawSpreadDistPICenter = [];
     pawSpreadDistPIRight = [];
     
     
     pawSpreadDistMILeft = [];
     pawSpreadDistMICenter = [];
     pawSpreadDistMIRight = [];
  
     pawSpreadDistRILeft = [];
     pawSpreadDistRICenter = [];
     pawSpreadDistRIRight = [];
     
    %Measure the seperation between the pinky and the index finger 
    for i =1:5
        pawSpreadDistPILeft(i) = sqrt((pinkyDistLeft(i,1)-indexDistLeft(i,1))^2+(pinkyDistLeft(i,2)-indexDistLeft(i,2))^2);
        pawSpreadDistPICenter(i) = sqrt((pinkyDistCenter(i,1)-indexDistCenter(i,1))^2+(pinkyDistCenter(i,2)-indexDistCenter(i,2))^2);    
        pawSpreadDistPIRight(i) = sqrt((pinkyDistRight(i,1)-indexDistRight(i,1))^2+(pinkyDistRight(i,2)-indexDistRight(i,2))^2);
    end
    
    %Measure the seperation between the middle and the index finger 
    for i =1:5
        pawSpreadDistMILeft(i) = sqrt((middleDistLeft(i,1)-indexDistLeft(i,1))^2+(middleDistLeft(i,2)-indexDistLeft(i,2))^2);
        pawSpreadDistMICenter(i) = sqrt((middleDistCenter(i,1)-indexDistCenter(i,1))^2+(middleDistCenter(i,2)-indexDistCenter(i,2))^2);    
        pawSpreadDistMIRight(i) = sqrt((middleDistRight(i,1)-indexDistRight(i,1))^2+(middleDistRight(i,2)-indexDistRight(i,2))^2);
    end
    
    %Measure the seperation between the ring and the index finger 
    for i =1:5
        pawSpreadDistRILeft(i) = sqrt((ringDistLeft(i,1)-indexDistLeft(i,1))^2+(ringDistLeft(i,2)-indexDistLeft(i,2))^2);
        pawSpreadDistRICenter(i) = sqrt((ringDistCenter(i,1)-indexDistCenter(i,1))^2+(ringDistCenter(i,2)-indexDistCenter(i,2))^2);    
        pawSpreadDistRIRight(i) = sqrt((ringDistRight(i,1)-indexDistRight(i,1))^2+(ringDistRight(i,2)-indexDistRight(i,2))^2);
    end
    
end

%% Establish 3D coordinate in space
function [currentMarker3]= create3Dpoints (currentMarkerLeft, currentMarkerCenter, currentMarkerRight) 
   
       for i =1:5
        
        tf1=isnan(currentMarkerCenter(i,1));
        tf2= isnan(currentMarkerCenter(i,2));
        tf3= isnan(currentMarkerLeft(i,1));
        tf4 = isnan(currentMarkerRight(i,1));
      
        
        
        if     (tf1 == 0 && tf2 == 0 && tf3 == 0)   
                currentMarker3{i} = [currentMarkerCenter(i,1), currentMarkerCenter(i,2), currentMarkerLeft(i,1)];  
        elseif (tf1 == 0 && tf2 == 0 && tf4 == 0)    
                currentMarker3{i} = [currentMarkerCenter(i,1), currentMarkerCenter(i,2), currentMarkerRight(i,1)];  
        end
        
        
      end
   
 end


%% Calc 3D paw spread in space
function PI3DistanceSeperation = calc3DistancePawSpread (allPinkyDist3 , allIndexDist3)

    for i = 1:length(allPinkyDist3(:,1))
        for j = 1:5
            currentPinky = cell2mat(allPinkyDist3(i,j));
            currentIndex = cell2mat(allIndexDist3(i,j));
            
           tfP =  sum(size(currentPinky) == [0 0]);
           tfI =  sum(size(currentIndex) == [0 0]);
            
            
           if (tfP == 0 && tfI == 0)              
               PI3DistanceSeperation(i,j) = sqrt((currentPinky(:,1)-currentIndex(:,1))^2+ (currentPinky(:,2)-currentIndex(:,2))^2 +(currentPinky(:,3)-currentIndex(:,3))^2);
           end
         end
    end
    
  

end


%% Plot paw center distance changes
function plotCenterDistance(indexDistCenter,middleDistCenter,ringDistCenter,pinkyDistCenter)
    for i=1:5
        figure(1) 
        hold on
        scatter(indexDistCenter(i,1), indexDistCenter(i,2),'r','X')
        scatter(middleDistCenter(i,1), middleDistCenter(i,2),'b','X')
        scatter(ringDistCenter(i,1),ringDistCenter(i,2),'g','X')
        scatter(pinkyDistCenter(i,1),pinkyDistCenter(i,1),'m','X')
    end
end


%% Plot the Paw distances  over time
function plot2DistancePawSpread(allPawSpreadDistMICenter,allPawSpreadDistRICenter, allPawSpreadDistPICenter)
   
    for i =1:5
        avgPawSpreadDistMI(i) = nanmean(allPawSpreadDistMICenter(:,i));
        stdPawSpreadDistMI(i) = std(allPawSpreadDistMICenter(:,i));
    end
    
    for i =1:5
        avgPawSpreadDistRI(i) = nanmean(allPawSpreadDistRICenter(:,i));
        stdPawSpreadDistRI(i) = std(allPawSpreadDistRICenter(:,i));
    end
    
    for i =1:5
        avgPawSpreadDistPI(i) = nanmean(allPawSpreadDistPICenter(:,i));
        stdPawSpreadDistPI(i) = std(allPawSpreadDistPICenter(:,i));
    end
    
    frames = 1:5;
    
%     figure(2)
%     hold on
%     errorbar(frames,avgPawSpreadDistMI,stdPawSpreadDistMI,'r')
%     errorbar(frames,avgPawSpreadDistRI,stdPawSpreadDistRI,'g')
%     errorbar(frames,avgPawSpreadDistPI,stdPawSpreadDistPI,'b')
end


%% Plot paw 3d seperation changes
function  plot3DistancePawSpread (PI3DistanceSeperation)
%     figure(3)
%     for i=1:length(PI3DistanceSeperation(:,1))
%         frames = 1:5;
%         hold on
%         plot(frames,PI3DistanceSeperation(i,:))
%     end      
% 
%   
end

%% Calculate the change in position for an individual digit
function [dispIndex,dispMiddle,dispRing,dispPinky] = calculatePositionChange(indexDistCenter)%, middleDistCenter, ringDistCenter, pinkyDistCenter) %This should return a matrix for each of the individual digits showing the change in position in the given digits

dispIndex = [];
dispMiddle = [];
dispRing = [];
dispPinky = [];

    for i = 1:length(indexDistCenter)
        currentIndexDistCenter = cell2mat(indexDistCenter(:,i));
    %     currentMiddleDistCenter = cell2mat(middleDistCenter(:,i)); 
    %     currentRingDistCenter = cell2mat(ringDistCenter(:,i)) ;
    %     currentPinkyDistCenter = cell2mat(ringDistCenter(:,i)) ;

        for j=1:4 %There are 5 frames that are taken into account and caluclates 4 distance changes
            currentDispIndexDistCenter = sqrt((currentIndexDistCenter((j+1),1)-currentIndexDistCenter(j,1))^2 + (currentIndexDistCenter((j+1),2)-currentIndexDistCenter(j,2))^2 );
            dispIndex(i,j) = currentDispIndexDistCenter;
        end
    end
end


%% Plot the distal points in 3d space
function  plot3DModelofPaw (allIndexMid3,allMiddleMid3,allRingMid3,allPinkyMid3,allIndexProx3,allMiddleProx3,allRingProx3,allPinkyProx3,allIndexDist3,allMiddleDist3,allRingDist3,allPinkyDist3)
    
    for i =1%:length(allIndexDist3(:,1)) %This reprsents the number of trials in given day
       for j = 1:5 %This represents the number of frames
           
            %Truefalse checks to see if digit points exist 
            IP = 0;
            IM = 0;
            ID = 0;
            
            MP = 0;
            MM = 0;
            MD = 0;
            
            RP = 0;
            RM = 0;
            RD = 0;
            
            PP = 0;
            PM = 0;
            PD = 0;
            
            
            
            
            currentIndexProx = cell2mat(allIndexProx3(i,j));
            currentMiddleProx = cell2mat(allMiddleProx3(i,j));
            currentRingProx = cell2mat(allRingProx3(i,j));
            currentPinkyProx = cell2mat(allPinkyProx3(i,j));

           
            currentIndexMid = cell2mat(allIndexMid3(i,j));
            currentMiddleMid = cell2mat(allMiddleMid3(i,j));
            currentRingMid = cell2mat(allRingMid3(i,j));
            currentPinkyMid = cell2mat(allPinkyMid3(i,j));

                      
            currentIndexDist = cell2mat(allIndexDist3(i,j));
            currentMiddleDist = cell2mat(allMiddleDist3(i,j));
            currentRingDist = cell2mat(allRingDist3(i,j));
            currentPinkyDist = cell2mat(allPinkyDist3(i,j));

     
            figure(j)
            hold on
                
            
                %Index Finger
                if size(currentIndexProx) == [1,3] 
                   IP = 1;
                   scatter3(currentIndexProx(1,1),currentIndexProx(1,2),currentIndexProx(1,3),'r');
                end
                if size(currentIndexMid) == [1,3]  
                    IM =1;
                   scatter3(currentIndexMid(1,1),currentIndexMid(1,2),currentIndexMid(1,3),'r');
                end
                if size(currentIndexDist) == [1,3]  
                    ID = 1;
                   scatter3(currentIndexDist(1,1),currentIndexDist(1,2),currentIndexDist(1,3),'r');
                end
                
                if (IP == 1 && IM ==1)
                    x = [currentIndexProx(1,1),currentIndexMid(1,1)];
                    y = [currentIndexProx(1,2),currentIndexMid(1,2)];
                    z = [currentIndexProx(1,3),currentIndexMid(1,3)];
                    line(x,y,z,'color','r')
                end
                
                 
                if (IM == 1 && ID ==1)
                    x = [currentIndexDist(1,1),currentIndexMid(1,1)];
                    y = [currentIndexDist(1,2),currentIndexMid(1,2)];
                    z = [currentIndexDist(1,3),currentIndexMid(1,3)];
                    line(x,y,z,'color','r')
                end
                
                
                %Middle
                if size(currentMiddleProx) == [1,3] 
                    MP=1;
                    scatter3(currentMiddleProx(1,1),currentMiddleProx(1,2),currentMiddleProx(1,3),'b');
                end
                if size(currentMiddleMid) == [1,3] 
                    MM = 1;
                    scatter3(currentMiddleMid(1,1),currentMiddleMid(1,2),currentMiddleMid(1,3),'b');
                end
 
                if size(currentMiddleDist) == [1,3] 
                    MD =1;
                    scatter3(currentMiddleDist(1,1),currentMiddleDist(1,2),currentMiddleDist(1,3),'b');
                end
                
                
                if (MP == 1 && MM ==1)
                    x = [currentMiddleProx(1,1),currentMiddleMid(1,1)];
                    y = [currentMiddleProx(1,2),currentMiddleMid(1,2)];
                    z = [currentMiddleProx(1,3),currentMiddleMid(1,3)];
                    line(x,y,z,'color','b')
                end
                
                 
                if (MM == 1 && MD ==1)
                    x = [currentMiddleDist(1,1),currentMiddleMid(1,1)];
                    y = [currentMiddleDist(1,2),currentMiddleMid(1,2)];
                    z = [currentMiddleDist(1,3),currentMiddleMid(1,3)];
                    line(x,y,z,'color','b')
                end

                
                
                
               
                
                
 
        
                %Ring
                if size(currentRingProx) == [1,3] 
                    RP =1;
                    scatter3(currentRingProx(1,1), currentRingProx(1,2),currentRingProx(1,3),'g');
                end
                if size(currentRingMid) == [1,3] 
                    RM = 1;
                    scatter3(currentRingMid(1,1), currentRingMid(1,2),currentRingMid(1,3),'g');
                end
                if size(currentRingDist) == [1,3]
                    RD =1;
                    scatter3(currentRingDist(1,1), currentRingDist(1,2),currentRingDist(1,3),'g');
                end
                
               if (RP == 1 && RM ==1)
                    x = [currentRingProx(1,1),currentRingMid(1,1)];
                    y = [currentRingProx(1,2),currentRingMid(1,2)];
                    z = [currentRingProx(1,3),currentRingMid(1,3)];
                    line(x,y,z,'color','g')
                end
                
                 
                if (RM == 1 && RD ==1)
                    x = [currentRingDist(1,1),currentRingMid(1,1)];
                    y = [currentRingDist(1,2),currentRingMid(1,2)];
                    z = [currentRingDist(1,3),currentRingMid(1,3)];
                    line(x,y,z,'color','g')
                end

              
                
                
               
 
                
                %Pinky
                if size(currentPinkyProx) == [1,3]  
                    PP = 1;
                    scatter3(currentPinkyProx(1,1), currentPinkyProx(1,2), currentPinkyProx(1,3),'k');
                end
                if size(currentPinkyMid) == [1,3]  
                    PM =1;
                    scatter3(currentPinkyMid(1,1), currentPinkyMid(1,2), currentPinkyMid(1,3),'k');
                end      
                if size(currentPinkyDist) == [1,3]  
                    PD = 1;
                    scatter3(currentPinkyDist(1,1), currentPinkyDist(1,2), currentPinkyDist(1,3),'k');
                end
                
                if (PP == 1 && PM ==1)
                    x = [currentPinkyProx(1,1),currentPinkyMid(1,1)];
                    y = [currentPinkyProx(1,2),currentPinkyMid(1,2)];
                    z = [currentPinkyProx(1,3),currentPinkyMid(1,3)];
                    line(x,y,z,'color','k')
                end
                
                 
                if (PM == 1 && PD ==1)
                    x = [currentPinkyDist(1,1),currentPinkyMid(1,1)];
                    y = [currentPinkyDist(1,2),currentPinkyMid(1,2)];
                    z = [currentPinkyDist(1,3),currentPinkyMid(1,3)];
                    line(x,y,z,'color','k')
                end

                
                
            
       end
    end

end

%% Calculate the displacment in 3D 
function [currentMarkerDisp3D] = calculatePositionChange3D(currentMarker3D)
currentMarkerDisp3D= [];

    for i = 1:length(currentMarker3D(:,1))
        for k =1:4 %number of frames
                
            
                currentFrame = cell2mat(currentMarker3D(i,k));
                nextFrame = cell2mat(currentMarker3D(i,k+1));
                
                tf1 = sum(currentFrame) == 0 ;
                tf2 = sum(nextFrame) == 0;
                
                if (tf1 == 0 && tf2 ==0)
                currentDispIndex = sqrt((currentFrame(1)-nextFrame(1))^2+(currentFrame(2)-nextFrame(2))^2+(currentFrame(3)-nextFrame(3))^2) ;
                currentMarkerDisp3D(i,k) = currentDispIndex;
                end
        end
        
    end
end



%% Calculate the Jerk (aka the 4th derivative of the position vector
function [Velocity, Acceleration, Jerk] = KinematicCalc (digit3d)

    ts = 1/300;
    frames = 0:8:40;
    time = frames*ts;

    Velocity = [];
    Acceleration = [];
    Jerk = [];

    for i = 1:length(digit3d(:,1))
        for j = 1:length(digit3d(1,:))
            Velocity(i,j) = digit3d(i,j)/ts ;%4 frames x by number of reaches 
        end
    end
    
    for j = 1:length(Velocity(:,1))
        for i = 1:length(Velocity(1,:))-1%Number of colums remains constant
                Acceleration (j,i) = (Velocity(j,i+1)-Velocity(j,i))/ts  ;  
        end
    end
    
     for j = 1:length(Acceleration(:,1))
        for i = 1:length(Acceleration(1,:))-1%Number of colums remains constant
                Jerk(j,i) = (Acceleration(j,i+1)-Acceleration(j,i))/ts;   
        end
    end

end


%% Calculate the distance of the distal digits to the pellet cetner at is orginal spot
function  [avgDistanceIndexDisttoPellet, avgDistanceMiddleDisttoPellet, avgDistanceRingDisttoPellet,avgDistancePinkyDisttoPellet] = calcDistancetoPellet(allIndexDist3,allMiddleDist3,allRingDist3,allPinkyDist3,allPellet3)
 
   allPelletStartPos = allPellet3(:,1);
   
   distanceIndexDisttoPellet = [];
   distanceMiddleDisttoPellet = [];   
   distanceRingDisttoPellet = []; 
   distancePinkyDisttoPellet = [];
    
    

    for i = 1:length(allIndexDist3(:,1))
        for j = 1:5
            
            
            currentPellet = cell2mat(allPelletStartPos(i));
            currentIndex = cell2mat(allIndexDist3(i,j));
            currentMiddle = cell2mat(allMiddleDist3(i,j));
            currentRing = cell2mat(allRingDist3(i,j));
            currentPinky = cell2mat(allPinkyDist3(i,j));
           
            if size(currentIndex) == [1,3]  
                distanceIndexDisttoPellet(i,j) = sqrt((currentPellet(1,1)-currentIndex(1,1))^2+(currentPellet(1,2)-currentIndex(1,2))^2+(currentPellet(1,3)-currentIndex(1,3))^2);
            end
            
            
            if size(currentMiddle) == [1,3]  
                distanceMiddleDisttoPellet(i,j) = sqrt((currentPellet(1,1)-currentMiddle(1,1))^2+(currentPellet(1,2)-currentMiddle(1,2))^2+(currentPellet(1,3)-currentMiddle(1,3))^2);
            end
            
            if size(currentRing) == [1,3]  
                distanceRingDisttoPellet(i,j) = sqrt((currentPellet(1,1)-currentRing(1,1))^2+(currentPellet(1,2)-currentRing(1,2))^2+(currentPellet(1,3)-currentRing(1,3))^2);
            end
            
            if size(currentPinky) == [1,3]  
                distancePinkyDisttoPellet(i,j) = sqrt((currentPellet(1,1)-currentPinky(1,1))^2+(currentPellet(1,2)-currentPinky(1,2))^2+(currentPellet(1,3)-currentPinky(1,3))^2);
            end
         end
    end
    
 %This loop will take the averages of the distal point to pellets over 5 frames
    for i = 1:5
        avgDistanceIndexDisttoPellet(i) = sum(distanceIndexDisttoPellet(:,i))./ sum(distanceIndexDisttoPellet(:,i)~=0);
        avgDistanceMiddleDisttoPellet(i) = sum(distanceMiddleDisttoPellet(:,i))./ sum(distanceMiddleDisttoPellet(:,i)~=0);
        avgDistanceRingDisttoPellet(i) = sum(distanceRingDisttoPellet(:,i))./ sum(distanceRingDisttoPellet(:,i)~=0);
        avgDistancePinkyDisttoPellet(i) = sum(distancePinkyDisttoPellet(:,i))./ sum(distancePinkyDisttoPellet(:,i)~=0);
    end
    
end



%% Calculate the change in paw angle
function PawAngle(currentMaker3d)




end

