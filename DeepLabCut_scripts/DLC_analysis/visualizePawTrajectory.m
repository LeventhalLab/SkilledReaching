function h_fig = visualizePawTrajectory(pawTrajectory, bodyparts, parts_to_show, varargin)
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
%
% OUTPUTS
%

[mcp_idx,pip_idx,digit_idx,pawdorsum_idx,nose_idx,pellet_idx,otherpaw_idx] = ...
    group_DLC_bodyparts(bodyparts);

numFrames = size(pawTrajectory,1);

% associate colors with specific body parts
bodypartColor.dig1 = [1 0 0];
bodypartColor.dig2 = [1 0 1];
bodypartColor.dig3 = [1 1 0];
bodypartColor.dig4 = [0 1 0];
bodypartColor.otherPaw = [0 1 1];
bodypartColor.paw_dorsum = [0 0 1];
bodypartColor.pellet = [0 0 0];


    
h_fig = figure;

markerAlpha = linspace(0,1,numFrames);

for i_part_to_show = 1 : length(parts_to_show)
    
    bp_match_idx = find(findStringMatchinCellArray(bodyparts,parts_to_show{i_part_to_show}));
    if isempty(bp_match_idx)
        fprintf('bodypart %s not found\n', parts_to_show{i_part_to_show});
        continue;
    end
    for i_subPart = 1 : length(bp_match_idx)
        curPart = bodyparts{bp_match_idx(i_subPart)};

        if any(strfind(curPart,'mcp'))
            
        elseif any(strfind(curPart,'pip'))
            
        elseif any(strfind(curPart,'dig'))
                
            
        for iFrame = 1 : numFrames
            scatter3(pawTrajectory(iFrame,1,bp_match_idx(i_subPart)),...
                     pawTrajectory(iFrame,2,bp_match_idx(i_subPart)),...
                     pawTrajectory(iFrame,3,bp_match_idx(i_subPart)),...
                     'markerfacealpha', markerAlpha(iFrame),...
                     'markeredgealpha', markerAlpha(iFrame),...
                     'markeredgecolor', 
                     'markerfacecolor',