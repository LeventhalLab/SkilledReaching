function pawOrientation = determinePawOrientation(interp_trajectory,bodyparts)

[~,~,digIdx,~] = findReachingPawParts(bodyparts,pawPref);