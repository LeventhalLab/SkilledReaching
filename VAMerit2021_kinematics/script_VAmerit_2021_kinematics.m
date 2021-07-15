% script_VAmerit_2021_kinematics

pelletMarkerColor = 'k';
pelletMarker = '0';
pelletMarkerSize = 20;
ylims_3d = [-20 20];
xlims_3d = [-10 10];
zlims_3d = [-30 15];

z_interp_digits = 25:-0.1:-15;
post_reach_t = (1:50)/300;

ap_or_z_lims = [-5,20];
theta_lim = [0,100];
ap_lim = [2 15];

session_lims = [0,9];

lw = 2;

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
    max_dig2_endpt = zeros(length(group_kinematics),3);
    std_dig2_endpt = zeros(length(group_kinematics),3);
    std_endpt = zeros(length(group_kinematics),3);
    
    dist_from_pellet = zeros(length(group_kinematics),1);
    std_dist_from_pellet = zeros(length(group_kinematics),1);
    
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
        
        dig2_endpts{ii} = squeeze(group_kinematics(ii).dig_endPoints(:,2,:));
        max_dig2_endpt(ii,:) = nanmean(dig2_endpts{ii});
        std_dig2_endpt(ii,:) = nanstd(dig2_endpts{ii});
        
        % dist of digit 2 from pellet
        dig2_dist = sqrt(sum(dig2_endpts{ii}.^2,2));
        dist_from_pellet(ii) = nanmean(dig2_dist);
        std_dist_from_pellet(ii) = nanstd(dig2_dist);
        
        
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
    
    figure;errorbar(max_v(2:end), std_v(2:end)); set(gcf,'name',['max v, ' ratID]); set(gca,'xlim', session_lims)
    figure;errorbar(max_endpt(2:end,1), std_endpt(2:end,1)); set(gcf,'name',['max x, ' ratID]); set(gca,'xlim', session_lims)
    figure;errorbar(max_endpt(2:end,2), std_endpt(2:end,2)); set(gcf,'name',['max y, ' ratID]); set(gca,'xlim', session_lims)
    figure;errorbar(max_endpt(2:end,3), std_endpt(2:end,3)); set(gcf,'name',['max z, ' ratID]); set(gca,'xlim', session_lims)
    
    figure;errorbar(max_endpt(2:end,3), std_endpt(2:end,3)); set(gcf,'name',['max z, ' ratID]); set(gca,'xlim', session_lims)
    
    figure;errorbar(max_dig2_endpt(2:end,1), std_dig2_endpt(2:end,1)); set(gcf,'name',['max x dig 2, ' ratID]); set(gca,'xlim', session_lims)
    figure;errorbar(max_dig2_endpt(2:end,2), std_dig2_endpt(2:end,2)); set(gcf,'name',['max y dig 2, ' ratID]); set(gca,'xlim', session_lims)
    figure;errorbar(max_dig2_endpt(2:end,3), std_dig2_endpt(2:end,3)); set(gcf,'name',['max z dig 2, ' ratID]); set(gca,'xlim', session_lims)
    
    figure;errorbar(dist_from_pellet(2:end), std_dist_from_pellet(2:end)); set(gcf,'name',['dist from pellet, ' ratID]); set(gca,'xlim', session_lims)

%     figure;errorbar(mean_aperture(2:end), std_aperture(2:end)); set(gcf,'name',['aperture, ' ratID]); set(gca,'xlim', session_lims, 'ylim', ap_lim)
    
%     orientation_plot = mean_orientation(2:end)*180/pi;
%     if strcmp(ratID, 'R0382')
%         orientation_plot = 180-orientation_plot;
%     end
%     figure;plot(orientation_plot); set(gcf,'name',['orientation, ' ratID]); set(gca,'xlim', session_lims, 'ylim', theta_lim)
%     figure;plot(mean_grasp_orientation*180/pi); set(gcf,'name','grasp orientation'); set(gca,'xlim', session_lims)
%     figure;plot(mean_grasp_aperture); set(gcf,'name','grasp aperture'); set(gca,'xlim', session_lims)
%     figure;plot(mean_reach_duration); set(gcf,'name','reach duration'); set(gca,'xlim', session_lims)
%     figure;plot(mean_grasp_duration); set(gcf,'name','grasp duration'); set(gca,'xlim', session_lims)
    
    figure;plot(gen_var_pd_endPt); set(gcf,'name',['pd generalized variance, ' ratID]);
    figure;plot(gen_var_dig_endPts); set(gcf,'name',['digits generalized variance, ' ratID]);
    
    h_ap_fig = figure;
    h_or_fig = figure;
    h_ap_post_fig = figure;
    h_or_post_fig = figure;
    col_list = zeros(7,3);
    col_list(2:end,:) = repmat((0.8:-0.16:0)',1,3);
    col_list(1,:) = [1 0 0];
    for ii = 2 : length(group_kinematics)
        figure(h_ap_fig);
        plot(z_interp_digits,mean_aperture_traj(ii,:),'color',col_list(ii-1,:),'linewidth',lw);
        h_ap_axes = gca;
        hold on
        
        figure(h_or_fig);
        plot(z_interp_digits,180-mean_orientation_traj(ii,:)*180/pi,'color',col_list(ii-1,:),'linewidth',lw);
        h_or_axes = gca;
        hold on
        
        figure(h_ap_post_fig);
        plot(post_reach_t,post_reach_aperture(ii,:),'color',col_list(ii-1,:),'linewidth',lw);
        h_ap_post_axes = gca;
        hold on
        
        figure(h_or_post_fig);
        plot(post_reach_t,180-post_reach_orientation(ii,:)*180/pi,'color',col_list(ii-1,:),'linewidth',lw);
        h_or_post_axes = gca;
        hold on
    end
    set(h_ap_fig,'name',['aperture trajectory, ' ratID]);
    set(h_ap_axes,'xdir','reverse','xlim',ap_or_z_lims,'ylim',ap_lim,'ytick',[0:5:ap_lim(2)]);
    h_ap_axes.XLabel.String = 'z (mm)';
    h_ap_axes.YLabel.String = 'aperture (mm)';
    h_ap_axes.XLabel.FontSize = 12;
    h_ap_axes.YLabel.FontSize = 12;
    axes(h_ap_axes)
    legend('saline','6-OHDA1','6-OHDA2','6-OHDA3','6-OHDA4','6-OHDA5','6-OHDA6','location','northwest')
    
    set(h_or_fig,'name',['orientation trajectory, ' ratID]); set(h_or_axes,'xdir','reverse','xlim',ap_or_z_lims,'ylim',theta_lim,'ytick',theta_lim)
    set(h_ap_post_fig,'name',['post reach aperture trajectory, ' ratID]);set(h_ap_post_axes,'ylim',ap_lim)
    set(h_or_post_fig,'name',['post reach orientation trajectory, ' ratID]);set(h_or_post_axes,'ylim',theta_lim,'ytick',theta_lim)
    
    h_or_axes.XLabel.String = 'z (mm)';
    h_or_axes.YLabel.String = 'paw orientation (deg)';
    h_or_axes.XLabel.FontSize = 12;
    h_or_axes.YLabel.FontSize = 12;
    
    h_or_post_axes.XLabel.String = 'time after reach (s)';
    h_or_post_axes.YLabel.String = 'paw orientation (deg)';
    h_or_post_axes.XLabel.FontSize = 12;
    h_or_post_axes.YLabel.FontSize = 12;
    
%     post_reach_or50 = 180-post_reach_orientation(:,15)*180/pi;
%     figure;
%     plot(post_reach_or50(2:end));
%     figure;   % ellipsoid plot
%     group_id = 2;
%     error_ellipse(group_kinematics(group_id).pd_covar, nanmean(group_kinematics(group_id).pdEndPts));
%     hold on
%     for i_digit = 1 : 4
%         cov_mtx = squeeze(group_kinematics(group_id).dig_covar(:,:,i_digit));
%         dig_endPt = nanmean(squeeze(group_kinematics(group_id).dig_endPoints(:,i_digit,:)));
%         error_ellipse(cov_mtx, dig_endPt);
%     end
%     scatter3(0,0,0,pelletMarkerSize,...
%         'markerfacecolor',pelletMarkerColor,...
%         'markeredgecolor',pelletMarkerColor);
%     set(gcf,'name',['saline, ' ratID])
%     set(gca,'ydir','reverse');
%     set(gca,'ylim',ylims_3d, 'xlim',xlims_3d, 'zlim', zlims_3d);   
%     xlabel('x');ylabel('y');zlabel('z');
%     
%     figure;   % ellipsoid plot
%     switch ratID
%         case 'R0382'
%             group_id = 8;
%         case 'R0383'
%             group_id = 5;
%         case 'R0386'
%             group_id = 3;
%         case 'R0387'
%             group_id = 3;
%     end
%     error_ellipse(group_kinematics(group_id).pd_covar, nanmean(group_kinematics(group_id).pdEndPts));
%     hold on
%     for i_digit = 1 : 4
%         cov_mtx = squeeze(group_kinematics(group_id).dig_covar(:,:,i_digit));
%         dig_endPt = nanmean(squeeze(group_kinematics(group_id).dig_endPoints(:,i_digit,:)));
%         error_ellipse(cov_mtx, dig_endPt);
%     end
%     scatter3(0,0,0,pelletMarkerSize,...
%         'markerfacecolor',pelletMarkerColor,...
%         'markeredgecolor',pelletMarkerColor);
%     set(gcf,'name',['last 6OHDA, ' ratID])
%     set(gca,'ydir','reverse');
%     set(gca,'ylim',ylims_3d, 'xlim',xlims_3d, 'zlim', zlims_3d);
%     xlabel('x');ylabel('y');zlabel('z');

end
    