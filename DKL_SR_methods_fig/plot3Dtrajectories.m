function plot3Dtrajectories(x,y,z,varargin)

slot_z = 175;

h_axes = 0;
plotCol = 'k';
fadeColor = false;
showIndTraj = true;
showMean = true;
meanWeight = 2;
indTrajWeight = 0.5;
onlyValidFrames = true;

for iarg = 1 : 2 : nargin - 3
    
    switch lower(varargin{iarg})
        case 'axes',
            h_axes = varargin{iarg + 1};
        case 'color',
            plotCol = varargin{iarg + 1};
        case 'fadecolor',
            fadeColor = varargin{iarg + 1};
        case 'showmean',
            showMean = varargin{iarg + 1};
        case 'showindtraj',
            showIndTraj = varargin{iarg + 1};
        case 'meanweight',
            meanWeight = varargin{iarg + 1};
        case 'onlyvalidframes',
            onlyValidFrames = varargin{iarg + 1};
        case 'slot_z',
            slot_z = varargin{iarg + 1};
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

if showIndTraj
    for i_plot = 1 : length(x)

        plot3(x{i_plot},y{i_plot},z{i_plot},...
              'color',plotCol,...
              'linewidth',indTrajWeight);
        xlabel('x');
        ylabel('y');
        zlabel('z');
        hold on
    end
end

if showMean
    
    plot3(meanTrajectory(validFrames,1),...
          meanTrajectory(validFrames,2),...
          meanTrajectory(validFrames,3),...
          'color',plotCol, ...
          'linewidth',meanWeight);
end

set(gca,'ydir','reverse')