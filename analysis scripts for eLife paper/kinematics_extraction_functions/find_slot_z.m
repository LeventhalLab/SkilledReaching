function slot_z = find_slot_z(trajectoryDir,varargin)
%
% figure out the z-coordinate of the reaching slot with respect to the
% pellet
%
% INPUTS
%   trajectoryDir - directory containing the paw trajectory files
%
% VARARGS
%   trajectory_file_name - string containing characters that define the
%       names of the paw trajectory files
%
% OUTPUTS
%   slot_z - estimate of the z-coordinate of the reaching slot/front panel

reachBorders = [160,230];
binWidth = 2;

binEdges = reachBorders(1):binWidth:reachBorders(2);

currentDir = pwd;
cd(trajectoryDir);
trajectory_file_name = 'R*3dtrajectory_new.mat';

for iarg = 1 : 2 : nargin - 1
    switch lower(varargin{iarg})
        case 'trajectory_file_name'
            trajectory_file_name = varargin{iarg + 1};
    end
end
            
% find the pawTrajectory files
pawTrajectoryList = dir(trajectory_file_name);
if isempty(pawTrajectoryList)
    slot_z = [];
    return;
end

numTrials = length(pawTrajectoryList);

load(pawTrajectoryList(1).name);

pawPref = thisRatInfo.pawPref;   % contained in paw trajectory file
if iscategorical(pawPref)
    pawPref = char(pawPref);
end
if iscell(pawPref)
    pawPref = pawPref{1};
end

allTrajectories = NaN(size(pawTrajectory,1),size(pawTrajectory,2),size(pawTrajectory,3),numTrials);
allTrajectories(:,:,:,1) = pawTrajectory;
[mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);
reachingPawIdx = [mcpIdx;pipIdx;digIdx;pawDorsumIdx];

for iTrial = 2 : numTrials
    load(pawTrajectoryList(iTrial).name);
    if size(pawTrajectory,1) < size(allTrajectories,1)   % if the current video is short compared to others for whatever reason.
        pawTrajectory(end+1:size(allTrajectories,1),:,:) = 0;
    end
    if size(pawTrajectory,1) > size(allTrajectories,1)   % if the current video is longer than the first one for whatever reason. this may happen if the first video in a series is short
        allTrajectories(end+1:size(pawTrajectory,1),:,:,:) = NaN;   % assume all frames after the last frame so far should be NaNs
    end
    allTrajectories(:,:,:,iTrial) = pawTrajectory;

end
all_z = squeeze(allTrajectories(:,3,reachingPawIdx,:));
all_z = all_z(all_z > 0);

% all z values should have a bimodal distribution, with a minimum where the
% slot is (can't find the paw in the mirror view at the slot). Use Otsu's
% method to find that minimum
[norm_thresh,~] = graythresh(all_z / 255);   % from image processing toolbox
slot_z = norm_thresh * 255;

cd(currentDir);

end