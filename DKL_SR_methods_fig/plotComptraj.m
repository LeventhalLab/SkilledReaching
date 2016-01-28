function plotComptraj(trajDiff, triggerFrame, frameRate, varargin)
%
%
% INPUTS:
%
h_axes = [];
plotColor = 'k';
errorAlpha = 0.5;

ylim = [-15 15
        -15 15];
tlim = [-0.25,0.4];
for iarg = 1 : 2 : nargin - 4
    
    switch lower(varargin{iarg})
        
        case 'axes',
            h_axes = varargin{iarg + 1};
        case 'color',
            plotColor = varargin{iarg + 1};
        case 'erroralpha',
            errorAlpha = varargin{iarg + 1};
            
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
max_t = min_t + (length(trajDiff) / frameRate);
t = linspace(min_t,max_t,length(trajDiff));

axes(h_axes(1));    % overlay all 3 differences
for ii = 1 : 3
    plot(t,trajDiff(:,ii));
    hold on
end
set(gca,'ylim',ylim(1,:),'xlim',tlim);

axes(h_axes(2))
diff3d = sqrt(sum(trajDiff.^2,2));
plot(t,diff3d)
set(gca,'ylim',ylim(2,:),'xlim',tlim);


end
    