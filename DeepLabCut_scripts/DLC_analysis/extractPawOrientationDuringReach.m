function pawOrientations = extractPawOrientationDuringReach(all_mcpAngle,all_pipAngle,all_digitAngle,all_paw_through_slot_frame,all_endPtFrame)

numTrials = length(all_paw_through_slot_frame);

pawOrientations = cell(numTrials,3);
for iTrial = 1 : numTrials
    
    pawOrientations{iTrial,1} = squeeze(all_mcpAngle(all_paw_through_slot_frame(iTrial):all_endPtFrame(iTrial),iTrial));
    pawOrientations{iTrial,2} = squeeze(all_pipAngle(all_paw_through_slot_frame(iTrial):all_endPtFrame(iTrial),iTrial));
    pawOrientations{iTrial,3} = squeeze(all_digitAngle(all_paw_through_slot_frame(iTrial):all_endPtFrame(iTrial),iTrial));
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%