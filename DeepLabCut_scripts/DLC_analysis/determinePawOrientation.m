function pawOrientation = determinePawOrientation(direct_pts,direct_bp,direct_p,pawPref)
%
% function to determine the angle of the paw in the direct view with
% respect to horizontal (vertical?)

[invalidPoints,diff_per_frame] = find_invalid_DLC_points(direct_pts, direct_p);
% hard code strings that only occur in bodyparts that are part of the
% reaching paw
[mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);


    
    