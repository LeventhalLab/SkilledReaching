function [meanTrajectory,stdTrajectory,numValidTraj,new_alignmentFrame,slot_z] = plotSessionTrajectories(sr_ratInfo, sessionName, scores, varargin)
%
% INPUTS:
%   sr_ratInfo - single element of the sr_ratInfo structure output by
%       get_sr_RatList
%   sessionName - string in 'YYYYMMDDa' format (a can be "a", "b", etc.)
%   scores - vector containing scores to include in the plot (e.g., [1] for
%      first reach success, [1,2] for any successful reach, etc.
%
%
% OUTPUTS:
%

meanTrajectory = [];

h_axes = 0;
indTrialCol = 'b';
meanCol = 'b';
fadeColor = false;
showIndTraj = true;
indTrajAlpha = 0.3;
showMean = true;
meanWeight = 2;
indTrajWeight = 0.5;
meanAlpha = 1;
onlyValidFrames = true;

showSlot = true;
showShelf = true;
slotHeight = 50;
slotColor = 'k';
slotAlpha = 0.2;

shelfWidth = 100;
minTrajHeight = 15;

K = [];
computeCamParams = false;
camParamFile = '/Users/dleventh/Documents/Leventhal_lab_github/SkilledReaching/Manual Tracking Analysis/ConvertMarkedPointsToReal/cameraParameters.mat';
cb_path = '/Users/dleventh/Documents/Leventhal_lab_github/SkilledReaching/tattoo_track_testing/intrinsics calibration images';

numVirtualFrames = 1500;
alignToFrame = 750;

% parameters for adjusting view
switch sr_ratInfo.pawPref
    case 'right',
        camView = [85 225];
    case 'left',
        camView = [-60 20];
end

camUpVector = [0 -1 0];
xLimits = [-15 15];
yLimits = [-20 30];
zLimits = [185 240];

excludePoints = {'left_bottom_box_corner','right_bottom_box_corner'};
% above line is points to ignore when computing box calibration

for iarg = 1 : 2 : nargin - 3
    
    switch lower(varargin{iarg})
        case 'axes',
            h_axes = varargin{iarg + 1};
        case 'indtrialcol',
            indTrialCol = varargin{iarg + 1};
        case 'meancol',
            meanCol = varargin{iarg + 1};
        case 'fadecolor',
            fadeColor = varargin{iarg + 1};
        case 'showmean',
            showMean = varargin{iarg + 1};
        case 'showindtraj',
            showIndTraj = varargin{iarg + 1};
        case 'meanweight',
            meanWeight = varargin{iarg + 1};
        case 'indtrajweight',
            indTrajWeight = varargin{iarg + 1};
        case 'indtrajalpha',
            indTrajAlpha = varargin{iarg + 1};
        case 'onlyvalidframes',
            onlyValidFrames = varargin{iarg + 1};
        case 'slot_z',
            slot_z = varargin{iarg + 1};
        case 'xlim',
            xLimits = varargin{iarg + 1};
        case 'ylim',
            yLimits = varargin{iarg + 1};
        case 'zlim',
            zLimits = varargin{iarg + 1};
        case 'showslot',
            showSlot = varargin{iarg + 1};
        case 'showshelf',
            showShelf = varargin{iarg + 1};
        case 'slotcoords',
            slotCoords = varargin{iarg + 1};
        case 'slotalpha',
            slotAlpha = varargin{iarg + 1};
        case 'slotcolor',
            slotColor = varargin{iarg + 1};
        case 'camview',
            camView = varargin{iarg + 1};
        case 'camupvector',
            camUpVector = varargin{iarg + 1};
        case 'excludepoints',
            excludePoints = varargin{iarg + 1};
        case 'mintrajectoryheight',
            minTrajHeight = varargin{iarg + 1};
        case 'numvirtualframes',
            numVirtualFrames = varargin{iarg + 1};
    end
      
end   % for iarg...

if isempty(K)
    if computeCamParams
        [cameraParams, ~, ~] = cb_calibration(...
                               'cb_path', cb_path, ...
                               'num_rad_coeff', num_rad_coeff, ...
                               'est_tan_distortion', est_tan_distortion, ...
                               'estimateskew', estimateSkew);
    else
        load(camParamFile);    % contains a cameraParameters object named cameraParams
    end
    K = cameraParams.IntrinsicMatrix;   % camera intrinsic matrix (matlab format, meaning lower triangular
                                        %       version - Hartley and Zisserman and the rest of the world seem to
                                        %       use the transpose of matlab K)
end

ratID = sr_ratInfo.ID;
            
processed_rootDir = sr_ratInfo.directory.processed;
rawdata_rootDir = sr_ratInfo.directory.rawdata;

reconstructionName = [ratID '_' sessionName '_trajectories.mat'];
processedDir = [ratID '_' sessionName];
reconstructionName = fullfile(processed_rootDir, processedDir, reconstructionName);

load(reconstructionName);

srCal = trajectory_metadata.session_srCal;
switch sr_ratInfo.pawPref
    case 'right',
        sf = mean(srCal.sf(:,1),1);
    case 'left',
        sf = mean(srCal.sf(:,2),1);
end
scaled_points3d = points3d * sf;
% [x1_left,x2_left,x1_right,x2_right,~,~] = ...
%     sr_sessionMatchedPointVector(session_mp, 'excludepoints', excludePoints);

session_mp = trajectory_metadata.matchedCalPoints;

% [x1_left,x2_left,x1_right,x2_right,~,~] = ...
%     sr_sessionMatchedPointVector(session_mp, 'excludepoints', excludePoints);
% srCal = sr_calibration(x1_left,x2_left,x1_right,x2_right, 'intrinsicmatrix', K);

% srCal = sr_calibration_mp(session_mp, 'intrinsicmatrix', K);

slotPoints = slot3dcoords(session_mp, 'srcal', srCal, 'intrinsicmatrix', K);
slot_z = mean(slotPoints(:,3));
z = squeeze(scaled_points3d(:,3,:));
slotCrossFrames = DKL_slotCrossFrames(z, 'slot_z', slot_z);

csv_scores = trajectory_metadata.csv_scores(~isnan(trajectory_metadata.csv_scores));
validTrialIdx = ismember(csv_scores,scores)';
% validTrialIdx = ismember(trajectory_metadata.csv_scores,scores);
validTrialIdx = find(validTrialIdx & ~isnan(slotCrossFrames));    % get rid of reaches where the paw centroid doesn't reach the slot
% validTrialNumbers = ismember(trajectory_metadata.trial_numbers, validTrialIdx);
% validTrialNumbers = find(validTrialNumbers & ~isnan(slotCrossFrames));    % get rid of reaches where the paw centroid doesn't reach the slot

numValidTrials = length(validTrialIdx);

aligned_trajectories = alignTrajectoriesToFrame(scaled_points3d(:,:,validTrialIdx),slotCrossFrames(validTrialIdx),...
                                                'numvirtframes',numVirtualFrames,...
                                                'aligntoframe',alignToFrame);
[single_reach_points, new_alignmentFrame] = ...
    restrictAnalysisToOneReach(aligned_trajectories, alignToFrame, minTrajHeight);
[meanTrajectory,stdTrajectory,numValidTraj] = calcAverageTrajectory(single_reach_points,...
                                                                'alignmentframes',ones(numValidTrials,1)*new_alignmentFrame,...
                                                                'aligntrajectories',false);
% try
%     [meanTrajectory,stdTrajectory,numValidTraj] = calcAverageTrajectory(scaled_points3d(:,:,validTrialNumbers),...
%                                                                     'alignmentframes',slotCrossFrames(validTrialNumbers));
% catch
%     keyboard
% end

% plot individual trials
if h_axes == 0
    figure;
else
    axes(h_axes);
end
hold on

h_indTrial = zeros(1,numValidTrials);
if showIndTraj
    for iTrial = 1 : numValidTrials
        try
%             toPlot = scaled_points3d(:,:,validTrialNumbers(iTrial));
            toPlot = single_reach_points;
        catch
            keyboard;
        end
        
%         alpha_values = linspace(0,1,10)';
        
%         h_indTrial(iTrial) = patch(toPlot(:,1),toPlot(:,3),toPlot(:,2),indTrialCol,...
%                                    'edgecolor',indTrialCol, ....
%                                    'linewidth',indTrajWeight, ...
%                                    'edgealpha',indTrajAlpha);
          h_indTrial(iTrial) = plot3(toPlot(:,1),toPlot(:,3),toPlot(:,2),...
                                     'color',indTrialCol,...
                                     'linewidth',indTrajWeight);
%                                    'facevertexalphadata',alpha_values,...
%                                    'edgealpha','interp');
        view(3)
                       
%         set(h_indTrial(iTrial),'edgealpha',0.5);
                       
        xlabel('x');
        ylabel('z');
        zlabel('y');

    end
end


if showMean
%     h_meanTraj = patch(meanTrajectory(:,1),meanTrajectory(:,3),meanTrajectory(:,2),indTrialCol,...
%                        'edgecolor',meanCol, ....
%                        'linewidth',meanWeight, ...
%                        'edgealpha',meanAlpha);
                   
    h_meanTraj = plot3(meanTrajectory(:,1),meanTrajectory(:,3),meanTrajectory(:,2),...
                       'color',meanCol, ...
                       'linewidth',meanWeight);
end

if showSlot
    slotCoords = generateSlotCoords(slotPoints, slotHeight);
    h_slot = patch(slotCoords(:,1),slotCoords(:,3),slotCoords(:,2),slotColor);
    set(h_slot,'facealpha',slotAlpha);
end

if showShelf
    shelfCoords = generateShelfCoords(session_mp, srCal, K, shelfWidth);
end
set(gca,'xlim',xLimits,'ylim',zLimits,'zlim',yLimits);
view(camView);
set(gca,'zdir','reverse')
% set(gca,'cameraupvector',camUpVector);


end    % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function slotCoords = generateSlotCoords(slotPoints, slotHeight)

slotCoords = zeros(5,3);
slotCoords(1,:) = slotPoints(1,:);
slotCoords(2,:) = slotPoints(1,:) - [0 slotHeight 0];
slotCoords(3,:) = slotPoints(2,:) - [0 slotHeight 0];
slotCoords(4,:) = slotPoints(2,:);
slotCoords(5,:) = slotPoints(1,:);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function shelfCoords = generateShelfCoords(session_mp, srCal, K, shelfWidth)

shelfCoords = zeros(5,3);
% WORK ON FUNCTION TO FIGURE OUT COORDINATES OF SHELF CORNERS

end