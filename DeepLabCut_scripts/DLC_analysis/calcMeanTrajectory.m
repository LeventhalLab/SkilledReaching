function meanTrajectory = calcMeanTrajectory(allTrajectories,pawPartsList,all_firstPawDorsumFrame,all_paw_through_slot_frame,all_endPtFrame,pawPref)
%
% INPUTS
%   
%
% OUTPUTS
%   meanTrajectory

% general strategy:

% identify the start and end point for each paw part.
% For the paw dorsum, find the first value where the mirror view was
% clearly identified, and track it up to the slot. 

numTrials = size(allTrajectories,4);
[mcp_idx,pip_idx,digit_idx,pawdorsum_idx,~,~,~] = ...
    group_DLC_bodyparts(pawPartsList,pawPref);


% extract 3D points for paw dorsum trajectory
for iTrial = 1 : numTrials
    
    curTrajectory = squeeze(allTrajectories(all_firstPawDorsumFrame(iTrial):all_endPtFrame(iTrial),:,pawdorsum_idx,iTrial));

    % WORKING HERE...
    % smooth the trajectory

end
% for the digits, identify the first point after it breaks the slot
% (recorded in firstSlotBreak) until max extension for the reach