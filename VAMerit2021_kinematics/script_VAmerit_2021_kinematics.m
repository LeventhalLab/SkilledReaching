% script_VAmerit_2021_kinematics

pelletMarkerColor = 'k';
pelletMarker = '0';
pelletMarkerSize = 20;
ylims_3d = [-20 20];
xlims_3d = [-10 10];
zlims_3d = [-30 15];

session_lims = [0,9];

parent_folder = '/Volumes/Untitled/videos_to_analyze';
labeledBodypartsFolder = fullfile(parent_folder, 'matlab_readable_dlc');
xlDir = parent_folder;%'/Users/dan/Box/Leventhal Lab/Skilled Reaching Project/Scoring Sheets';
% xlfname = fullfile(xlDir,'rat_info_pawtracking_DL.xlsx');
csvfname = fullfile(xlDir,'SR_rat_database.csv');
ratInfo = readRatInfoTable(csvfname);

ratSummaryDir = fullfile(labeledBodypartsFolder,'rat_kinematic_summaries');

ratInfo_IDs = [ratInfo.ratID];

cd(labeledBodypartsFolder)
ratFolders = dir('R*');
numRatFolders = length(ratFolders);

sessions_grouping = {'training','saline','OHDA1','OHDA2','OHDA3','OHDA4','OHDA5','OHDA6'};

if exist('group_kinematics','var')
    clear group_kinematics
end
for i_rat = 2:2%1 : numRatFolders
    
    ratID = ratFolders(i_rat).name
    ratIDnum = str2double(ratID(2:end));
    
    ratSummaryName = [ratID '_kinematicsSummary.mat'];
        cd(ratSummaryDir)
    if exist(ratSummaryName,'file')
        load(ratSummaryName)
    else
        fprintf('no rat summary found for %s\n',ratID)
    end
    
    ratInfo_idx = find(ratInfo_IDs == ratIDnum);
    if isempty(ratInfo_idx)
        error('no entry in ratInfo structure for rat %d\n',C{1});
    end
    thisRatInfo = ratInfo(ratInfo_idx,:);
    pawPref = thisRatInfo.pawPref;
    if iscategorical(pawPref)
        pawPref = char(pawPref);
    end
    if iscell(pawPref)
        pawPref = pawPref{1};
    end
    
    ratRootFolder = fullfile(labeledBodypartsFolder,ratID);
    cd(ratRootFolder);
    sessionDirectories = listFolders([ratID '_2*']);
    numSessions = length(sessionDirectories);
    
    % figure out all the session types
    sessions_from_table = cellstr(ratSummary.sessions_analyzed.trainingStage);
    
    for i_stage = 1 : length(sessions_grouping)
        i_stage
        current_session_idxs = find(strcmpi(sessions_from_table, sessions_grouping{i_stage}));
        current_sessions = ratSummary.sessions_analyzed(current_session_idxs,:);
        
        current_dates = current_sessions.date;
        
        group_kinematics(i_stage) = collect_group_trials(sessionDirectories, current_sessions, ratSummary, current_session_idxs, ratRootFolder); %#ok<*SAGROW>

        
    end
        
    
    % collect kinematics
    
    max_v = zeros(1, length(group_kinematics));
    std_v = zeros(1, length(group_kinematics));
    max_endpt = zeros(length(group_kinematics),3);
    std_endpt = zeros(length(group_kinematics),3);
    mean_aperture = zeros(1,length(group_kinematics));
    std_aperture = zeros(1,length(group_kinematics));
    mean_orientation = zeros(1,length(group_kinematics));
    mean_grasp_orientation = zeros(1,length(group_kinematics));
    mean_grasp_aperture = zeros(1,length(group_kinematics));
    mean_reach_duration = zeros(1, length(group_kinematics));
    mean_grasp_duration = zeros(1, length(group_kinematics));
    mean_aperture_traj = zeros(length(group_kinematics),401);
    mean_orientation_traj = zeros(length(group_kinematics),401);
    
    gen_var_pd_endPt = zeros(1, length(group_kinematics));
    gen_var_dig_endPts = zeros(length(group_kinematics),4);
    
    post_reach_points = size(group_kinematics(1).post_reach_aperture,2);
    post_reach_aperture = zeros(length(group_kinematics), post_reach_points);
    post_reach_orientation = zeros(length(group_kinematics), post_reach_points);
    for ii = 1 : length(group_kinematics)
        % paw velocity
        max_v(ii) = nanmean(group_kinematics(ii).max_pd_v);
        std_v(ii) = nanstd(group_kinematics(ii).max_pd_v);
        max_endpt(ii,:) = nanmean(group_kinematics(ii).pdEndPts);
        std_endpt(ii,:) = nanstd(group_kinematics(ii).pdEndPts);
        mean_aperture(ii) = nanmean(group_kinematics(ii).end_aperture);
        std_aperture(ii) = nanstd(group_kinematics(ii).end_aperture);
        mean_orientation(ii) = nanmean(group_kinematics(ii).end_orientation);
        
        mean_grasp_orientation(ii) = nanmean(group_kinematics(ii).grasp_end_orientation);
        mean_grasp_aperture(ii) = nanmean(group_kinematics(ii).grasp_end_aperture);
        
        mean_reach_duration(ii) = nanmean(group_kinematics(ii).reach_duration);
        mean_grasp_duration(ii) = nanmean(group_kinematics(ii).grasp_duration);
        
        mean_aperture_traj(ii,:) = nanmean(group_kinematics(ii).aperture_traj);
        mean_orientation_traj(ii,:) = nanmean(group_kinematics(ii).orientation_traj);
        
        if ~isempty(group_kinematics(ii).pd_gen_var)
            gen_var_pd_endPt(ii) = group_kinematics(ii).pd_gen_var;
        end
        gen_var_dig_endPts(ii,:) = group_kinematics(ii).dig_gen_var;
        
        post_reach_aperture(ii,:) = nanmean(group_kinematics(ii).post_reach_aperture,1);
        post_reach_orientation(ii,:) = nanmean(group_kinematics(ii).post_reach_orientation,1);
    end
    
    figure;errorbar(max_v, std_v); set(gcf,'name','max v'); set(gca,'xlim', session_lims)
    figure;errorbar(max_endpt(:,1), std_endpt(:,1)); set(gcf,'name','max x'); set(gca,'xlim', session_lims)
    figure;errorbar(max_endpt(:,2), std_endpt(:,2)); set(gcf,'name','max y'); set(gca,'xlim', session_lims)
    figure;errorbar(max_endpt(:,3), std_endpt(:,3)); set(gcf,'name','max z'); set(gca,'xlim', session_lims)
    figure;errorbar(mean_aperture, std_aperture); set(gcf,'name','aperture'); set(gca,'xlim', session_lims)
    figure;plot(mean_orientation*180/pi); set(gcf,'name','orientation'); set(gca,'xlim', session_lims)
%     figure;plot(mean_grasp_orientation*180/pi); set(gcf,'name','grasp orientation'); set(gca,'xlim', session_lims)
%     figure;plot(mean_grasp_aperture); set(gcf,'name','grasp aperture'); set(gca,'xlim', session_lims)
%     figure;plot(mean_reach_duration); set(gcf,'name','reach duration'); set(gca,'xlim', session_lims)
%     figure;plot(mean_grasp_duration); set(gcf,'name','grasp duration'); set(gca,'xlim', session_lims)
    
    figure;plot(gen_var_pd_endPt); set(gcf,'name','pd generalized variance');
    figure;plot(gen_var_dig_endPts); set(gcf,'name','digits generalized variance');
    
    h_ap_fig = figure;
    h_or_fig = figure;
    h_ap_post_fig = figure;
    h_or_post_fig = figure;
    col_list = repmat((0.8:-0.1:0)',1,3);
    for ii = 2 : length(group_kinematics)
        figure(h_ap_fig);
        plot(mean_aperture_traj(ii,:),'color',col_list(ii,:));
        hold on
        
        figure(h_or_fig);
        plot(mean_orientation_traj(ii,:)*180/pi,'color',col_list(ii,:));
        hold on
        
        figure(h_ap_post_fig);
        plot(post_reach_aperture(ii,:),'color',col_list(ii,:));
        hold on
        
        figure(h_or_post_fig);
        plot(post_reach_orientation(ii,:)*180/pi,'color',col_list(ii,:));
        hold on
    end
    set(h_ap_fig,'name','aperture trajectory');
    set(h_or_fig,'name','orientation trajectory');
    
    figure;   % ellipsoid plot
    group_id = 2;
    error_ellipse(group_kinematics(group_id).pd_covar, nanmean(group_kinematics(group_id).pdEndPts));
    hold on
    for i_digit = 1 : 4
        cov_mtx = squeeze(group_kinematics(group_id).dig_covar(:,:,i_digit));
        dig_endPt = nanmean(squeeze(group_kinematics(group_id).dig_endPoints(:,i_digit,:)));
        error_ellipse(cov_mtx, dig_endPt);
    end
    scatter3(0,0,0,pelletMarkerSize,...
        'markerfacecolor',pelletMarkerColor,...
        'markeredgecolor',pelletMarkerColor);
    set(gcf,'name','saline')
    set(gca,'ydir','reverse');
    set(gca,'ylim',ylims_3d, 'xlim',xlims_3d, 'zlim', zlims_3d);   
    xlabel('x');ylabel('y');zlabel('z');
    
    figure;   % ellipsoid plot
    group_id = 8;
    error_ellipse(group_kinematics(group_id).pd_covar, nanmean(group_kinematics(group_id).pdEndPts));
    hold on
    for i_digit = 1 : 4
        cov_mtx = squeeze(group_kinematics(group_id).dig_covar(:,:,i_digit));
        dig_endPt = nanmean(squeeze(group_kinematics(group_id).dig_endPoints(:,i_digit,:)));
        error_ellipse(cov_mtx, dig_endPt);
    end
    scatter3(0,0,0,pelletMarkerSize,...
        'markerfacecolor',pelletMarkerColor,...
        'markeredgecolor',pelletMarkerColor);
    set(gcf,'name','OHDA6')
    set(gca,'ydir','reverse');
    set(gca,'ylim',ylims_3d, 'xlim',xlims_3d, 'zlim', zlims_3d);
    xlabel('x');ylabel('y');zlabel('z');

end
    