function slot_z = find_slot_z(trajectoryDir)

reachBorders = [160,220];
binWidth = 2;

binEdges = reachBorders(1):binWidth:reachBorders(2);

currentDir = pwd;
cd(trajectoryDir);

% find the pawTrajectory files
pawTrajectoryList = dir('R*3dtrajectory.mat');
if isempty(pawTrajectoryList)
    slot_z = [];
    return;
end

numTrials = length(pawTrajectoryList);

load(pawTrajectoryList(1).name);

pawPref = thisRatInfo.pawPref;
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
% numPawParts = length(reachingPawIdx);

for iTrial = 2 : numTrials
    load(pawTrajectoryList(iTrial).name);
    if size(pawTrajectory,1) < size(allTrajectories,1)
        pawTrajectory(end+1:size(allTrajectories,1),:,:) = 0;
    end
    allTrajectories(:,:,:,iTrial) = pawTrajectory;
end
all_z = squeeze(allTrajectories(:,3,reachingPawIdx,:));
all_z = all_z(all_z > 0);

% all z values should have a bimodal distribution, with a minimum where the
% slot is (can't find the paw in the mirror view at the slot). Use Otsu's
% method to find that minimum
norm_thresh = graythresh(all_z / 255);
slot_z = norm_thresh * 255;

% figure(2);
% histogram(all_z,binEdges)
% N = histcounts(all_z(:),binEdges);
% reshaped_z = zeros(size(all_z,1),size(all_z,2)*size(all_z,3));
% for iTrial = 1 : numTrials
%     start_idx = (iTrial-1) * numPawParts + 1;
%     end_idx = iTrial * numPawParts;
%     reshaped_z(:,start_idx:end_idx) = squeeze(all_z(:,:,iTrial));
% end
% slot_z_estimate = 200;

cd(currentDir);

end