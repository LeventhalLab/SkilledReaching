function h_axes = plotEndpointRelativeToPellet(all_initPellet3D, all_endPts, validTrials, pawPartsList, valid_bodyparts, varargin)
%
% INPUTS
%
% OUTPUTS

h_axes = [];

pelletMarker = 'o';
pelletMarkerSize = 25;
pelletMarkerColor = 'k';
digitMarker = '+';
digitMarkerSize = 3;
digitMarkerColor = 'b';

if ~iscell(valid_bodyparts)
    valid_bodyparts = {valid_bodyparts};
end

for iarg = 1 : 2 : nargin - 5
    switch lower(varargin{iarg})
        case 'h_axes'
            h_axes = varargin{iarg + 1};
        case 'pelletmarker'
            pelletMarker = varargin{iarg + 1};
        case 'pelletmarkersize'
            pelletMarkerSize = varargin{iarg + 1};
        case 'digitmarker'
            digitMarker = varargin{iarg + 1};
        case 'digitmarkersize'
            digitMarkerSize = varargin{iarg + 1};
        case 'digitmarkercolor'
            digitMarkerColor = varargin{iarg + 1};
    end
end

if isempty(h_axes)
    figure
    h_axes = gca;
else
    axes(h_axes);
end

pawPartsIdx = zeros(length(valid_bodyparts),1);
for i_part = 1 : length(valid_bodyparts)
    pawPartsIdx(i_part) = find(strcmpi(pawPartsList, valid_bodyparts{i_part}));
end

endPt_wrt_pellet = NaN(length(validTrials),3,length(pawPartsIdx));
for iTrial = 1 : length(validTrials)
    
    curPelletLoc = all_initPellet3D(validTrials(iTrial),:);
    
    if isnan(curPelletLoc(1))
        continue;
    end
    
    for i_part = 1 : length(pawPartsIdx)
        
        cur_endPt = all_endPts(pawPartsIdx(i_part),:,iTrial);
        endPt_wrt_pellet(iTrial,:,i_part) = cur_endPt - curPelletLoc;
        
        % plot z along the "y" axis, 
        scatter3(endPt_wrt_pellet(iTrial,1,i_part),endPt_wrt_pellet(iTrial,3,i_part),endPt_wrt_pellet(iTrial,2,i_part),...
            digitMarker,'sizedata',digitMarkerSize,...
            'markerfacecolor',digitMarkerColor,...
            'markeredgecolor',digitMarkerColor);
        hold on
        
    end
    
end

endPtCov = zeros(3,3,length(pawPartsIdx));
mean_endPt = zeros(length(pawPartsIdx),3);
for i_part = 1 : length(pawPartsIdx)
    parts_endPts = squeeze(endPt_wrt_pellet(:,:,i_part));
    endPtCov(:,:,i_part) = nancov(parts_endPts);
    
    mean_endPt(i_part,:) = nanmean(parts_endPts,1);
    
    error_ellipse(endPtCov,'mu',mean_endPt(i_part,:))
    
end




scatter3(0,0,0,pelletMarker,'sizedata',pelletMarkerSize,...
    'markerfacecolor',pelletMarkerColor,...
    'markeredgecolor',pelletMarkerColor);
        
xlabel('x');
ylabel('z');
zlabel('y');

set(gca,'ydir','reverse','zdir','reverse');