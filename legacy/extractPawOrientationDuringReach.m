function pawOrientations = extractPawOrientationDuringReach(all_mcpAngle,all_pipAngle,all_digitAngle,all_paw_through_slot_frame,all_endPtFrame)

numTrials = length(all_paw_through_slot_frame);

pawOrientations = cell(numTrials,3);

h_mcpFig = figure;
set(gcf,'name','mcp angles')
h_pipFig = figure;
set(gcf,'name','pip angles')
h_digFig = figure;
set(gcf,'name','digit angles')

for iTrial = 1 : numTrials
    
    pawOrientations{iTrial,1} = squeeze(all_mcpAngle(all_paw_through_slot_frame(iTrial):all_endPtFrame(iTrial),iTrial));
    pawOrientations{iTrial,2} = squeeze(all_pipAngle(all_paw_through_slot_frame(iTrial):all_endPtFrame(iTrial),iTrial));
    pawOrientations{iTrial,3} = squeeze(all_digitAngle(all_paw_through_slot_frame(iTrial):all_endPtFrame(iTrial),iTrial));
    
    figure(h_mcpFig)
    plot(pawOrientations{iTrial,1})
    hold on
    
    figure(h_pipFig)
    plot(pawOrientations{iTrial,2})
    hold on
    
    figure(h_digFig)
    plot(pawOrientations{iTrial,3})
    hold on
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%