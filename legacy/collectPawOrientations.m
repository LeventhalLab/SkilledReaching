function [paw_endAngle,pawOrientationTrajectories] = collectPawOrientations(all_pawAngle,all_paw_through_slot_frame,all_endPtFrame)

numTrials = length(all_endPtFrame);

paw_endAngle = NaN(numTrials,1);
pawOrientationTrajectories = cell(numTrials,1);

maxFrameWindow_for_endPt = 3;
% pip_endAngle = zeros(numTrials,1);
% mcp_endAngle = zeros(numTrials,1);
for iTrial = 1 : numTrials
    
    if isnan(all_endPtFrame(iTrial)) || isnan(all_paw_through_slot_frame(iTrial))
        continue;
    end
    try
    pawOrientationTrajectories{iTrial} = all_pawAngle(all_paw_through_slot_frame(iTrial):all_endPtFrame(iTrial),iTrial);
    catch
        keyboard
    end
    
    if ~isnan(all_pawAngle(all_endPtFrame(iTrial),iTrial))
        paw_endAngle(iTrial) = all_pawAngle(all_endPtFrame(iTrial),iTrial);
    else
        % find nearest frame within maxFrameWindow_for_endPt with a valid
        % angle
        for iFrameDiff = 1 : maxFrameWindow_for_endPt
            curFrame = all_endPtFrame(iTrial) - iFrameDiff;
            if ~isnan(all_pawAngle(curFrame,iTrial))
                paw_endAngle(iTrial) = all_pawAngle(curFrame,iTrial);
                break
            end
            curFrame = all_endPtFrame(iTrial) + iFrameDiff;
            if ~isnan(all_pawAngle(curFrame,iTrial))
                paw_endAngle(iTrial) = all_pawAngle(curFrame,iTrial);
                break
            end
        end
    end
%     pip_endAngle(iTrial) = all_pipAngle(all_endPtFrame(iTrial),iTrial);
%     mcp_endAngle(iTrial) = all_mcpAngle(all_endPtFrame(iTrial),iTrial);
end