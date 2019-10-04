function plotSessionReachSummaries(reachData, trialNumbers, all_slot_z_wrt_pellet, varargin)

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

[h_fig,h_axes] = createFigPanels5(figProps);

% first row of plots: 
%   column 1: breakdown of trial outcomes
%   column 2: number of reaches in each trial
%   column 3: "event frames" - frames at which paw dorsum is first seen, 
%       paw breaches slot, 1st reach end framez-endpoints vs trial #
%   column 4: z-end points of each reach (paw and digit 2)
%   column 5: 3-D of reach endpoints, color coded by trial type

% ROW 2
% column 1: 
% column 2: paw orientation for 1st reach in each trial
% column 3: aperture at end of 1st reach in each trial


% second row of plots
%   overlay 3D trajectories for each trial type across each column


numTrials = length(reachData);

trialTypeColors = {'k','y','b','r','g','c','m'};
validTrialTypes = {0:10,1,2,[3,4,7],0,11,6};
validTypeNames = {'all','1st success','any success','failed','no pellet','paw through slot','no reach'};

% breakdown of trial outcomes
[score_breakdown,ind_trial_type] = breakDownTrialScores(reachData,validTrialTypes);
h_scoreBreakdown = plotTrialOutcomeBreakdown(score_breakdown,trialTypeColors,h_axes(1,1));
set(gca,'ylim',[0 100])
title('trial outcomes')
ylabel('number of trials');
legend(validTypeNames)

% number of reaches
plotNumReaches(reachData,trialNumbers,ind_trial_type,trialTypeColors,h_axes(1,2));
set(gca,'ylim',[0 10])

% event frames
plotEventFrames(reachData,trialNumbers,h_axes(1,3))
    
% z at reach end points
plot_z_endpoints(reachData,trialNumbers,ind_trial_type,trialTypeColors,all_slot_z_wrt_pellet,h_axes(1,4));

% 3D endpoints
plot_3D_endpoints(reachData,trialNumbers,ind_trial_type,trialTypeColors,h_axes(1,5));
end

%%%%%%%%%%%%%%%%%% ROW 2


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h_scoreBreakdown = plotTrialOutcomeBreakdown(score_breakdown,trialTypeColors,h_axes)

axes(h_axes);
h_scoreBreakdown = zeros(length(score_breakdown),1);
for ii = 1 : length(score_breakdown)
    h_scoreBreakdown(ii) = bar(ii,score_breakdown(ii),'facecolor',trialTypeColors{ii});
    hold on
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotNumReaches(reachData,trialNumbers,ind_trial_type,trialTypeColors,h_axes)

axes(h_axes);
numTrials = length(reachData);
num_reaches_per_trial = zeros(numTrials,1);
for iTrial = 1 : numTrials
    num_reaches_per_trial(iTrial) = length(reachData(iTrial).reachEnds);
end

for ii = 1 : max(ind_trial_type)
    if any(ind_trial_type == ii)
        scatter(trialNumbers(ind_trial_type==ii,2),num_reaches_per_trial(ind_trial_type==ii),...
            'markerfacecolor',trialTypeColors{ii},'markeredgecolor',trialTypeColors{ii});
        hold on
    end
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotEventFrames(reachData,trialNumbers,h_axes)

axes(h_axes);
numTrials = length(reachData);
all_frames = zeros(3,numTrials);
for iTrial = 1 : numTrials
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

plot(trialNumbers(:,2),all_frames(1,:),'b')
hold on
plot(trialNumbers(:,2),all_frames(2,:),'r')
plot(trialNumbers(:,2),all_frames(3,:),'g')

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_z_endpoints(reachData,trialNumbers,ind_trial_type,trialTypeColors,all_slot_z_wrt_pellet,h_axes)

axes(h_axes)

numTrials = length(reachData);
pd_z_endpt = zeros(numTrials,1);
dig2_z_endpt = zeros(numTrials,1);
for iTrial = 1 : numTrials
    pd_z_endpt(iTrial) = reachData(iTrial).pdEndPoints(1,3);
    dig2_z_endpt(iTrial) = reachData(iTrial).dig2_endPoints(1,3);
end

for ii = 1 : max(ind_trial_type)
    if any(ind_trial_type == ii)
        scatter(trialNumbers(ind_trial_type==ii,2),pd_z_endpt(ind_trial_type==ii),...
            'markerfacecolor',trialTypeColors{ii},'markeredgecolor',trialTypeColors{ii},...
            'markerfacealpha',0.5,'markeredgealpha',0.5);
        hold on
        scatter(trialNumbers(ind_trial_type==ii,2),dig2_z_endpt(ind_trial_type==ii),...
            'markerfacecolor',trialTypeColors{ii},'markeredgecolor',trialTypeColors{ii},...
            'markerfacealpha',1,'markeredgealpha',1);
    end
end

slot_z_wrt_pellet = nanmean(all_slot_z_wrt_pellet);
line([0 max(trialNumbers(:,2))],[slot_z_wrt_pellet,slot_z_wrt_pellet])

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_3D_endpoints(reachData,trialNumbers,ind_trial_type,trialTypeColors,h_axes)

x_lim = [-30 10];
y_lim = [-20 5];
z_lim = [-15 10];

axes(h_axes)

numTrials = length(reachData);
pd_z_endpt = zeros(numTrials,3);
dig2_z_endpt = zeros(numTrials,3);
for iTrial = 1 : numTrials
    pd_endpt(iTrial,:) = reachData(iTrial).pdEndPoints(1,:);
    dig2_endpt(iTrial,:) = reachData(iTrial).dig2_endPoints(1,:);
end

for ii = 1 : max(ind_trial_type)
    if any(ind_trial_type == ii)
        validTrialIdx = (ind_trial_type == ii);
        scatter3(pd_endpt(validTrialIdx,1),pd_endpt(validTrialIdx,3),pd_endpt(validTrialIdx,2),...
            'markerfacecolor',trialTypeColors{ii},'markeredgecolor',trialTypeColors{ii},...
            'markerfacealpha',0.5,'markeredgealpha',0.5);
        hold on
        scatter3(dig2_endpt(validTrialIdx,1),dig2_endpt(validTrialIdx,3),dig2_endpt(validTrialIdx,2),...
            'markerfacecolor',trialTypeColors{ii},'markeredgecolor',trialTypeColors{ii},...
            'markerfacealpha',1,'markeredgealpha',1);
    end
end

scatter3(0,0,0,'marker','*','markerfacecolor','k','markeredgecolor','k');
set(gca,'zdir','reverse','xlim',x_lim,'ylim',z_lim,'zlim',y_lim,...
    'view',[-70,30])
xlabel('x');ylabel('z');zlabel('y');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%