function aperture = calcAperture(trajectory,bodyparts,pawPref)

[~,~,digIdx,~] = findReachingPawParts(bodyparts,pawPref);

numFrames = size(trajectory,1);

aperture = NaN(numFrames,3);

for iFrame = 1 : numFrames
    
    cur_digCoords = [squeeze(trajectory(iFrame,:,digIdx(1)));
                     squeeze(trajectory(iFrame,:,digIdx(3)))];
    if ~isnan(cur_digCoords(1,1)) && ~isnan(cur_digCoords(2,1))
        % both 1st and 4th digit tips were found in this frame
        aperture(iFrame,:) = diff(cur_digCoords,1,1);
    end
    
end