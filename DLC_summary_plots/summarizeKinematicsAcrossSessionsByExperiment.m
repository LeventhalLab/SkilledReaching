function exptSummary = summarizeKinematicsAcrossSessionsByExperiment(summary)

% collect the number of trials for each 

num_rats = length(summary);
num_sessions = size(summary(1).ratSummary.sessions_analyzed,1);

exptSummary.num_trials = zeros(num_sessions, num_rats);
exptSummary.firstReachSuccess = zeros(num_sessions, num_rats);
exptSummary.anyReachSuccess = zeros(num_sessions, num_rats);
exptSummary.mean_num_reaches = zeros(num_sessions, num_rats);
exptSummary.mean_pd_v = zeros(num_sessions, num_rats);
exptSummary.mean_end_orientations = zeros(num_sessions, num_rats);
exptSummary.end_MRL = zeros(num_sessions, num_rats);
exptSummary.mean_end_aperture = zeros(num_sessions, num_rats);
exptSummary.std_end_aperture = zeros(num_sessions, num_rats);

exptSummary.mean_pd_endPt = zeros(num_rats,num_sessions,3);
exptSummary.mean_dig2_endPt = zeros(num_rats,num_sessions,3);

num_z_points = size(summary(1).ratSummary.mean_aperture_traj,2);
exptSummary.mean_aperture_traj = NaN(num_rats,num_sessions,num_z_points);
exptSummary.std_aperture_traj = NaN(num_rats,num_sessions,num_z_points);
exptSummary.sem_aperture_traj = NaN(num_rats,num_sessions,num_z_points);
exptSummary.mean_orientation_traj = NaN(num_rats,num_sessions,num_z_points);
exptSummary.MRL_traj = NaN(num_rats,num_sessions,num_z_points);

for i_rat = 1 : num_rats
    
    exptSummary.pawPref(i_rat) = summary(i_rat).thisRatInfo.pawPref;
    
    try
    exptSummary.num_trials(:,i_rat) = summary(i_rat).ratSummary.num_trials(:,1);
    catch
        keyboard
    end
    
    exptSummary.firstReachSuccess(:,i_rat) = summary(i_rat).ratSummary.outcomePercent(:,2);
    exptSummary.anyReachSuccess(:,i_rat) = summary(i_rat).ratSummary.outcomePercent(:,3) + exptSummary.firstReachSuccess(:,i_rat);
    exptSummary.mean_num_reaches(:,i_rat) = summary(i_rat).ratSummary.mean_num_reaches(:,1);
    exptSummary.mean_pd_v(:,i_rat) = summary(i_rat).ratSummary.mean_pd_v(:,1);
    exptSummary.end_MRL(:,i_rat) = summary(i_rat).ratSummary.end_MRL(:,1);
    exptSummary.mean_end_aperture(:,i_rat) = summary(i_rat).ratSummary.mean_end_aperture(:,1);
    exptSummary.std_end_aperture(:,i_rat) = summary(i_rat).ratSummary.std_end_aperture(:,1);
    
    temp_pd_coords = squeeze(summary(i_rat).ratSummary.mean_pd_endPt(:,1,:));
    temp_dig2_coords = squeeze(summary(i_rat).ratSummary.mean_dig_endPts(:,1,2,:));
    if exptSummary.pawPref(i_rat) == 'left'
        temp_pd_coords(:,1) = -temp_pd_coords(:,1);
        temp_dig2_coords(:,1) = -temp_dig2_coords(:,1);
    end
    exptSummary.mean_pd_endPt(i_rat,:,:) = temp_pd_coords;
    exptSummary.mean_dig2_endPt(i_rat,:,:) = temp_dig2_coords;
    
    exptSummary.pawPref(i_rat) = summary(i_rat).thisRatInfo.pawPref;
    
    % mean apertures and orientations as a function of z
    exptSummary.mean_aperture_traj(i_rat,:,:) = summary(i_rat).ratSummary.mean_aperture_traj;
    exptSummary.std_aperture_traj(i_rat,:,:) = summary(i_rat).ratSummary.std_aperture_traj;
    exptSummary.sem_aperture_traj(i_rat,:,:) = summary(i_rat).ratSummary.sem_aperture_traj;
    
    if exptSummary.pawPref(i_rat) == 'left'
        exptSummary.mean_orientation_traj(i_rat,:,:) = pi - summary(i_rat).ratSummary.mean_orientation_traj;
        exptSummary.mean_end_orientations(:,i_rat) = pi - summary(i_rat).ratSummary.mean_end_orientations(:,1);
    else
        exptSummary.mean_orientation_traj(i_rat,:,:) = summary(i_rat).ratSummary.mean_orientation_traj;
        exptSummary.mean_end_orientations(:,i_rat) = summary(i_rat).ratSummary.mean_end_orientations(:,1);
    end
    exptSummary.MRL_traj(i_rat,:,:) = summary(i_rat).ratSummary.MRL_traj;
    
    exptSummary.z_interp_digits = summary(i_rat).ratSummary.z_interp_digits;
    
end

end
    