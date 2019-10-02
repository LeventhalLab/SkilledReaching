function [pawOrientation,firstValidFrame] = determinePawOrientation(interp_trajectory,bodyparts,pawPref)

[~,~,digIdx,~] = findReachingPawParts(bodyparts,pawPref);
numFrames = size(interp_trajectory,1);
% paw orienation is the angle of the line between the first and fourth
% digits
dig1_trajectory = squeeze(interp_trajectory(:,:,digIdx(1)));
dig4_trajectory = squeeze(interp_trajectory(:,:,digIdx(4)));

% maybe we can just ignore z, which would be equivalent to projecting the
% vector connecting the tips of digits 1 and 4 onto the plane z = 0?
validFrames = ~isnan(dig1_trajectory(:,1)) & ~isnan(dig4_trajectory(:,1));

if ~any(validFrames)   % no valid frames. this can happen on very short reaches where
                       % all the digits don't make it through the slot.
                       % Will have to think about how to deal with this -
                       % maybe these don't count as reaches?
	pawOrientation = NaN(numValidFrames,1);
    firstValidFrame = [];
    return
end
firstValidFrame = find(validFrames,1,'first');
numValidFrames = numFrames - firstValidFrame + 1;
pawOrientation = zeros(numValidFrames,1);

for iFrame = firstValidFrame : numFrames
    DIGpts = [dig1_trajectory(iFrame,1:2);dig4_trajectory(iFrame,1:2)];
    DIGpts = flipud(DIGpts);
    pawOrientation(iFrame-firstValidFrame+1) = pointsAngle(DIGpts);
end

end