function h_fig = plotSessionReachSummaries(reachData, all_slot_z_wrt_pellet, thisRatInfo, sessionName, sessionType, varargin)

% REACHING SCORES:
%
% 0 - No pellet, mechanical failure
% 1 -  First trial success (obtained pellet on initial limb advance)
% 2 -  Success (obtain pellet, but not on first attempt)
% 3 -  Forelimb advance -pellet dropped in box
% 4 -  Forelimb advance -pellet knocked off shelf
% 5 -  Obtain pellet with tongue
% 6 -  Walk away without forelimb advance, no forelimb advance
% 7 -  Reached, pellet remains on shelf
% 8 - Used only contralateral paw
% 9 - Laser fired at the wrong time
% 10 ?Used preferred paw after obtaining or moving pellet with tongue
% 11 - paw started out through the slot

full_traj_z_lim = [-5 50];
reachEnd_zlim = [-15 10];

pawPref = char(thisRatInfo.pawPref);
figProps.m = 5;
figProps.n = 5;

figProps.panelWidth = ones(figProps.n,1) * 10;
figProps.panelHeight = ones(figProps.m,1) * 4;

figProps.colSpacing = ones(figProps.n-1,1) * 1;
figProps.rowSpacing = ones(figProps.m-1,1) * 1.5;

figProps.leftMargin = 2.54;
figProps.topMargin = 5;

figProps.width = sum(figProps.colSpacing) + sum(figProps.panelWidth) + figProps.leftMargin + 2.54;
figProps.height = sum(figProps.rowSpacing) + sum(figProps.panelHeight) + figProps.topMargin + 2.54;

[h_fig,h_axes] = createFigPanels5(figProps);

% first row of plots: 
%   column 1: breakdown of trial outcomes
%   column 2: number of reaches in each trial
%   column 3: "event frames" - frames at which paw dorsum is first seen, 
%       paw breaches slot, 1st reach end framez-endpoints vs trial #
%   column 4: z-end points of each reach (paw and digit 2)
%   column 5: 3-D of reach endpoints, color coded by trial type

% ROW 2
% column 1: paw orientation at end of each reach
% column 2: paw orientation for 1st reach in each trial
% column 3: aperture at end of 1st reach in each trial


% second row of plots
%   overlay 3D trajectories for each trial type across each column

% reach velocity profiles

numTrials = length(reachData);

trialTypeColors = {'k','g','b','r','y','c','m'};
validTrialTypes_for_outcomes = {0:10,1,[1,2],[3,4,7],0,11,6};
validTrialTypes = {0:10,1,2,[3,4,7],0,11,6};
validTypeNames = {'all','1st success','any success','failed','no pellet','paw through slot','no reach'};

% breakdown of trial outcomes
[score_breakdown,~] = breakDownTrialScores(reachData,validTrialTypes_for_outcomes);
h_scoreBreakdown = plotTrialOutcomeBreakdown(score_breakdown,trialTypeColors,h_axes(1,1));
set(gca,'ylim',[0 100])
ylabel('number of trials');
legend(validTypeNames)

% repeat for subsequent plots so first and any success aren't plotted over
% each other
[~,ind_trial_type] = breakDownTrialScores(reachData,validTrialTypes);

% number of reaches
plotNumReaches(reachData,ind_trial_type,trialTypeColors,h_axes(1,2));
set(gca,'ylim',[0 10])

% event frames
plotEventFrames(reachData,h_axes(1,3))
    
% z at reach end points
plot_z_endpoints(reachData,ind_trial_type,trialTypeColors,all_slot_z_wrt_pellet,h_axes(1,4));

% 3D endpoints
plot_3D_endpoints(reachData,ind_trial_type,trialTypeColors,pawPref,h_axes(1,5),reachEnd_zlim);

%%%%%%%%%%%%%%%%%% ROW 2
% 3-D trajectories
plot_3DreachTrajectories(reachData,ind_trial_type,trialTypeColors,pawPref,h_axes(2,5),full_traj_z_lim);

% x,y,z trajectories
% plot_reachTrajectories(reachData,ind_trial_type,trialTypeColors,h_axes(2,1));

% histogram of reach orientations at reach end points by trial type
hist_z_endPoints(reachData,ind_trial_type,trialTypeColors,h_axes(2,4));

%%%%%%%%%%%%%%%%%%% ROW 3
% paw velocity
plot_pawVelocityProfiles(reachData,ind_trial_type,trialTypeColors,h_axes(3,1),full_traj_z_lim);

% mean paw velocity by trial type

plot_meanPawVelocityProfiles(reachData,ind_trial_type,trialTypeColors,h_axes(3,2),full_traj_z_lim)
%%%%%%%%%%%%%%%%%% ROW 4
% reach orientation at reach end point
plot_endReachOrientation(reachData,ind_trial_type,trialTypeColors,h_axes(4,1));

% histogram of reach orientations at reach end points by trial type
hist_endReachOrientation(reachData,ind_trial_type,trialTypeColors,h_axes(4,2));

% reach orientation post-slot
plot_reachOrientation(reachData,ind_trial_type,trialTypeColors,h_axes(4,3))

% mean reach orientation across trial types
plot_meanReachOrientation(reachData,ind_trial_type,trialTypeColors,h_axes(4,4))

%%%%%%%%%%%%%%%%%% ROW 5
% digit aperture at reach end point
plot_endReachAperture(reachData,ind_trial_type,trialTypeColors,h_axes(5,1));

hist_endReachAperture(reachData,ind_trial_type,trialTypeColors,h_axes(5,2));

% digit aperture post-slot
plot_digitApertures(reachData,ind_trial_type,trialTypeColors,h_axes(5,3))

plot_meanDigitApertures(reachData,ind_trial_type,trialTypeColors,h_axes(5,4))

h_figAxis = createFigAxes(h_fig);

textString{1} = sprintf('%s session summary; %s, day %d, %d days left in block, Virus: %s', ...
    sessionName, sessionType.type, sessionType.sessionsInBlock, sessionType.sessionsLeftInBlock, char(thisRatInfo.Virus));
% textString{2} = 'rows 2-4: mean absolute difference from mean trajectory in x, y, z for each trial type';
% textString{3} = 'row 5: mean euclidean distance from mean trajectory for each trial type';
axes(h_figAxis);
text(figProps.leftMargin,figProps.height-0.75,textString,'units','centimeters','interpreter','none');
% plot_firstReachDuration(reachData,trialNumbers,ind_trial_type,trialTypeColors,h_axes(3,1));

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h_scoreBreakdown = plotTrialOutcomeBreakdown(score_breakdown,trialTypeColors,h_axes)

axes(h_axes);
h_scoreBreakdown = zeros(length(score_breakdown),1);
for ii = 1 : length(score_breakdown)
    h_scoreBreakdown(ii) = bar(ii,score_breakdown(ii),'facecolor',trialTypeColors{ii});
    hold on
end
title('trial outcomes')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotNumReaches(reachData,ind_trial_type,trialTypeColors,h_axes)

axes(h_axes);
numTrials = length(reachData);
num_reaches_per_trial = zeros(numTrials,1);
trialNumbers = zeros(numTrials,1);
for iTrial = 1 : numTrials
    num_reaches_per_trial(iTrial) = length(reachData(iTrial).reachEnds);
    trialNumbers(iTrial) = reachData(iTrial).trialNumbers(2);
end

for ii = 1 : max(ind_trial_type)
    if any(ind_trial_type == ii)
        scatter(trialNumbers(ind_trial_type==ii),num_reaches_per_trial(ind_trial_type==ii),...
            'markerfacecolor',trialTypeColors{ii},'markeredgecolor',trialTypeColors{ii});
        hold on
    end
end
title('num reaches per trial')

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotEventFrames(reachData,h_axes)

axes(h_axes);
numTrials = length(reachData);
trialNumbers = zeros(numTrials,1);
all_frames = zeros(3,numTrials);
for iTrial = 1 : numTrials
    trialNumbers(iTrial) = reachData(iTrial).trialNumbers(2);
    if ~isempty(reachData(iTrial).reachStarts)
        all_frames(1,iTrial) = reachData(iTrial).reachStarts(1);
    end
    if ~isempty(reachData(iTrial).slotBreachFrame)
        all_frames(2,iTrial) = reachData(iTrial).slotBreachFrame(1);
    end
    if ~isempty(reachData(iTrial).reachEnds)
        all_frames(3,iTrial) = reachData(iTrial).reachEnds(1);
    end
end

plot(trialNumbers,all_frames(1,:),'b')
hold on
plot(trialNumbers,all_frames(2,:),'r')
plot(trialNumbers,all_frames(3,:),'g')

title('reach start,slot breach,reach end frames')

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_z_endpoints(reachData,ind_trial_type,trialTypeColors,all_slot_z_wrt_pellet,h_axes)

axes(h_axes)

[trialNumbers,pd_endPts, dig2_endPts] = extractReachEndPoints(reachData);
pd_z_endpt = pd_endPts(:,3);
dig2_z_endpt = dig2_endPts(:,3);

for ii = 1 : max(ind_trial_type)
    if any(ind_trial_type == ii)
        scatter(trialNumbers(ind_trial_type==ii),pd_z_endpt(ind_trial_type==ii),...
            'markerfacecolor',trialTypeColors{ii},'markeredgecolor',trialTypeColors{ii},...
            'markerfacealpha',0.5,'markeredgealpha',0.5);
        hold on
        scatter(trialNumbers(ind_trial_type==ii),dig2_z_endpt(ind_trial_type==ii),...
            'markerfacecolor',trialTypeColors{ii},'markeredgecolor',trialTypeColors{ii},...
            'markerfacealpha',1,'markeredgealpha',1);
    end
end

slot_z_wrt_pellet = nanmean(all_slot_z_wrt_pellet);
line([0 max(trialNumbers)],[slot_z_wrt_pellet,slot_z_wrt_pellet])

title('reach end z')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_3D_endpoints(reachData,ind_trial_type,trialTypeColors,pawPref,h_axes,reachEnd_zlim)

x_lim = [-30 10];
y_lim = [-20 5];

axes(h_axes)

[~,pd_endpt, dig2_endpt] = extractReachEndPoints(reachData);

for ii = 1 : max(ind_trial_type)
    if any(ind_trial_type == ii)
        validTrialIdx = (ind_trial_type == ii);
        switch pawPref
            case 'left'
                scatter3(-pd_endpt(validTrialIdx,1),pd_endpt(validTrialIdx,3),pd_endpt(validTrialIdx,2),...
                    'markerfacecolor',trialTypeColors{ii},'markeredgecolor',trialTypeColors{ii},...
                    'markerfacealpha',0.5,'markeredgealpha',0.5);
                hold on
                scatter3(-dig2_endpt(validTrialIdx,1),dig2_endpt(validTrialIdx,3),dig2_endpt(validTrialIdx,2),...
                    'markerfacecolor',trialTypeColors{ii},'markeredgecolor',trialTypeColors{ii},...
                    'markerfacealpha',1,'markeredgealpha',1);
            case 'right'
                scatter3(pd_endpt(validTrialIdx,1),pd_endpt(validTrialIdx,3),pd_endpt(validTrialIdx,2),...
                    'markerfacecolor',trialTypeColors{ii},'markeredgecolor',trialTypeColors{ii},...
                    'markerfacealpha',0.5,'markeredgealpha',0.5);
                hold on
                scatter3(dig2_endpt(validTrialIdx,1),dig2_endpt(validTrialIdx,3),dig2_endpt(validTrialIdx,2),...
                    'markerfacecolor',trialTypeColors{ii},'markeredgecolor',trialTypeColors{ii},...
                    'markerfacealpha',1,'markeredgealpha',1);
        end
    end
end

scatter3(0,0,0,25,'marker','*','markerfacecolor','k','markeredgecolor','k');
set(gca,'zdir','reverse','xlim',x_lim,'ylim',reachEnd_zlim,'zlim',y_lim,...
    'view',[-70,30])
xlabel('x');ylabel('z');zlabel('y');

title('3D reach endpoints')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_endReachOrientation(reachData,ind_trial_type,trialTypeColors,h_axes)

axes(h_axes)

[trialNumbers,end_orientation] = extractReachEndOrientation(reachData);

for ii = 1 : max(ind_trial_type)
    if any(ind_trial_type == ii)
        validTrialIdx = (ind_trial_type == ii);
        scatter(trialNumbers(validTrialIdx),end_orientation(validTrialIdx),...
            'markerfacecolor',trialTypeColors{ii},'markeredgecolor',trialTypeColors{ii});
        hold on
    end
end
set(gca,'ylim',[0,pi])
title('paw orientation at reach end')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_reachOrientation(reachData,ind_trial_type,trialTypeColors,h_axes)

axes(h_axes)

traj_limits = align_trajectory_to_reach(reachData);

numTrials = length(reachData);
reach_orientation = cell(numTrials,1);
for iTrial = 1 : numTrials
    
    if isempty(reachData(iTrial).orientation)
        continue;
    end
    if isempty(reachData(iTrial).orientation{1})
        continue;
    end
    
    reach_orientation{iTrial} = reachData(iTrial).orientation{1};
    
    % extract digit 2 z-coordinates that correspond to reach orientation
    % points
    % frame limits for the first reach_to_grasp movement
    graspFrames = traj_limits(iTrial).reach_aperture_lims(1,1) : traj_limits(iTrial).reach_aperture_lims(1,2);
    dig2_z = reachData(iTrial).dig2_trajectory{1}(graspFrames,3);
    plot(dig2_z,reach_orientation{iTrial},trialTypeColors{ind_trial_type(iTrial)});
    hold on
end

set(gca,'ylim',[0,pi])
set(gca,'xdir','reverse')
title('paw orientation')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_endReachAperture(reachData,ind_trial_type,trialTypeColors,h_axes)

axes(h_axes)

numTrials = length(reachData);
trialNumbers = NaN(numTrials,1);
end_aperture = NaN(numTrials,1);
for iTrial = 1 : numTrials
    if isempty(reachData(iTrial).aperture)
        continue;
    end
    if isempty(reachData(iTrial).aperture{1})
        continue;
    end
    end_aperture(iTrial) = reachData(iTrial).aperture{1}(end);
    trialNumbers(iTrial) = reachData(iTrial).trialNumbers(2);
end

for ii = 1 : max(ind_trial_type)
    if any(ind_trial_type == ii)
        validTrialIdx = (ind_trial_type == ii);
        scatter(trialNumbers(validTrialIdx),end_aperture(validTrialIdx),...
            'markerfacecolor',trialTypeColors{ii},'markeredgecolor',trialTypeColors{ii});
        hold on
    end
end
set(gca,'ylim',[5,25])
title('digit aperture at reach end')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_digitApertures(reachData,ind_trial_type,trialTypeColors,h_axes)

axes(h_axes)

traj_limits = align_trajectory_to_reach(reachData);

numTrials = length(reachData);
digit_aperture = cell(numTrials,1);
for iTrial = 1 : numTrials
    if isempty(reachData(iTrial).aperture)
        continue;
    end
    if isempty(reachData(iTrial).aperture{1})
        continue;
    end
    digit_aperture{iTrial} = reachData(iTrial).aperture{1};
    graspFrames = traj_limits(iTrial).reach_aperture_lims(1,1) : traj_limits(iTrial).reach_aperture_lims(1,2);
    dig2_z = reachData(iTrial).dig2_trajectory{1}(graspFrames,3);

    plot(dig2_z,digit_aperture{iTrial},trialTypeColors{ind_trial_type(iTrial)});
    hold on
end

set(gca,'ylim',[5,25])
set(gca,'xdir','reverse')
title('digit aperture')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_firstReachDuration(reachData,ind_trial_type,trialTypeColors,h_axes)

axes(h_axes)

numTrials = length(reachData);
trialNumbers = zeros(numTrials,1);
firstReachDuration = zeros(numTrials,1);
for iTrial = 1 : numTrials
    firstReachDuration(iTrial) = length(reachData(iTrial).aperture{1});
    trialNumbers(iTrial) = reachData(iTrial).trialNumbers(2);
end

for ii = 1 : max(ind_trial_type)
    if any(ind_trial_type == ii)
        validTrialIdx = (ind_trial_type == ii);
        scatter(trialNumbers(validTrialIdx),firstReachDuration(validTrialIdx),...
            'markerfacecolor',trialTypeColors{ii},'markeredgecolor',trialTypeColors{ii});
        hold on
    end
end
set(gca,'ylim',[5,70])
title('frames in aperture calc')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function hist_endReachOrientation(reachData,ind_trial_type,trialTypeColors,h_axes)

axes(h_axes)
binWidth = pi/12;

numTrials = length(reachData);
end_orientation = zeros(numTrials,1);
for iTrial = 1 : numTrials
    if isempty(reachData(iTrial).orientation)
        continue;
    end
    if isempty(reachData(iTrial).orientation{1})
        continue;
    end
    end_orientation(iTrial) = reachData(iTrial).orientation{1}(end);
end

for ii = 1 : max(ind_trial_type)
    if ii == 1
        cur_orientations = end_orientation;
    else
        cur_orientations = end_orientation(ind_trial_type == ii);
    end
    
    polarhistogram(cur_orientations,'binwidth',binWidth,'facecolor','none','edgecolor',trialTypeColors{ii});
    hold on
end

title('paw orientation at reach end')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_meanDigitApertures(reachData,ind_trial_type,trialTypeColors,h_axes)
% 
% INPUTS
%
% OUTPUTS
% 

axes(h_axes)

traj_limits = align_trajectory_to_reach(reachData);

zq = 20:-0.1:-15;
numTrials = length(reachData);
num_trial_types = max(ind_trial_type);

interp_apertures = cell(num_trial_types,1);
for i_trialType = 1 : num_trial_types
    if i_trialType == 1   % this is ALL trials
        num_trials_of_this_type = length(ind_trial_type);
    else
        num_trials_of_this_type = sum(ind_trial_type == i_trialType);
    end
    interp_apertures{i_trialType} = NaN(num_trials_of_this_type,length(zq));
    trialCount = 0;
    for iTrial = 1 : numTrials
        
        if isempty(reachData(iTrial).aperture)
            continue;
        end
        if isempty(reachData(iTrial).aperture{1})
            continue;
        end
    
        if (i_trialType==1) || (ind_trial_type(iTrial) == i_trialType)
            
            trialCount = trialCount + 1;
            graspFrames = traj_limits(iTrial).reach_aperture_lims(1,1) : traj_limits(iTrial).reach_aperture_lims(1,2);
            dig2_z = reachData(iTrial).dig2_trajectory{1}(graspFrames,3);
           
            if length(reachData(iTrial).aperture{1}) > 1
                cur_apertures = pchip(dig2_z,reachData(iTrial).aperture{1},zq);
            else
                cur_apertures = NaN(size(zq));
            end
            cur_apertures(zq < min(dig2_z)) = NaN;
            cur_apertures(zq > max(dig2_z)) = NaN;
            interp_apertures{i_trialType}(trialCount,:) = cur_apertures;
            
        end
            
    end
    
    plot(zq,nanmean(interp_apertures{i_trialType}),trialTypeColors{i_trialType})
    hold on
end

set(gca,'ylim',[5,25])
set(gca,'xdir','reverse')
title('mean digit aperture vs z by reach outcome')

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function hist_endReachAperture(reachData,ind_trial_type,trialTypeColors,h_axes)

axes(h_axes)
aperture_limits = [10,25];
binEdges = aperture_limits(1) : 1 : aperture_limits(2);

numTrials = length(reachData);
end_aperture = zeros(numTrials,1);
for iTrial = 1 : numTrials
    if isempty(reachData(iTrial).aperture)
        continue;
    end
    if isempty(reachData(iTrial).aperture{1})
        continue;
    end
    end_aperture(iTrial) = reachData(iTrial).aperture{1}(end);
end

for ii = 1 : max(ind_trial_type)
    if ii == 1
        cur_apertures = end_aperture;
    else
        cur_apertures = end_aperture(ind_trial_type == ii);
    end
    
    histogram(cur_apertures,'binedges',binEdges,'facecolor','none','edgecolor',trialTypeColors{ii});
    hold on
end

set(gca,'xlim',[10,25])

title('digit aperture at reach end')

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_meanReachOrientation(reachData,ind_trial_type,trialTypeColors,h_axes)

axes(h_axes)

traj_limits = align_trajectory_to_reach(reachData);

zq = 20:-0.1:-15;
numTrials = length(reachData);
num_trial_types = max(ind_trial_type);

interp_orientations = cell(num_trial_types,1);
for i_trialType = 1 : num_trial_types
    if i_trialType == 1   % this is ALL trials
        num_trials_of_this_type = length(ind_trial_type);
    else
        num_trials_of_this_type = sum(ind_trial_type == i_trialType);
    end
    interp_orientations{i_trialType} = NaN(num_trials_of_this_type,length(zq));
    trialCount = 0;
    for iTrial = 1 : numTrials
        
        if isempty(reachData(iTrial).orientation)
            continue
        end
        if isempty(reachData(iTrial).orientation{1})
            continue
        end
        if (i_trialType==1) || (ind_trial_type(iTrial) == i_trialType)
            
            trialCount = trialCount + 1;
            graspFrames = traj_limits(iTrial).reach_aperture_lims(1,1) : traj_limits(iTrial).reach_aperture_lims(1,2);
            dig2_z = reachData(iTrial).dig2_trajectory{1}(graspFrames,3);
            
            
%             or_interp = NaN(length(zq),1);
            if length(reachData(iTrial).orientation{1}) > 1
                cur_orientations = pchip(dig2_z,unwrap(reachData(iTrial).orientation{1}),zq);
            else
                cur_orientations = NaN(size(zq));
            end
            cur_orientations(zq < min(dig2_z)) = NaN;
            cur_orientations(zq > max(dig2_z)) = NaN;
            interp_orientations{i_trialType}(trialCount,:) = cur_orientations;
            
        end
            
    end
    
    plot(zq,nanmean(interp_orientations{i_trialType}),trialTypeColors{i_trialType})
    hold on
end

set(gca,'ylim',[0,pi])
set(gca,'xdir','reverse')
title('mean paw orientation vs z by reach outcome')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function hist_z_endPoints(reachData,ind_trial_type,trialTypeColors,h_axes)

axes(h_axes)
z_limits = [-20,20];
binEdges = z_limits(1) : 1 : z_limits(2);

numTrials = length(reachData);
pd_z_endpt = NaN(numTrials,1);
dig2_z_endpt = NaN(numTrials,1);
for iTrial = 1 : numTrials
    if isempty(reachData(iTrial).pdEndPoints) || isempty(reachData(iTrial).dig2_endPoints)
        continue
    end
    pd_z_endpt(iTrial) = reachData(iTrial).pdEndPoints(1,3);
    dig2_z_endpt(iTrial) = reachData(iTrial).dig2_endPoints(1,3);
end

for ii = 1 : max(ind_trial_type)
    if ii == 1
        cur_dig2_z = dig2_z_endpt;
        cur_pd_z = pd_z_endpt;
    else
        cur_dig2_z = dig2_z_endpt(ind_trial_type == ii);
        cur_pd_z = pd_z_endpt(ind_trial_type == ii);
    end
    
    histogram(cur_dig2_z,'binedges',binEdges,'facecolor','none','edgecolor',trialTypeColors{ii},'edgealpha',1);
    hold on
    histogram(cur_pd_z,'binedges',binEdges,'facecolor','none','edgecolor',trialTypeColors{ii},'edgealpha',0.5);
    
end

set(gca,'xlim',z_limits)
set(gca,'xdir','reverse')

title('endpoint z by trial type')

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_pawVelocityProfiles(reachData,ind_trial_type,trialTypeColors,h_axes,full_traj_z_lim)

axes(h_axes);
numTrials = length(reachData);

for iTrial = 1 : numTrials
    if isempty(reachData(iTrial).pd_v)
        continue;
    end
    if isempty(reachData(iTrial).pd_v{1})
        continue;
    end
    cur_v = reachData(iTrial).pd_v{1};
    cur_v = sqrt(sum(cur_v.^2,2));
    plot(reachData(iTrial).pd_trajectory{1}(1:end-1,3),cur_v,'color',trialTypeColors{ind_trial_type(iTrial)});
    hold on
end

title('tangential paw velocity vs z')
set(gca,'xdir','reverse','ylim',[0 1100],'xlim',full_traj_z_lim)
ylabel('mm/s');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_dig2_velocityProfiles(reachData,ind_trial_type,trialTypeColors,h_axes)

axes(h_axes);
numTrials = length(reachData);

for iTrial = 1 : numTrials
    cur_v = reachData(iTrial).dig2_v{1};
    cur_v = sqrt(sum(cur_v.^2,2));
    plot(reachData(iTrial).dig2_trajectory{1}(1:end-1,3),cur_v,'color',trialTypeColors{ind_trial_type(iTrial)});
    hold on
end

title('tangential digit 2 velocity vs z')
set(gca,'xdir','reverse','ylim',[0 1100])
ylabel('mm/s');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_meanPawVelocityProfiles(reachData,ind_trial_type,trialTypeColors,h_axes,full_traj_z_lim)

zq = 50:-0.5:-15;

axes(h_axes);
numTrials = length(reachData);
num_trial_types = max(ind_trial_type);

interp_v = cell(num_trial_types,1);

for i_trialType = 1 : num_trial_types
    if i_trialType == 1   % this is ALL trials
        num_trials_of_this_type = length(ind_trial_type);
    else
        num_trials_of_this_type = sum(ind_trial_type == i_trialType);
    end
    interp_v{i_trialType} = NaN(num_trials_of_this_type,length(zq));
    
    trialCount = 0;
    for iTrial = 1 : numTrials
        
        if isempty(reachData(iTrial).pd_trajectory)
            continue;
        end
        if isempty(reachData(iTrial).pd_trajectory{1})
            continue;
        end
        if (i_trialType==1) || (ind_trial_type(iTrial) == i_trialType)
            % check that there are enough points to do the interpolation;
            % sometimes, the paw dorsum is hidden/not found prior to the
            % reach; just ignore these trials for now
            
            trialCount = trialCount + 1;
            
            pd_z = reachData(iTrial).pd_trajectory{1}(1:end-1,3);
            cur_v = reachData(iTrial).pd_v{1};
            cur_v = sqrt(sum(cur_v.^2,2));
            try
            cur_v_interp = pchip(pd_z,cur_v,zq);
            catch
                keyboard
            end

            cur_v_interp(zq < min(pd_z)) = NaN;
            cur_v_interp(zq > max(pd_z)) = NaN;
            
            interp_v{i_trialType}(trialCount,:) = cur_v_interp;
        end
        
    end
    plot(zq,nanmean(interp_v{i_trialType}),trialTypeColors{i_trialType})
    hold on

title('mean tangential paw velocity vs z')
set(gca,'xdir','reverse','ylim',[0 1100],'xlim',full_traj_z_lim)
ylabel('mm/s');

end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_3DreachTrajectories(reachData,ind_trial_type,trialTypeColors,pawPref,h_axes,full_traj_z_lim)

x_lim = [-30 10];
y_lim = [-20 10];


axes(h_axes)

numTrials = length(reachData);

for iTrial = 1 : numTrials
    
    if isempty(reachData(iTrial).pd_trajectory)
        continue;
    end
    if isempty(reachData(iTrial).pd_trajectory{1})
        continue;
    end
    switch pawPref
        case 'left'
            try
            plot3(-reachData(iTrial).pd_trajectory{1}(:,1),...
                  reachData(iTrial).pd_trajectory{1}(:,3),...
                  reachData(iTrial).pd_trajectory{1}(:,2),...
                  trialTypeColors{ind_trial_type(iTrial)});
            catch
                keyboard
            end
        case 'right'
            plot3(-reachData(iTrial).pd_trajectory{1}(:,1),...
                  reachData(iTrial).pd_trajectory{1}(:,3),...
                  reachData(iTrial).pd_trajectory{1}(:,2),...
                  trialTypeColors{ind_trial_type(iTrial)});
    end
      hold on
end

scatter3(0,0,0,25,'marker','*','markerfacecolor','k','markeredgecolor','k');
set(gca,'zdir','reverse','xlim',x_lim,'ylim',full_traj_z_lim,'zlim',y_lim,...
    'view',[-70,30])
xlabel('x');ylabel('z');zlabel('y');

title('3D paw trajectories')

end