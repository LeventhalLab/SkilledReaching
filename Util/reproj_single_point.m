function [direct_pt,mirror_pt] = reproj_single_point(point3D,P,Pn,K,sf)

direct_pt = NaN(1,2);
mirror_pt = NaN(1,2);

if all(point3D==0) || isnan(point3D(1))
    % 3D point wasn't computed for this body part
    return;
end

point3D = point3D / sf;

% reproject this point into the direct view
currPt_direct = projectPoints_DL(point3D, P);
direct_pt = unnormalize_points(currPt_direct,K);

currPt_mirror = projectPoints_DL(point3D, Pn);
mirror_pt = unnormalize_points(currPt_mirror,K);