function h_fig = visualizePawTrajectory(pawTrajectory, bodyparts, parts_to_show, pawPref, varargin)
%
% INPUTS
%   pawTrajectory - numFrames x 3 x numBodyparts array. Each numFramex x 3
%       matrix contains x,y,z points for each bodypart
%   bodyparts - cell array containing strings describing each bodypart in
%       the same order as in the pawTrajectory array
%   parts_to_show - cell array of strings containing which bodyparts to
%       show in the plot
%
% VARARGS
%   markersize - size of the markers used in the plots
%   xlim, ylim, zlim - 2-element vectors containing x,y, or z axis limits
%
% OUTPUTS
%   h_fig - figure handle containing the trajectory reconstruction

if ~iscell(bodyparts)
    bodyparts = {bodyparts};
end
if ~iscell(parts_to_show)
    parts_to_show = {parts_to_show};
end

markerSize = 3;

xlim = [-15 20];
ylim = [5 50];
zlim = [150 250];




for iarg = 1 : 2 : nargin - 4
    switch lower(varargin{iarg})
        case 'markersize'
            markerSize = varargin{iarg + 1};
        case 'xlim'
            xlim = varargin{iarg + 1};
        case 'ylim'
            ylim = varargin{iarg + 1};
        case 'zlim'
            zlim = varargin{iarg + 1};
    end
end

[mcp_idx,pip_idx,digit_idx,pawdorsum_idx,nose_idx,pellet_idx,otherpaw_idx] = ...
    group_DLC_bodyparts(bodyparts,pawPref);

numFrames = size(pawTrajectory,1);

% associate colors with specific body parts
bodypartColor.dig = [1 0 0;
                     1 0 1;
                     1 1 0;
                     0 1 0];
bodypartColor.otherPaw = [0 1 1];
bodypartColor.paw_dorsum = [0 0 1];
bodypartColor.pellet = [0 0 0];
bodypartColor.nose = [0 0 0];


    
h_fig = figure;

markerAlpha = linspace(0,1,numFrames);
% markerAlpha = ones(numFrames,1);

for i_part_to_show = 1 : length(parts_to_show)
    
    bp_match_idx = find(findStringMatchinCellArray(bodyparts,parts_to_show{i_part_to_show}));
    if isempty(bp_match_idx)
        fprintf('bodypart %s not found\n', parts_to_show{i_part_to_show});
        continue;
    end
    for i_subPart = 1 : length(bp_match_idx)
        curPart = bodyparts{bp_match_idx(i_subPart)};

        if any(strfind(curPart,'mcp'))
            digitNum = str2num(curPart(end));
            baseColor = bodypartColor.dig(digitNum,:) * 1/3;
            trajIdx = mcp_idx(digitNum);
        elseif any(strfind(curPart,'pip'))
            digitNum = str2num(curPart(end));
            baseColor = bodypartColor.dig(digitNum,:) * 2/3;
            trajIdx = pip_idx(digitNum);
        elseif any(strfind(curPart,'dig'))
            digitNum = str2num(curPart(end));
            baseColor = bodypartColor.dig(digitNum,:) * 1;
            trajIdx = digit_idx(digitNum);
        elseif any(strfind(curPart,[pawPref 'pawdorsum']))
            baseColor = bodypartColor.paw_dorsum;
            trajIdx = pawdorsum_idx;
        elseif any(strfind(curPart,'nose'))
            baseColor = bodypartColor.nose;
            trajIdx = nose_idx;
        elseif any(strfind(curPart,'pellet'))
            baseColor = bodypartColor.pellet;
            trajIdx = pellet_idx;
        else
            baseColor = bodypartColor.otherPaw;
        end
                
            
        for iFrame = 1 : numFrames
            scatter3(pawTrajectory(iFrame,1,trajIdx),...
                     pawTrajectory(iFrame,2,trajIdx),...
                     pawTrajectory(iFrame,3,trajIdx),...
                     markerSize,...
                     'markerfacealpha', markerAlpha(iFrame),...
                     'markeredgealpha', markerAlpha(iFrame),...
                     'markeredgecolor', baseColor, ...
                     'markerfacecolor', baseColor);
             hold on
        end
        
    end
    
    xlabel('x');
    ylabel('y');
    zlabel('z');
    set(gca,'zdir','reverse');
    set(gca,'ydir','reverse');
    set(gca,'xlim',xlim,'ylim',ylim,'zlim',zlim)
    
end