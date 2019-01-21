function [paw_endAngle,pawOrientationTrajectories] = collectPawOrientations(all_pawAngle,all_paw_through_slot_frame,all_endPtFrame)

numTrials = length(all_endPtFrame);

paw_endAngle = NaN(numTrials,1);
pawOrientationTrajectories = cell(numTrials,1);
% pip_endAngle = zeros(numTrials,1);
% mcp_endAngle = zeros(numTrials,1);
for iTrial = 1 : numTrials
    
    pawOrientationTrajectories{iTrial} = all_pawAngle(all_paw_through_slot_frame(iTrial):all_endPtFrame(iTrial),iTrial);
    
    if isnan(all_endPtFrame(iTrial))
        continue;
    end
    
    
    paw_endAngle(iTrial) = all_pawAngle(all_endPtFrame(iTrial),iTrial);
%     pip_endAngle(iTrial) = all_pipAngle(all_endPtFrame(iTrial),iTrial);
%     mcp_endAngle(iTrial) = all_mcpAngle(all_endPtFrame(iTrial),iTrial);
end