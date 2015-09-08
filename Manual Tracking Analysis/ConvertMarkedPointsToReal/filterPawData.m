function allPawDataFiltered = filterPawData(RatData)
 for i = 1:length(RatData.VideoFiles)
     
 end
end


 function [allPawDataFiltered] = KnockoutCoordinates(RatData) 
    for i = 1:length(allPawData)
         pawPointsData = RatData.VideoFiles(i).Paw_Points_Tracking_Data;
         pawPointsData = allPawData{1,i};
         
         counter = 1;
         
         for j =1:length(pawPointsData)
            if pawPointsData{j,1}>1
                pawPointsDataFilt(:,counter) = pawPointsData(:,j);
                counter = counter + 1;
            end
         end
         
        allPawDataFiltered{i}  = pawPointsDataFilt ;
    end
end
    