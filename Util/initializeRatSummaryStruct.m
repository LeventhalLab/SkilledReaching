function ratSummary = initializeRatSummaryStruct(ratID,outcomeCategories,outcomeNames,numSessions_to_analyze)

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

ratSummary.mean_orientations = NaN(numSessions_to_analyze,num_outcome_categories);
ratSummary.MRL = NaN(numSessions_to_analyze,num_outcome_categories);

ratSummary.mean_aperture = NaN(numSessions_to_analyze,num_outcome_categories);
ratSummary.std_aperture = NaN(numSessions_to_analyze,num_outcome_categories);

ratSummary.sessionDates = NaT(numSessions_to_analyze,1);
ratSummary.sessionTypes = cell(numSessions_to_analyze,1);

ratSummary.outcomeCategories = outcomeCategories;
ratSummary.outcomeNames = outcomeNames;