%%
numTrials = length(reachData);

for iTrial = 1 : numTrials
    
    num_reaches = length(reachData(iTrial).reachEnds);
    
    for i_reach = num_reaches
        
        if any(reachData(iTrial).dig2_trajectory{i_reach}(:,3) > 20)
            
            iTrial
            reachData(iTrial).trialNumbers
            
        end
    end
end