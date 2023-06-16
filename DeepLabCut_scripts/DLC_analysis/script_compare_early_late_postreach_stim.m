%%
DLCoutput_parent = '\\corexfs.med.umich.edu\SharedX\Neuro-Leventhal\data\skilled_reaching\DLC output\';

% only counting trials where stim through vidtrigger, there are also ones
% with stim through nose-in
% prereach_sessions

sessions_to_analyze(1).session_type = 'prereach';
sessions_to_analyze(1).sessions = {'R0216_20180305a', 'R0216_20180308a', 'R0217_20180305a', 'R0217_20180308a', 'R0218_20180305a', 'R0218_20180308a', 'R0229_20181128a', 'R0230_20181116a', 'R0235_20181128a'};
sessions_to_analyze(2).session_type = 'pre-midreach';
sessions_to_analyze(2).sessions = {'R0216_20180313a', 'R0217_20180313a', 'R0218_20180313a'};
sessions_to_analyze(3).session_type = 'earlypost';
sessions_to_analyze(3).sessions = {'R0216_20180306a', 'R0217_20180306a', 'R0218_20180306a', 'R0229_20181127a', 'R0230_20181120a', 'R0230_20181121a', 'R0235_20181121a'};
sessions_to_analyze(4).session_type = 'latepost';
sessions_to_analyze(4).sessions = {'R0229_20181119a', 'R0229_20181126a', 'R0235_20181126a', 'R0235_20181127a'};

for i_sessiontype = 1 : length(sessions_to_analyze)
    kinematics(i_sessiontype).session_type = sessions_to_analyze(i_sessiontype).session_type;

    session_type = sessions_to_analyze(i_sessiontype).session_type;
    session_list = sessions_to_analyze(i_sessiontype).sessions;

    num_sessions = length(session_list);

    for i_session = 1 : num_sessions
        cur_session = session_list{i_session};
        session_name_parts = split(cur_session, '_');
        ratID = session_name_parts{1};

        rat_folder = fullfile(DLCoutput_parent, ratID);
        session_folder = fullfile(rat_folder, cur_session);

        if ~isfolder(session_folder)
            continue
        end

        cd(session_folder)
        reachDataName = [cur_session(1:end-1) '_processed_reaches.mat'];

        load(reachDataName)

        num_trials = length(reachData);
        kinematics(i_sessiontype).dig_endPts{i_session} = NaN(num_trials,4,3);
        kinematics(i_sessiontype).pd_endPts{i_session} = NaN(num_trials, 3);
        
        for iTrial = 1 : num_trials
        
            current_outcome = reachData(iTrial).trialScores;
            
%             for i_validType = 1 : length(validTrialOutcomes)
%                 if any(ismember(current_outcome,validTrialOutcomes{i_validType}))
%                     outcomeFlag(iTrial,i_validType) = true;   % this could be slightly inaccurate, but most trials only have 1 outcome
%                 end
%             end
            
            if ~isempty(reachData(iTrial).reachEnds)
                kinematics(i_sessiontype).pd_endPts{i_session}(iTrial,:) = reachData(iTrial).pdEndPoints(1,:);
                kinematics(i_sessiontype).dig_endPts{i_session}(iTrial,:,:) = reachData(iTrial).dig_endPoints(1,:,:);
            end

        end

    end

end

%%


col_list = {'k', 'b','r','g'};
num_sessions = 0;
for i_sessiontype = 1 : length(kinematics)
%     figure(i_sessiontype)
%     hold off

    for i_session = 1 : length(kinematics(i_sessiontype).dig_endPts)

        if isempty(kinematics(i_sessiontype).dig_endPts{i_session})
            continue
        end
        num_sessions = num_sessions + 1;
        figure(num_sessions)
        hold off
        set(gcf,'name', sprintf('%s, %s', sessions_to_analyze(i_sessiontype).session_type, sessions_to_analyze(i_sessiontype).sessions{i_session}))
        plot(smoothdata(kinematics(i_sessiontype).dig_endPts{i_session}(:,2,3), 'movmean', 10), col_list{i_sessiontype})
        hold on
        plot(kinematics(i_sessiontype).dig_endPts{i_session}(:,2,3), col_list{i_sessiontype})
    end
end

%%
col_list = {'k', 'b','r','g'};
num_sessions = 0;
figure
hold on

num_trials_to_average = 10;
num_sessiontypes = length(sessions_to_analyze);
session_values = cell(num_sessiontypes, 1);
for i_sessiontype = 1 : length(kinematics)

    num_sessions = length(sessions_to_analyze(i_sessiontype).sessions);
    session_values{i_sessiontype} = NaN(num_sessions, 2);
    dig_endPts = kinematics(i_sessiontype).dig_endPts;
    for i_session = 1 : length(dig_endPts)

        if isempty(kinematics(i_sessiontype).dig_endPts{i_session})
            continue
        end
        if size(dig_endPts{i_session},1) < num_trials_to_average
            continue
        end
        num_sessions = num_sessions + 1;

        session_values{i_sessiontype}(i_session, 1) = mean(dig_endPts{i_session}(1:num_trials_to_average,2,3));
        session_values{i_sessiontype}(i_session, 2) = mean(dig_endPts{i_session}(end-num_trials_to_average:end,2,3));
    end
    for ii = 1 : size(session_values{i_sessiontype}, 1)
        plot([1,2], session_values{i_sessiontype}(ii,:), 'marker', '*', 'color',col_list{i_sessiontype})
    end
    scatter([1,2], mean(session_values{i_sessiontype}, 1, 'omitnan'), 20, 'marker', 'o', 'markerfacecolor', col_list{i_sessiontype})
end