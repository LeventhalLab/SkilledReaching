function plot3Dtrajectories(x,y,z,varargin)

slot_z = 175;

h_axes = 0;
indTrialCol = 'k';
meanCol = 'k';
fadeColor = false;
showIndTraj = true;
showMean = true;
meanWeight = 2;
indTrajWeight = 0.5;
onlyValidFrames = true;

xLimits = [-10 20];
yLimits = [-10 30];
zLimits = [160 200];

zdist_from_box = 175;

% parameters for drawing the shelf
slotCoords = [-5  30 zdist_from_box
              -5 -10 zdist_from_box
               5 -10 zdist_from_box
               5  30 zdist_from_box
              -5  30 zdist_from_box];
slotAlpha = 0.5;
slotColor = [0.9 0.9 0.9];
showSlot = true;

% parameters for adjusting view
camView = [85 85];
camUpVector = [0 -1 0];
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
        case 'slotcoords',
            slotCoords = varargin{iarg + 1};
        case 'slotalpha',
            slotAlpha = varargin{iarg + 1};
        case 'slotcolor',
            slotColor = varargin{iarg + 1};
        case 'disttoslot',
            zdist_from_box = varargin{iarg + 1};
        case 'camview',
            camView = varargin{iarg + 1};
        case 'camupvector',
            camUpVector = varargin{iarg + 1};
    end
      
end   % for iarg...

if h_axes == 0
    figure;
else
    axes(h_axes);
    hold on
end

[meanTrajectory,varTrajectory,numValidTraj] = calcAverageTrajectory(x,y,z,...
                                                                    'slot_z',slot_z);
if onlyValidFrames
    validFrames = (numValidTraj == max(numValidTraj));   % only use frames where every trajectory is represented
else
    validFrames = 1:size(meanTrajectory,3);
end

h_indTraj = zeros(1,length(x));
if showIndTraj
    for i_plot = 1 : length(x)

        temp = plot3(x{i_plot},y{i_plot},z{i_plot},...
                          'color',indTrialCol,...
                          'linewidth',indTrajWeight);
%         set(h_indTraj(i_plot),'alpha',0.5);
        xlabel('x');
        ylabel('y');
        zlabel('z');
        
        hold on
    end
end

if showMean
    
    h_meanTraj = plot3(meanTrajectory(validFrames,1),...
                       meanTrajectory(validFrames,2),...
                       meanTrajectory(validFrames,3),...
                       'color',meanCol, ...
                       'linewidth',meanWeight);
end


if showSlot
    h_slot = patch(slotCoords(:,1),slotCoords(:,2),slotCoords(:,3),slotColor);
    set(h_slot,'facealpha',slotAlpha);
end

set(gca,'xlim',xLimits,'ylim',yLimits,'zlim',zLimits);
set(gca,'ydir','reverse')
set(gca,'view',camView,'cameraupvector',camUpVector);