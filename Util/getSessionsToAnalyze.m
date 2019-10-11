function sessions_to_analyze = getSessionsToAnalyze()
%
% create a structure with session metadata that we want for the analysis of
% last 2 training sessions, 10 sessions with laser, 10 sessions with
% occlusion. Would modify if we wanted the alternating sessions, etc.
%
% extract last 2 training sessions
for i_session = 1 : 2
    sessions_to_analyze(i_session).trainingStage = 'retraining';
    sessions_to_analyze(i_session).laserStim = 'none';
    sessions_to_analyze(i_session).sessions_remaining = 2 - i_session;
end

% extract 10 test sessions
for i_session = 3 : 12
    sessions_to_analyze(i_session).trainingStage = 'testing';
    sessions_to_analyze(i_session).laserStim = 'on';
    sessions_to_analyze(i_session).sessions_remaining = 12-i_session;
end

% extract 10 occlusion sessions
for i_session = 13 : 22
    sessions_to_analyze(i_session).trainingStage = 'testing';
    sessions_to_analyze(i_session).laserStim = 'occlude';
    sessions_to_analyze(i_session).sessions_remaining = 22-i_session;
end