function digit_endAngle = collectFinalPawOrientations(all_digitAngle,all_endPtFrame)

numTrials = length(all_endPtFrame);

digit_endAngle = NaN(numTrials,1);
% pip_endAngle = zeros(numTrials,1);
% mcp_endAngle = zeros(numTrials,1);
for iTrial = 1 : numTrials
    if isnan(all_endPtFrame(iTrial))
        continue;
    end
    digit_endAngle(iTrial) = all_digitAngle(all_endPtFrame(iTrial),iTrial);
%     pip_endAngle(iTrial) = all_pipAngle(all_endPtFrame(iTrial),iTrial);
%     mcp_endAngle(iTrial) = all_mcpAngle(all_endPtFrame(iTrial),iTrial);
end