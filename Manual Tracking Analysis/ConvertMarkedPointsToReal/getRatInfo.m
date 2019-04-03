function [sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
%
% INPUTS:
%   RatData - 
%
% OUTPUTS:
%   

RatName = [RatData.VideoFiles.name];
RatID = strcat(RatName(4),RatName(5));
Scores=[RatData.VideoFiles.Score]';

Scores(isnan(Scores)) = [];

    counter1 = 0;
    counter47 = 0; 
    
    for  i =1:length(Scores)
    
        if Scores(i) == 1
            counter1 = counter1 +1;
        end
        
        if Scores(i) ==  7
            counter47 = counter47+1; 
        end
    end

    
    totalNumReaches  = 0;
    totalNumReaches = length(Scores);
    
    sucessRate = counter1/totalNumReaches*100;
    failureRate = counter47 / totalNumReaches*100;

end