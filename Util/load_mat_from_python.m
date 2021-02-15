function [direct_bp, mirror_bp, direct_p, mirror_p, direct_pts_ud, mirror_pts_ud, paw_pref, im_size, video_number, ROIs] = ...
    load_mat_from_python(filename)

dlc_from_python = load(filename);

num_bp = size(dlc_from_python.direct_bp, 1);

direct_bp = cell(num_bp, 1);
mirror_bp = cell(num_bp, 1);
for i_bp = 1 : num_bp
    
    direct_bp{i_bp} = strtrim(dlc_from_python.direct_bp(i_bp,:));
    mirror_bp{i_bp} = strtrim(dlc_from_python.mirror_bp(i_bp,:));
    
end

direct_p = dlc_from_python.direct_p;
mirror_p = dlc_from_python.mirror_p;
direct_pts_ud = dlc_from_python.direct_pts_ud;
mirror_pts_ud = dlc_from_python.mirror_pts_ud;
paw_pref = dlc_from_python.paw_pref;
im_size = dlc_from_python.im_size;
video_number = dlc_from_python.video_number;
ROIs = dlc_from_python.ROIs;

mirror_pts_ud(mirror_pts_ud==0) = NaN;
direct_pts_ud(direct_pts_ud==0) = NaN;