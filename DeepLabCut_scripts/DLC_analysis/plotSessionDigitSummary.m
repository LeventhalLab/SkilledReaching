function [h_fig,h_axes,h_figAxis] = plotSessionDigitSummary(trialTypeIdx,paw_endAngle,mean_session_digit_trajectories,mean_xyz_from_dig_session_trajectories,mean_euc_from_dig_session_trajectories,bodyparts,pawPref,trialNumbers,all_firstPawDorsumFrame,all_paw_through_slot_frame,all_endPtFrame,validTypeNames,curSession,curSessionType,varargin)

x_lim = [-30 10];
y_lim = [-15 10];
z_lim = [-5 50];

% to plot:
%   mean distance from mean trajectory at each point for all, correct, no
%       pellet, and other trials (along with n)
%   all_firstPawDorsum, all_paw_through_slot_frame, and all_endPtFrame
%   
figProps.m = 5;
figProps.n = 5;

figProps.panelWidth = ones(figProps.n,1) * 10;
figProps.panelHeight = ones(figProps.m,1) * 4;

figProps.colSpacing = ones(figProps.n-1,1) * 0.5;
figProps.rowSpacing = ones(figProps.m-1,1) * 1;

figProps.leftMargin = 2.54;
figProps.topMargin = 5;

figProps.width = sum(figProps.colSpacing) + sum(figProps.panelWidth) + figProps.leftMargin + 2.54;
figProps.height = 12 * 2.54;

numTrialTypes_to_analyze = size(trialTypeIdx,2);


var_lim = [0,5;
           0,5;
           0,10;
           0,10];
pawFrameLim = [0 400];

for iarg = 1 : 2 : nargin - 14
    switch lower(varargin{iarg})
        case 'var_lim'
            var_lim = varargin{iarg + 1};
        case 'pawframelim'
            pawFrameLim = varargin{iarg + 1};
    end
end
[h_fig(1),h_axes{1}] = createFigPanels5(figProps);
% [h_fig(2),h_axes{2}] = createFigPanels5(figProps);

numTrials = length(all_endPtFrame);
% first row
% histogram of paw angles at reach end point
axes(h_axes{1}(1,1));
% binEdges = 0 : pi/20 : 2*pi;

polarhistogram(paw_endAngle,20);
title('paw orientations at reach end')

% paw angle at reach end point as a function of trial #
axes(h_axes{1}(1,2));
plot(trialNumbers(:,2),paw_endAngle);
hold on
plot(trialNumbers(:,2),paw_endAngle + 2*pi);

title('paw orientation at reach end')
set(gca,'ylim',[-pi,3*pi]);
% axes(h_axes{1}(1,2));
% plot(trialNumbers,all_paw_through_slot_frame);
% title('paw through slot frame frame')
% set(gca,'ylim',pawFrameLim);


% plot mean trajectories for each digit, for each joint
for iJoint = 1 : 3
    for iDim = 1 : 3
        axes(h_axes{1}(iJoint + 1,iDim));
        % plot all mean MCP trajectories
        for iDigit = 1 : 4
            curDigit = (iJoint-1)*4 + iDigit;
            toPlot = squeeze(mean_session_digit_trajectories(curDigit,:,iDim,1));
            plot(toPlot)
            hold on
        end
    end
    axes(h_axes{1}(iJoint + 1,4));
    for iDigit = 1 : 4
        curDigit = (iJoint-1)*4 + iDigit;
        toPlot = squeeze(mean_session_digit_trajectories(curDigit,:,:,1));
        plot3(toPlot(:,1),toPlot(:,3),toPlot(:,2))
        hold on
    end
    scatter3(0,0,0,25,'k','o','markerfacecolor','k')
    set(gca,'zdir','reverse','xlim',x_lim,'ylim',z_lim,'zlim',y_lim,...
        'view',[-70,30])
    xlabel('x');ylabel('z');zlabel('y');
end

h_figAxis = zeros(length(h_fig),1);
for iFig = 1 : length(h_fig)
    h_figAxis(iFig) = createFigAxes(h_fig(iFig));
end

textString{1} = sprintf('%s session summary; %s, day %d, %d days left in block', ...
    curSession, curSessionType.type, curSessionType.sessionsInBlock, curSessionType.sessionsLeftInBlock);
textString{2} = 'rows 2-4: mean digit trajectories for MCP, PIP, tips in x, y, z';
textString{3} = '';
axes(h_figAxis(1));
text(figProps.leftMargin,figProps.height-0.75,textString,'units','centimeters','interpreter','none');
            
end    % function
        
% % axes(h_axes{1}(1,3));
% plot(trialNumbers,all_endPtFrame);
% title('event frames')
% set(gca,'ylim',pawFrameLim);
% 
% % final z location as a function of trial #
% [mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
% pd_endPts_z = squeeze(reachEndPoints{1}(pawDorsumIdx,3,:));
% digit_endPts_z = squeeze(reachEndPoints{1}(digIdx(2),3,:));
% axes(h_axes{1}(1,3));
% scatter(trialNumbers,pd_endPts_z);
% hold on
% scatter(trialNumbers,digit_endPts_z);
% legend({'paw dorsum','digit 2'});
% title('z-endpoints')
% 
% % histogram of paw dorsum endpoints
% % [mcp_idx,pip_idx,digit_idx,pawdorsum_idx,nose_idx,pellet_idx,otherpaw_idx] = group_DLC_bodyparts(bodyparts,pawPref);
% axes(h_axes{1}(1,4));
% histogram(pd_endPts_z,10)
% title('paw dorsum z-endpoints')
% set(gca,'xdir','reverse');
% 
% % histogram of second digit endpoints
% axes(h_axes{1}(1,5));
% histogram(digit_endPts_z,10)
% title('2nd digit z-endpoints')
% set(gca,'xdir','reverse');
% 
% 
% 
% mean_dist_from_trajectory = zeros(size(mean_pd_trajectory,1),size(mean_pd_trajectory,2),numTrialTypes_to_analyze);
% mean_euc_dist_from_trajectory = zeros(size(mean_pd_trajectory,1),numTrialTypes_to_analyze);
% 
% for iType = 1 : numTrialTypes_to_analyze
%     numTrials = sum(trialTypeIdx(:,iType));
%     current_mean_trajectory = squeeze(mean_pd_trajectory(:,:,iType));
%     dist_from_trajectory = normalized_pd_trajectories(:,:,trialTypeIdx(:,iType)) - repmat(current_mean_trajectory,1,1,numTrials);
%     euclidean_dist_from_trajectory = sqrt(squeeze(sum(dist_from_trajectory.^2,2)));
%     mean_dist_from_trajectory(:,:,iType) = nanmean(abs(dist_from_trajectory),3);
%     mean_euc_dist_from_trajectory(:,iType) = nanmean(euclidean_dist_from_trajectory,2);
%     
%     for iDir = 1 : 3
%         axes(h_axes{1}(iDir+1,iType))
%         toPlot = squeeze(mean_dist_from_trajectory(:,iDir,iType));
%         plot(toPlot)
%         set(gca,'ylim',var_lim(iDir,:));
%         title(validTypeNames{iType})
%         if iType == 1
%             switch iDir
%                 case 1
%                     ylabel('x')
%                 case 2
%                     ylabel('y')
%                 case 3
%                     ylabel('z')
%             end
%         end
%     end
%     axes(h_axes{1}(5,iType))
%     toPlot = squeeze(mean_euc_dist_from_trajectory(:,iType));
%     plot(toPlot)
%     set(gca,'ylim',var_lim(4,:));
%     title(validTypeNames{iType})
%     ylabel('euc dist')
% %     plot(mean_dist_from_trajectory
% end
% 
% end
%         