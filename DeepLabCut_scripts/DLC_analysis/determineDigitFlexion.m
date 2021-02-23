function [digFlex,firstValidFrame] = determineDigitFlexion(interp_trajectory,bodyparts,pawPref)

% calculate the flexion/extension of the second digit by measuring the angle of
% the line between the tips of the digits and the mcps

[mcpIdx,~,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
numFrames = size(interp_trajectory,1);

pd_trajectory = squeeze(interp_trajectory(:,:,pawDorsumIdx));
mcp2_trajectory = squeeze(interp_trajectory(:,:,mcpIdx(2)));
dig2_trajectory = squeeze(interp_trajectory(:,:,digIdx(2)));

validFrames = ~isnan(dig2_trajectory(:,3)) & ~isnan(mcp2_trajectory(:,1)) & ~isnan(pd_trajectory(:,1));

firstValidFrame = find(validFrames,1,'first');
numValidFrames = numFrames - firstValidFrame + 1;

if ~any(validFrames)   % no valid frames. this can happen on very short reaches where
                       % all the digits don't make it through the slot.
                       % Will have to think about how to deal with this -
                       % maybe these don't count as reaches?
	digAngle = NaN(numValidFrames,1);  
    firstValidFrame = [];
    digFlex = [];
    return
end

% calculate angle between paw dorsum and mcp2 as a reference angle
pdAngle = zeros(numValidFrames,1);
for iFrame = firstValidFrame : numFrames
    PDpts = [mcp2_trajectory(iFrame,2:3);pd_trajectory(iFrame,2:3)];
%         DIGpts = flipud(DIGpts);
    pdAngle(iFrame-firstValidFrame+1) = pointsAngle2(PDpts);
end

digAngle = zeros(numValidFrames,1); 

for iFrame = firstValidFrame : numFrames
    DIGpts = [dig2_trajectory(iFrame,2:3);mcp2_trajectory(iFrame,2:3)];
%         DIGpts = flipud(DIGpts);
    digAngle(iFrame-firstValidFrame+1) = pointsAngle2(DIGpts);
end

digFlex = digAngle-pdAngle;


end