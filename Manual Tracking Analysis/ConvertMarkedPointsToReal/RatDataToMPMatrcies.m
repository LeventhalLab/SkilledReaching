%Titus John
%Leventhal Lab, University of Michigan 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This scripts takes the rat data and creates the direct and the indirect
%matricies x1 and x2 respectively that are then fed into
%convertMarkedPointstoRealWorld script. 

function  [X1,X2] = RatDataToMPMatrcies(RatData,score)


    [allPawData] = ReadPawDataFromRatData(RatData,score);
    
    [allPawDataFiltered] = KnockoutCoordinates(allPawData); 
    
    
    
    
    counter = 1;
     for i = 1:length(allPawDataFiltered) 
            pawPointsData = allPawDataFiltered{1,i};
            if size(pawPointsData) ~= [0,0]
                [allLeft{counter},allCenter{counter},allRight{counter}] = SplitPawData(pawPointsData);
                counter = counter + 1;
            end
    end

    
   for i =1:length(allLeft)
       trialLeft = allLeft{1,i};
       trialCenter = allCenter{1,i};
       trialRight = allRight{1,i};
       
       for j = 1:5
            frameLeft = cell2mat(trialLeft(1,j));
            frameCenter = cell2mat(trialCenter(1,j)); 
            frameRight = cell2mat(trialRight(1,j));
            
            
            counterLeft = 1;
            counterRight =1;
            
            x1= [];
            x2 = [];
            
            for k = 1:16
                
                   
                TFC = isnan(frameCenter(k,1)); 
                TFL = isnan(frameLeft(k,1));
                TFR = isnan(frameRight(k,1));

                if TFC  == 0
                    if TFL == 0
                        
                        
                        x1(counterLeft,:) = frameCenter(k,:);
                        x2(counterLeft,:) = frameLeft(k,:);
                        counterLeft = counterLeft + 1;
                        
                        X1{i,j} = x1;
                        X2{i,j} = x2;
                    end
                end
            end
       end
   end
    
    
end


function [left,center,right] = SplitPawData(pawPointsData)
  overallCounter = 1;
  

  
    for i=1:5
        for j=1:3
            
              counterLeft = 1;
              counterCenter = 1;
              counterRight = 1;
            
            
            for k=overallCounter:(overallCounter+15) 
                if overallCounter<241
                    
                       if j == 1
                            frameLeft(:,counterLeft) =  [pawPointsData(k,7),pawPointsData(k,8)];
                            counterLeft = counterLeft + 1;
                       end
                       
                       if j == 2
                            frameCenter(:,counterCenter) = [pawPointsData(k,7),pawPointsData(k,8)];
                            counterCenter = counterCenter+ 1;
                       end
                       
                       if j ==3 
                            frameRight(:,counterRight) = [pawPointsData(k,7),pawPointsData(k,8)];
                            counterRight = counterRight +1;
                       end
                       
                       overallCounter = overallCounter + 1;
                end
            end
        end
        
        trialLeft{i} = frameLeft';
        trialCenter{i} = frameCenter';
        trialRight{i} = frameRight';
        
    end
    
    
    left = trialLeft;
    center = trialCenter;
    right = trialRight;

end


function [allPawData] = ReadPawDataFromRatData(RatData,score) 
    allPawData = [];
    filteredPawData = [];
    Scores=[RatData.VideoFiles.Score]';

    j= 1;
    for i=1:length(Scores)
        if Scores(i) == score 
            tempAllPawData = RatData.VideoFiles(i).Paw_Points_Tracking_Data;
            
           
          
            counter = 1; %This is the counter that represents the actual length of filled data
            
            
            
            if size(tempAllPawData) ~= [0,0]
                for k =1:length(tempAllPawData)



                    if isnumeric(cell2mat(tempAllPawData(k,7)))  


                        filteredPawData(counter,7) = cell2mat(tempAllPawData(k,7));
                        filteredPawData(counter,8) = cell2mat(tempAllPawData(k,8));
                        counter = counter + 1;
                    end
                end         
                allPawData{j}= filteredPawData; 
                j = j+1;
            end
        end
    end
end


function [allPawDataFiltered] = KnockoutCoordinates(allPawData) 

    
    for i = 1:length(allPawData)
         pawPointsData = allPawData{1,i};  
         
             for j =1:length(pawPointsData)
                if mod(j,16) == 7 || mod(j,16) == 10 || mod(j,16) == 13 || mod(j,16) == 0 
               %if  mod(j,16) == 1
                    pawPointsDataFilt(j,7) =   pawPointsData(j,7);
                    pawPointsDataFilt(j,8) =   pawPointsData(j,8);

                else
                    pawPointsDataFilt(j,7) = NaN;
                    pawPointsDataFilt(j,8) = NaN;
                end
             end
        
         
        allPawDataFiltered{i}  = pawPointsDataFilt ;
    end
end