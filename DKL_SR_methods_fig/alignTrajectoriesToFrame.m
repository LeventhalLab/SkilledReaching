function aligned_trajectories = alignTrajectoriesToFrame(x,y,z,vid_alignFrame, varargin)
%
% function to align 3D reaching trajectories to frames that satisfy some
% condition (previously tested to figure out vid_alignFrame)
%
% INPUTS:
%   x,y,z - cell arrays containing the x,y,z coordinates for each reach
%   vid_alignFrame - vector containing the frames on which to align the
%       trajectories for each video. This vector must have the same length
%       as the x,y,z cell arrays
%
% OUTPUTS:
%   aligned_trajectories - m x n x p array, where m is the number of
%       "virtual" frames (real frames plus padding to accomodate the
%       alignment), n is 3 (x,y,z), and p is the number of trajectories
%

numVirtualFrames = 1000; 
alignToFrame = 500;

for iarg = 1 : 2 : nargin - 4
    switch lower(varargin{iarg})
        case 'numvirtframes',
            numVirtualFrames = varargin{iarg + 1};
        case 'aligntoframe',
            alignToFrame = varargin{iarg + 1};
    end
end
aligned_trajectories = zeros(numVirtualFrames,3,length(z));

for i_traj = 1 : length(z)
%     i_traj
    if vid_alignFrame(i_traj) == 0; continue; end
    
    pre_pad = alignToFrame - vid_alignFrame(i_traj);
    post_pad = numVirtualFrames - pre_pad - length(x{i_traj});
    
    if length(x{i_traj}) > size(x{i_traj},1)
        x{i_traj} = x{i_traj}';
    end
    if length(y{i_traj}) > size(y{i_traj},1)
        y{i_traj} = y{i_traj}';
    end
    if length(z{i_traj}) > size(z{i_traj},1)
        z{i_traj} = z{i_traj}';
    end
    
    x_pad = padarray(x{i_traj},pre_pad,0,'pre');
    x_pad = padarray(x_pad,post_pad,0,'post');
    
    y_pad = padarray(y{i_traj},pre_pad,0,'pre');
    y_pad = padarray(y_pad,post_pad,0,'post');
    
    z_pad = padarray(z{i_traj},pre_pad,0,'pre');
    z_pad = padarray(z_pad,post_pad,0,'post');
    
    aligned_trajectories(:,1,i_traj) = x_pad;
    aligned_trajectories(:,2,i_traj) = y_pad;
    aligned_trajectories(:,3,i_traj) = z_pad;
    
end