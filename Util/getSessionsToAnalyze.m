function sessions_to_analyze = getSessionsToAnalyze()

% extract last 2 training sessions
for i_session = 1 : 2
    sessions_to_analyze(i_session).trainingStage = 'training';
    sessions_to_analyze(i_session).laserTrialSetting = 'none';
    sessions_to_analyze(i_session).sessions_remaining = 2 - i_session;
%     sessions_to_analyze(i_session).prior_laserTrialSetting = '';
end

% extract 10 test sessions
for i_session = 3 : 12
    sessions_to_analyze(i_session).trainingStage = 'testing';
    sessions_to_analyze(i_session).laserTrialSetting = 'on';
    sessions_to_analyze(i_session).session_in_block = i_session - 2;
%     sessions_to_analyze(i_session).prior_laserTrialSetting = 'none';
end

% extract 10 occlusion sessions
for i_session = 13 : 22
    sessions_to_analyze(i_session).trainingStage = 'testing';
    sessions_to_analyze(i_session).laserTrialSetting = 'occlude';
    sessions_to_analyze(i_session).session_in_block = i_session - 12;
%     sessions_to_analyze(i_session).prior_laserTrialSetting = '';
end