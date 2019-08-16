function [h_fig,h_axes,h_figAxis] = plotSessionDigitSummary(trialTypeIdx,paw_endAngle,mean_session_digit_trajectories,pawOrientationTrajectories,meanOrientations,mean_MRL,apertureTrajectories,endApertures,meanApertures,varApertures,mean_xyz_from_dig_session_trajectories,mean_euc_from_dig_session_trajectories,bodyparts,pawPref,trialNumbers,all_firstPawDorsumFrame,all_paw_through_slot_frame,all_endPtFrame,validTypeNames,curSession,curSessionType,thisRatInfo,varargin)

x_lim = [-30 10];
y_lim = [-15 10];
z_lim = [-5 50];
apertureLims = [0 25];

virus = thisRatInfo.Virus;
if iscell(virus)
    virus = virus{1};
end
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

for iarg = 1 : 2 : nargin - 22
    switch lower(varargin{iarg})
        case 'var_lim'
            var_lim = varargin{iarg + 1};
        case 'pawframelim'
            pawFrameLim = varargin{iarg + 1};
        case 'x_lim'
            x_lim = varargin{iarg + 1};
        case 'y_lim'
            y_lim = varargin{iarg + 1};
        case 'z_lim'
            z_lim = varargin{iarg + 1};
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

% overlay paw angles for each trajectory
axes(h_axes{1}(1,3));
for iTrial = 1 : length(pawOrientationTrajectories)
    plot(pawOrientationTrajectories{iTrial})
    hold on
%     plot(pawOrientationTrajectories{iTrial} + 2*pi)
end
plot(meanOrientations,'color','k','linewidth',2)
% plot(meanOrientations+2*pi,'color','k','linewidth',2)
title('paw orientation after slot vs frame')
set(gca,'ylim',[-pi,pi]);

axes(h_axes{1}(1,4));
plot(mean_MRL)
title('mean paw orientation MRL after slot vs frame')
% plot(trialNumbers,all_paw_through_slot_frame);
% title('paw through slot frame frame')
% set(gca,'ylim',pawFrameLim);

axes(h_axes{1}(1,5));
for iTrial = 1 : length(apertureTrajectories)
    curApertureTrajectory = apertureTrajectories{iTrial};
    toPlot = sqrt(sum(curApertureTrajectory.^2,2));
    plot(toPlot);
    hold on
end
plot(meanApertures,'color','k','linewidth',2);
plot(meanApertures+varApertures,'k:');
plot(meanApertures-varApertures,'k:');
set(gca,'ylim',apertureLims);
title('aperture vs frames')

axes(h_axes{1}(2,5));
toPlot = sqrt(sum(endApertures.^2,2));
plot(trialNumbers(:,2),toPlot);
title('aperture at reach end vs trials')
set(gca,'ylim',apertureLims);

% plot mean trajectories for each digit, for each joint
for iJoint = 1 : 3
    for iDim = 1 : 3
        axes(h_axes{1}(iJoint + 1,iDim));
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

textString{1} = sprintf('%s session summary; %s (%s on score sheet), day %d, %d days left in block, Virus: %s', ...
    curSession, curSessionType.type, curSessionType.typeFromScoreSheet, curSessionType.sessionsInBlock, curSessionType.sessionsLeftInBlock,virus);
textString{2} = 'rows 2-4: mean digit trajectories for MCP, PIP, tips in x, y, z';
textString{3} = '';
axes(h_figAxis(1));
text(figProps.leftMargin,figProps.height-0.75,textString,'units','centimeters','interpreter','none');
            
end    % function
          