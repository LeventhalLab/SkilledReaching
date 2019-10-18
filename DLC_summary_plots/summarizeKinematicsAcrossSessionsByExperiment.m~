function exptSummary = summarizeKinematicsAcrossSessionsByExperiment(summary)

% collect the number of trials for each 

num_rats = length(summary);
num_sessions = size(summary(1).sessions_analyzed,1);

exptSummary.num_trials = zeros(num_sessions, num_rats);
exptSummary.firstReachSuccess = zeros(num_sessions, num_rats);
exptSummary.anyReachSuccess = zeros(num_sessions, num_rats);
exptSummary.mean_num_reaches = zeros(num_sessions, num_rats);
exptSummary.mean_pd_v = zeros(num_sessions, num_rats);
exptSummary.mean_orientations = zeros(num_sessions, num_rats);
exptSummary.MRL = zeros(num_sessions, num_rats);
exptSummary.mean_aperture = zeros(num_sessions, num_rats);
exptSummary.std_aperture = zeros(num_sessions, num_rats);

exptSummary.mean_pd_endPt = zeros(num_rats,num_sessions,3);
exptSummary.mean_dig2_endPt = zeros(num_rats,num_sessions,3);

for i_rat = 1 : num_rats
    try
    exptSummary.num_trials(:,i_rat) = summary(i_rat).ratSummary.num_trials(:,1);
    catch
        keyboard
    end
    exptSummary.firstReachSuccess(:,i_rat) = summary(i_rat).ratSummary.outcomePercent(:,2);
    exptSummary.anyReachSuccess(:,i_rat) = summary(i_rat).ratSummary.outcomePercent(:,3) + exptSummary.firstReachSuccess(:,i_rat);
    exptSummary.mean_num_reaches(:,i_rat) = summary(i_rat).ratSummary.mean_num_reaches(:,1);
    exptSummary.mean_pd_v(:,i_rat) = summary(i_rat).ratSummary.mean_pd_v(:,1);
    exptSummary.mean_orientations(:,i_rat) = summary(i_rat).ratSummary.mean_orientations(:,1);
    exptSummary.MRL(:,i_rat) = summary(i_rat).ratSummary.MRL(:,1);
    exptSummary.mean_aperture(:,i_rat) = summary(i_rat).ratSummary.mean_aperture(:,1);
    exptSummary.std_aperture(:,i_rat) = summary(i_rat).ratSummary.std_aperture(:,1);
    
    exptSummary.pawPref(i_rat) = summary(i_rat).thisRatInfo.pawPref;
    
    temp_pd_coords = squeeze(summary(i_rat).ratSummary.mean_pd_endPt(:,1,:));
    temp_dig2_coords = squeeze(summary(i_rat).ratSummary.mean_dig2_endPt(:,1,:));
    if exptSummary.pawPref(i_rat) == 'left'
        temp_pd_coords(:,1) = -temp_pd_coords(:,1);
        temp_dig2_coords(:,1) = -temp_dig2_coords(:,1);
    end
    exptSummary.mean_pd_endPt(i_rat,:,:) = temp_pd_coords;
    exptSummary.mean_dig2_endPt(i_rat,:,:) = temp_dig2_coords;
    
    exptSummary.pawPref(i_rat) = summary(i_rat).thisRatInfo.pawPref;
end

end
    