%%
DLCoutput_parent = '\\corexfs.med.umich.edu\SharedX\Neuro-Leventhal\data\skilled_reaching\DLC output\';

% only counting trials where stim through vidtrigger, there are also ones
% with stim through nose-in
% prereach_sessions


% can exclude 230 because it had minimal to no effect with full during
% reach stim
sessions_to_analyze(1).session_type = 'during';
% exclude sessions with less than 40 trials
sessions_to_analyze(1).sessions = {'R0216_20180227a', 'R0216_20180228a', 'R0217_20180228a', 'R0217_20180301a', 'R0217_20180302a', 'R0218_20180228a', 'R0218_20180301a', 'R0229_20181116a', 'R0229_20181117a','R0229_20181119a','R0235_20181116a','R0235_20181117a'};
% sessions_to_analyze(5).sessions = {'R0216_20180227a', 'R0216_20180228a', 'R0217_20180228a', 'R0217_20180301a', 'R0217_20180302a', 'R0218_20180228a', 'R0218_20180301a', 'R0229_20181116a', 'R0229_20181117a','R0229_20181119a','R0230_20181105a','R0230_20181106a','R0230_20181107a','R0230_20181108a','R0230_20181109a','R0230_20181110a','R0230_20181112a','R0230_20181113a','R0235_20181116a','R0235_20181117a'};
sessions_to_analyze(1).sessions = {'R0216_20180227a', 'R0216_20180228a', 'R0217_20180228a', 'R0217_20180301a', 'R0217_20180302a', 'R0229_20181116a', 'R0229_20181117a','R0229_20181119a','R0235_20181116a','R0235_20181117a'};


sessions_to_analyze(2).session_type = 'bb-orient';
% sessions_to_analyze(2).sessions = {'R0216_20180305a', 'R0216_20180308a', 'R0217_20180305a', 'R0217_20180308a', 'R0218_20180305a', 'R0229_20181128a', 'R0230_20181116a', 'R0235_20181128a'};
% sessions_to_analyze(2).sessions = {'R0216_20180305a', 'R0216_20180308a', 'R0217_20180305a', 'R0217_20180308a', 'R0218_20180305a', 'R0229_20181128a', 'R0235_20181128a'};
% exclude session with just 14 trials
sessions_to_analyze(2).sessions = {'R0216_20180305a', 'R0216_20180308a', 'R0217_20180305a', 'R0217_20180308a', 'R0218_20180305a', 'R0229_20181128a'};
% ignored 'R0218_20180308a' for pre-reach because only 6 trials

sessions_to_analyze(3).session_type = 'vidtrigger-';
sessions_to_analyze(3).sessions = {'R0216_20180306a', 'R0217_20180306a', 'R0218_20180306a', 'R0229_20181127a', 'R0235_20181121a'};
% sessions_to_analyze(3).sessions = {'R0216_20180306a', 'R0217_20180306a', 'R0218_20180306a', 'R0229_20181127a', 'R0230_20181120a', 'R0230_20181121a', 'R0235_20181121a'};

sessions_to_analyze(4).session_type = 'vidtrigger + 500ms -';
sessions_to_analyze(4).sessions = {'R0229_20181119a', 'R0229_20181126a', 'R0235_20181126a', 'R0235_20181127a'};
% exclude session with 8 trials
sessions_to_analyze(4).sessions = {'R0229_20181119a', 'R0229_20181126a', 'R0235_20181127a'};

sessions_to_analyze(5).session_type = 'bb-vidtrigger';
% sessions_to_analyze(5).sessions = {'R0216_20180313a', 'R0217_20180313a', 'R0218_20180313a'};
% exclude session with just 18 trials
sessions_to_analyze(5).sessions = {'R0216_20180313a', 'R0217_20180313a'};

ratIDs = cell(length(sessions_to_analyze), 1);
for i_type = 1 : length(sessions_to_analyze)
    ratIDs{i_type} = cell(length(sessions_to_analyze(i_type).sessions),1);
    for ii = 1 : length(sessions_to_analyze(i_type).sessions)
        ratIDs{i_type}{ii} = sessions_to_analyze(i_type).sessions{ii}(1:5);
    end
end

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
col_list = {[47,65,151]/255,[88,200,228]/255,[237,32,36]/255,[17,150,75]/255,'m'};

% col_list = {'k', 'b','r','g', 'm'};
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
        set(gca,'ylim',[-10 15])
    end
end


%%
col_list = {[47,65,151]/255,[88,200,228]/255,[237,32,36]/255,[17,150,75]/255,'m'};
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

%%
% normalize session to have same number of reaches
col_list = {'c','m','r','g','b'};

for ii = 1 : length(sessions_to_analyze)
    sessiontypes{ii} = sessions_to_analyze(ii).session_type;
end

num_sessiontypes = length(sessions_to_analyze);
num_trials_to_average = 10;

interp_values = cell(num_sessiontypes, 1);
smoothwin = 10;
num_interp_points = 50;
interp_x = linspace(0,1,num_interp_points);
interp_means = NaN(length(kinematics), num_interp_points);

for i_sessiontype = 1 : length(kinematics)

    
    num_sessions = length(sessions_to_analyze(i_sessiontype).sessions);
        session_values{i_sessiontype} = NaN(num_sessions, 2);
    dig_endPts = kinematics(i_sessiontype).dig_endPts;
    interp_values{i_sessiontype} = NaN(length(dig_endPts), num_interp_points);
    for i_session = 1 : length(dig_endPts)

        if isempty(kinematics(i_sessiontype).dig_endPts{i_session})
            continue
        end
        if size(dig_endPts{i_session},1) < num_trials_to_average
            continue
        end
        num_sessions = num_sessions + 1;

        cur_values = kinematics(i_sessiontype).dig_endPts{i_session}(:,2,3);
        x_values = linspace(0,1,length(cur_values));
        
        interp_values{i_sessiontype}(i_session, :) = interp1(x_values, cur_values, interp_x);

    end
    interp_means(i_sessiontype, :) = mean(interp_values{i_sessiontype}, 'omitnan');
end

figure(1)
hold off
idx_to_plot = [1,2,3,4,5];
for ii = 1 : length(idx_to_plot)
    plot(movmean(interp_means(idx_to_plot(ii), :), smoothwin), color=col_list{idx_to_plot(ii)})
    hold on
end
set(gca,'ylim',[-6 5])
ylabel('z_d_i_g_i_t_2 (mm)','fontname','arial','fontsize',10)
% legend(sessiontypes)

%%
% use first reaches_to_use reaches
lw = 2;

num_reaches_to_use = 40;
trial_nums = 1 : num_reaches_to_use;

for ii = 1 : length(sessions_to_analyze)
    sessiontypes{ii} = sessions_to_analyze(ii).session_type;
end

num_sessiontypes = length(sessions_to_analyze);

session_dig2 = cell(num_sessiontypes, 1);
smoothwin = 15;
dig2_means = NaN(length(kinematics), num_reaches_to_use);
dig2_stds = NaN(length(kinematics), num_reaches_to_use);
dig2_sems = NaN(length(kinematics), num_reaches_to_use);
num_sessions = zeros(num_sessiontypes, 1);
num_rats = zeros(num_sessiontypes, 1);

for i_sessiontype = 1 : length(kinematics)

    unique_rats = unique(ratIDs{i_sessiontype});
    num_rats(i_sessiontype) = length(unique_rats);

    
    num_sessions(i_sessiontype) = length(sessions_to_analyze(i_sessiontype).sessions);

    dig_endPts = kinematics(i_sessiontype).dig_endPts;
    session_dig2{i_sessiontype} = NaN(length(dig_endPts), num_reaches_to_use);
    for i_session = 1 : length(dig_endPts)

        if isempty(kinematics(i_sessiontype).dig_endPts{i_session})
            continue
        end
        if isempty(kinematics(i_sessiontype).dig_endPts{i_session})
            continue
        end
        if size(dig_endPts{i_session},1) < num_reaches_to_use
            continue
        end
        num_sessions(i_sessiontype) = num_sessions(i_sessiontype) + 1;
        
        session_dig2{i_sessiontype}(i_session, :) = kinematics(i_sessiontype).dig_endPts{i_session}(1:num_reaches_to_use,2,3);

    end
    dig2_means(i_sessiontype, :) = mean(session_dig2{i_sessiontype}, 'omitnan');
    dig2_stds(i_sessiontype, :) = std(session_dig2{i_sessiontype}, 'omitnan');
    dig2_sems(i_sessiontype, :) = dig2_stds(i_sessiontype, :) / sqrt(num_sessions(i_sessiontype));
end

h_fig = figure(1);
% set(h_fig, 'units', 'centimeters', 'position', [10, 10, 6, 4.5])
set(gca, 'units', 'centimeters', 'position', [10, 10, 6, 4.5])
hold off
col_list = {[47,65,151]/255,[88,200,228]/255,[237,32,36]/255,[17,150,75]/255,'m'};
idx_to_plot = [1,2,3,4];
for ii = 1 : length(idx_to_plot)
    plot(trial_nums, -movmean(dig2_means(idx_to_plot(ii), :), smoothwin), color=col_list{idx_to_plot(ii)},LineWidth=lw)
    shadedErrorBar(trial_nums, -movmean(dig2_means(idx_to_plot(ii), :), smoothwin), movmean(dig2_sems(idx_to_plot(ii), :), smoothwin), 'lineprops',{'color',col_list{idx_to_plot(ii)}, 'linewidth', lw})
    hold on
end
yline(0, 'k--')
set(gca,'ylim',[-8 10],'xtick',[0, 20, 40], 'ytick', [-5,0,10])
ylabel('z_d_i_g_i_t_2 (mm)','fontname','arial','fontsize',10)
xlabel('trial number','fontname','arial','fontsize',10)
% legend(sessiontypes)

set(gca, 'units', 'centimeters', 'position', [1, 1, 4.5, 3])

dest_name = 'fine_stimtiming_kinematics.pdf';
dest_name = fullfile('C:\Users\dleventh\Dropbox (University of Michigan)\MED-LeventhalLab\Proposals\R01_applications\R01_SR_2022\Figures', dest_name);
print(h_fig, dest_name, '-dpdf')

%% 
all_rats = ratIDs{1};
for ii = 2 : length(ratIDs)
    all_rats = [all_rats; ratIDs{ii}];
end
all_rats = unique(all_rats);

%%
smoothwin = 15;
rat_list = cell(length(kinematics), 1);
dig2_pre_post = cell(length(kinematics), 1);

all_rats = ratIDs{1};
for ii = 2 : length(ratIDs)
    all_rats = [all_rats; ratIDs{ii}];
end
all_rats = unique(all_rats);


for i_sessiontype = 1 : length(kinematics)

    num_unique_rats = 0;
   
    unique_rats = unique(ratIDs{i_sessiontype});
    num_rats(i_sessiontype) = length(unique_rats);
%     dig2_pre_post{i_sessiontype} = cell(num_rats(i_sessiontype), 1);

    num_sessions(i_sessiontype) = length(sessions_to_analyze(i_sessiontype).sessions);
    num_rat_sessions = zeros(num_rats(i_sessiontype), 1);

    dig_endPts = kinematics(i_sessiontype).dig_endPts;
    session_dig2{i_sessiontype} = NaN(length(dig_endPts), num_reaches_to_use);

    
    for i_session = 1 : length(dig_endPts)
        ratID = sessions_to_analyze(i_sessiontype).sessions{i_session}(1:5);

        if isempty(kinematics(i_sessiontype).dig_endPts{i_session})
            continue
        end
        if size(dig_endPts{i_session},1) < num_reaches_to_use
            continue
        end

        if ~any(strcmp(ratID, rat_list{i_sessiontype}))
            num_unique_rats = num_unique_rats + 1;
            rat_list{i_sessiontype}{num_unique_rats} = ratID;
        end
        num_rat_sessions(num_unique_rats) = num_rat_sessions(num_unique_rats) + 1;

        num_sessions(i_sessiontype) = num_sessions(i_sessiontype) + 1;
        
        session_dig2{i_sessiontype}(i_session, :) = kinematics(i_sessiontype).dig_endPts{i_session}(1:num_reaches_to_use,2,3);

        if num_rat_sessions(num_unique_rats) == 1
            dig2_pre_post{i_sessiontype}{num_unique_rats} = [mean(session_dig2{i_sessiontype}(i_session, 1:smoothwin), 'omitnan'), mean(session_dig2{i_sessiontype}(i_session, num_reaches_to_use-smoothwin:end), 'omitnan')];
        else
            dig2_pre_post{i_sessiontype}{num_unique_rats} = [dig2_pre_post{i_sessiontype}{num_unique_rats};
                                                             mean(session_dig2{i_sessiontype}(i_session, 1:smoothwin), 'omitnan'), mean(session_dig2{i_sessiontype}(i_session, num_reaches_to_use-smoothwin:end), 'omitnan')];
        end
        

    end

end

idx_to_plot = [1,2,3,4];
rat_diffs = zeros(length(all_rats), length(idx_to_plot));
for i_rat = 1 : length(all_rats)
    cur_ratID = all_rats{i_rat};
    for ii = 1 : length(idx_to_plot)

        i_sessiontype = idx_to_plot(ii);

        % get pre-post average for each rat
        for i_sessiontyperat = 1 : length(rat_list{i_sessiontype})

            sessiontyperat_idx = find(strcmp(cur_ratID, rat_list{i_sessiontype}));

            if isempty(sessiontyperat_idx)
                continue
            end

            ratsession_pre_post = dig2_pre_post{i_sessiontype}{sessiontyperat_idx};

            if size(ratsession_pre_post, 1) > 1
                rat_diffs(i_rat, ii) = diff(mean(ratsession_pre_post));
            else
                rat_diffs(i_rat, ii) = diff(ratsession_pre_post);
            end

        end

    end

end

rat_diffs(rat_diffs==0) = nan;
h_fig = figure(2);
% set(h_fig, 'units', 'centimeters', 'position', [10, 10, 6, 4.5])
linestyles = {'-o','--s',':+','-.x', '-^'};
% markertypes = {'o','s','+','x',''};
for i_rat = 1 : size(rat_diffs, 1)
    plot(-rat_diffs(i_rat, :), linestyles{i_rat}, color='k',linewidth=2)
%     set(gca,'')
    hold on
end
yline(0, '--')
set(gca,'xlim',[0.5 4.5],'ylim',[-8 10],'ytick', [-5,0,10],'yticklabel','')
set(gca,'fontname','arial','fontsize',10)
set(gca,'xtick',1:4,'xticklabel',{'during','pre-reach','imm post','delay post'})
xtickangle(20)
set(gca, 'units', 'centimeters', 'position', [1, 2, 4.5, 3.25])

% ylabel('z_d_i_g_i_t_2 (mm)','fontname','arial','fontsize',10)
dest_name = 'fine_stimtiming_summary.pdf';
dest_name = fullfile('C:\Users\dleventh\Dropbox (University of Michigan)\MED-LeventhalLab\Proposals\R01_applications\R01_SR_2022\Figures', dest_name);
print(h_fig, dest_name, '-dpdf')
        