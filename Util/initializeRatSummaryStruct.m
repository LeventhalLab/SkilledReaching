function ratSummary = initializeRatSummaryStruct(ratID,outcomeCategories,outcomeNames,sessions_analyzed,thisRatInfo,z_interp_digits)

% calculate the following kinematic parameters:
% number of trials
% number of reaches per trial
% success rate
% 1. max velocity, by reach type
% 2. average trajectory for a session, by reach time
% 3. deviation from that trajectory for a session
% 4. distance between trajectories
% 5. closest distance paw to pellet
% 6. minimum z, by type
% 7. number of reaches, by type
% aperture of reach orientation at reach end
% orientation of reach orientation at reach end
% MRL of reach orientation at reach end

ratSummary.ratID = ratID;
num_outcome_categories = length(outcomeCategories);

numSessions_to_analyze = size(sessions_analyzed,1);

% figure out which type of experiment this was (stim during, between,
% control, etc.)
opsin_prefix = lower(char(thisRatInfo.Virus));
switch thisRatInfo.laserTiming
    case 'During Reach'
        timing_suffix = 'during';
    case 'Between Reach'
        timing_suffix = 'between';
end
ratSummary.exptType = [opsin_prefix '_' timing_suffix];

ratSummary.sessions_analyzed = sessions_analyzed;

ratSummary.num_trials = NaN(numSessions_to_analyze,num_outcome_categories);
ratSummary.outcomePercent = NaN(numSessions_to_analyze,num_outcome_categories);
ratSummary.mean_num_reaches = NaN(numSessions_to_analyze,num_outcome_categories);
ratSummary.std_num_reaches = NaN(numSessions_to_analyze,num_outcome_categories);

ratSummary.mean_pd_v = NaN(numSessions_to_analyze,num_outcome_categories);
ratSummary.std_pd_v = NaN(numSessions_to_analyze,num_outcome_categories);

ratSummary.mean_pd_endPt = NaN(numSessions_to_analyze,num_outcome_categories,3);
ratSummary.mean_dig2_endPt = NaN(numSessions_to_analyze,num_outcome_categories,3);

ratSummary.cov_pd_endPts = NaN(numSessions_to_analyze,num_outcome_categories,3,3);
ratSummary.cov_dig2_endPts = NaN(numSessions_to_analyze,num_outcome_categories,3,3);

ratSummary.mean_pd_v = NaN(numSessions_to_analyze,num_outcome_categories);
ratSummary.std_pd_v = NaN(numSessions_to_analyze,num_outcome_categories);

ratSummary.mean_end_orientations = NaN(numSessions_to_analyze,num_outcome_categories);
ratSummary.end_MRL = NaN(numSessions_to_analyze,num_outcome_categories);

ratSummary.mean_end_aperture = NaN(numSessions_to_analyze,num_outcome_categories);
ratSummary.std_end_aperture = NaN(numSessions_to_analyze,num_outcome_categories);

ratSummary.aperture_traj = [];%NaN(numSessions_to_analyze,num_outcome_categories,length(z_interp_digits));
ratSummary.orientation_traj = [];%NaN(numSessions_to_analyze,num_outcome_categories,length(z_interp_digits));

ratSummary.mean_aperture_traj = NaN(numSessions_to_analyze,length(z_interp_digits));
ratSummary.mean_orientation_traj = NaN(numSessions_to_analyze,length(z_interp_digits));

ratSummary.std_aperture_traj = NaN(numSessions_to_analyze,length(z_interp_digits));
ratSummary.sem_aperture_traj = NaN(numSessions_to_analyze,length(z_interp_digits));
ratSummary.MRL_traj = NaN(numSessions_to_analyze,length(z_interp_digits));

ratSummary.z_interp_digits = z_interp_digits;

ratSummary.sessionDates = NaT(numSessions_to_analyze,1);
ratSummary.sessionTypes = cell(numSessions_to_analyze,1);

ratSummary.outcomeCategories = outcomeCategories;
ratSummary.outcomeNames = outcomeNames;

ratSummary.mean_pd_trajectory = [];
ratSummary.mean_dig_trajectories = [];
ratSummary.mean_dist_from_pd_trajectory = [];
ratSummary.mean_dist_from_dig_trajectories = [];