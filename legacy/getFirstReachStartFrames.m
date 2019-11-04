function all_reachStartFrames = getFirstReachStartFrames(allTrajectories,bodyparts,pawPref,all_endPtFrame,slot_z,all_initPellet3D)


numTrials = size(allTrajectories,4);
all_reachStartFrames = zeros(numTrials,1);

for iTrial = 1 : numTrials
    
    trajectory = squeeze(allTrajectories(:,:,:,iTrial));
    try
    all_reachStartFrames(iTrial) = findReachStart_pastSlot(trajectory,bodyparts,pawPref,all_endPtFrame(iTrial),slot_z,all_initPellet3D(iTrial,3));
    catch
        keyboard
    end
    
end

