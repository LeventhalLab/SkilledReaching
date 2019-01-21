function [endApertures,apertureTrajectories] = collectApertures(all_aperture,all_paw_through_slot_frame,all_endPtFrame)

numTrials = length(all_endPtFrame);

endApertures = NaN(numTrials,3);
apertureTrajectories = cell(numTrials,1);
% pip_endAngle = zeros(numTrials,1);
% mcp_endAngle = zeros(numTrials,1);
for iTrial = 1 : numTrials
    
    if isnan(all_endPtFrame(iTrial))
        continue;
    end
    
    apertureTrajectories{iTrial} = squeeze(all_aperture(all_paw_through_slot_frame(iTrial):all_endPtFrame(iTrial),:,iTrial));
    
    endApertures(iTrial,:) = squeeze(all_aperture(all_endPtFrame(iTrial),:,iTrial));

end