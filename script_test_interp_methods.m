
%%

iTrial = 30;


cur_interp_traj = squeeze(all_interp_trajectories(:,:,:,iTrial));

cur_traj = squeeze(allTrajectories(:,:,:,iTrial));

cur_start_pt = all_firstPawDorsumFrame(iTrial);

cur_lastPt = 0;
for ii = 1 : 13
    testVals = all_reachFrameIdx{iTrial}{ii};
    if iscolumn(testVals)
        testVals = testVals';
    end
    cur_lastPt = max([testVals, cur_lastPt]);
end

pawTraj = squeeze(cur_traj(:,:,13));
dig2Traj = squeeze(cur_traj(:,:,10));
dig3Traj = squeeze(cur_traj(:,:,11));

interp_pawTraj = squeeze(cur_interp_traj(:,:,13));
interp_dig2Traj = squeeze(cur_interp_traj(:,:,10));
interp_dig3Traj = squeeze(cur_interp_traj(:,:,11));


for iDim = 1 : 3
    figure(iDim)
    hold off
    plot(interp_pawTraj(cur_start_pt:cur_lastPt,iDim));
    hold on
    plot(pawTraj(cur_start_pt:cur_lastPt,iDim));
    set(gcf,'name',sprintf('paw, dimension %d',iDim));
    
    figure(iDim + 3)
    hold off
    plot(interp_dig2Traj(cur_start_pt:cur_lastPt,iDim));
    hold on
    plot(dig2Traj(cur_start_pt:cur_lastPt,iDim));
    set(gcf,'name',sprintf('digit 2, dimension %d',iDim));
    
    figure(iDim + 6)
    hold off
    plot(interp_dig3Traj(cur_start_pt:cur_lastPt,iDim));
    hold on
    plot(dig3Traj(cur_start_pt:cur_lastPt,iDim));
    set(gcf,'name',sprintf('digit 3, dimension %d',iDim));
end