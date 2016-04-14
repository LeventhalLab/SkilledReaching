function plotXYZtraj(meanTraj, varTraj, triggerFrame, frameRate, varargin)
%
%
% INPUTS:
%
h_axes = [];
plotColor = 'k';
errorAlpha = 0.5;

ylim = [-15 15
        -10 15
        190 235];
tlim = [-0.25,0.4];

slot_z = [];

for iarg = 1 : 2 : nargin - 4
    
    switch lower(varargin{iarg})
        
        case 'axes',
            h_axes = varargin{iarg + 1};
        case 'color',
            plotColor = varargin{iarg + 1};
        case 'erroralpha',
            errorAlpha = varargin{iarg + 1};
        case 'slot_z',
            slot_z = varargin{iarg + 1};
            
    end
    
end

if isempty(h_axes)
    figure;
    h_axes = zeros(3,1);
    for i_axes = 1 : 3
        h_axes(i_axes) = subplot(3,1,i_axes);
    end
end

min_t = -triggerFrame/frameRate;
max_t = min_t + (length(meanTraj) / frameRate);
t = linspace(min_t,max_t,length(meanTraj));

for i_axes = 1 : length(h_axes)
    if i_axes == 2
        set(gca,'ydir','reverse');
    end
    axes(h_axes(i_axes));
    hold on;
    shadedErrorBar(t,meanTraj(:,i_axes),varTraj(:,i_axes),...
                   {'color',plotColor},0.5);
	line([0,0],[ylim(i_axes,1),ylim(i_axes,2)],'color','k')
    if i_axes == 2
        set(gca,'ydir','reverse');
    end
    if i_axes == 3 && ~isempty(slot_z)
        line(tlim,[slot_z,slot_z],'color','k')
    end
    
    set(gca,'ylim',ylim(i_axes,:),'xlim',tlim);
%     plot(t, meanTraj(:,i_axes));
%     hold on
end
    