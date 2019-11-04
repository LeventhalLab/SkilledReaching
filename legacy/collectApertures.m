function [endApertures,apertureTrajectories] = collectApertures(all_aperture,all_paw_through_slot_frame,all_endPtFrame)

maxFrameWindow_for_endPt = 3;

numTrials = length(all_endPtFrame);

endApertures = NaN(numTrials,3);
apertureTrajectories = cell(numTrials,1);
% pip_endAngle = zeros(numTrials,1);
% mcp_endAngle = zeros(numTrials,1);
for iTrial = 1 : numTrials
    
    if isnan(all_endPtFrame(iTrial)) || isnan(all_paw_through_slot_frame(iTrial))
        continue;
    end
    
    apertureTrajectories{iTrial} = squeeze(all_aperture(all_paw_through_slot_frame(iTrial):all_endPtFrame(iTrial),:,iTrial));
    
    if ~isnan(all_aperture(all_endPtFrame(iTrial),1,iTrial))
        endApertures(iTrial,:) = squeeze(all_aperture(all_endPtFrame(iTrial),:,iTrial));
    else
        % find nearest frame within maxFrameWindow_for_endPt with a valid
        % aperture
        for iFrameDiff = 1 : maxFrameWindow_for_endPt
            curFrame = all_endPtFrame(iTrial) - iFrameDiff;
            if ~isnan(all_aperture(curFrame,1,iTrial))
                endApertures(iTrial,:) = all_aperture(curFrame,:,iTrial);
                break
            end
            curFrame = all_endPtFrame(iTrial) + iFrameDiff;
            if ~isnan(all_aperture(curFrame,1,iTrial))
                endApertures(iTrial,:) = all_aperture(curFrame,:,iTrial);
                break
            end
        end
    end
    

end