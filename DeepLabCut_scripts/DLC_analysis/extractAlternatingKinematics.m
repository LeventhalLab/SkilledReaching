function alternateKinematics = extractAlternatingKinematics(reachData,alternateKinematics)

% assume 5 reaches per on/off block
trials_per_block = 5;

startBlockLaserOn = false;      % true for laser on, false for laser off in the first block

[trialNumbers,pd_endPts, dig2_endPts] = extractReachEndPoints(reachData);
[~,end_aperture] = extractReachEndApertures(reachData);
[~,end_orientation] = extractReachEndOrientation(reachData);
max_pd_v = extract_max_v(reachData);

alternateKinematics.pd_endPts = pd_endPts;
alternateKinematics.dig2_endPts = dig2_endPts;
alternateKinematics.endAperture = end_aperture;
alternateKinematics.endOrientation = end_orientation;
alternateKinematics.max_pd_v = max_pd_v;
alternateKinematics.trialNumbers = trialNumbers;

% create a mask for laser on vs off trials
numTrials = length(reachData);
numBlocks = ceil(numTrials/trials_per_block);

if startBlockLaserOn
    num_on_blocks = ceil(numBlocks/2);
    num_off_blocks = floor(numBlocks/2);
else
    num_on_blocks = floor(numBlocks/2);
    num_off_blocks = ceil(numBlocks/2);
end
alternateKinematics.on_pd_endPts = NaN(num_on_blocks,trials_per_block,3);
alternateKinematics.off_pd_endPts = NaN(num_off_blocks,trials_per_block,3);

alternateKinematics.on_dig2_endPts = NaN(num_on_blocks,trials_per_block,3);
alternateKinematics.off_dig2_endPts = NaN(num_off_blocks,trials_per_block,3);

alternateKinematics.on_endAperture = NaN(num_on_blocks,trials_per_block);
alternateKinematics.off_endAperture = NaN(num_off_blocks,trials_per_block);

alternateKinematics.on_endOrientation = NaN(num_on_blocks,trials_per_block);
alternateKinematics.off_endOrientation = NaN(num_off_blocks,trials_per_block);

alternateKinematics.on_max_pd_v = NaN(num_on_blocks,trials_per_block);
alternateKinematics.off_max_pd_v = NaN(num_off_blocks,trials_per_block);

laserOnFlag = false(numTrials,1);

currentBlockFlag = startBlockLaserOn;
cur_on_block = 0;
cur_off_block = 0;
for i_block = 1 : numBlocks
    block_start_idx = (i_block-1)*trials_per_block + 1;
    block_end_idx = min(i_block*trials_per_block,numTrials);
    
    laserOnFlag(block_start_idx:block_end_idx) = currentBlockFlag;
    
    trials_in_current_block = block_end_idx - block_start_idx + 1;
    if currentBlockFlag
        % this is a laser on block
        cur_on_block = cur_on_block + 1;
        alternateKinematics.on_pd_endPts(cur_on_block,1:trials_in_current_block,:) = ...
            pd_endPts(block_start_idx:block_end_idx,:);
        alternateKinematics.on_dig2_endPts(cur_on_block,1:trials_in_current_block,:) = ...
            dig2_endPts(block_start_idx:block_end_idx,:);
        alternateKinematics.on_endAperture(cur_on_block,1:trials_in_current_block) = ...
            end_aperture(block_start_idx:block_end_idx);
        alternateKinematics.on_endOrientation(cur_on_block,1:trials_in_current_block) = ...
            end_orientation(block_start_idx:block_end_idx);
        alternateKinematics.on_max_pd_v(cur_on_block,1:trials_in_current_block) = ...
            max_pd_v(block_start_idx:block_end_idx);
    else
        % this is a laser on block
        cur_off_block = cur_off_block + 1;
        alternateKinematics.off_pd_endPts(cur_off_block,1:trials_in_current_block,:) = ...
            pd_endPts(block_start_idx:block_end_idx,:);
        alternateKinematics.off_dig2_endPts(cur_off_block,1:trials_in_current_block,:) = ...
            dig2_endPts(block_start_idx:block_end_idx,:);
        alternateKinematics.off_endAperture(cur_off_block,1:trials_in_current_block) = ...
            end_aperture(block_start_idx:block_end_idx);
        alternateKinematics.off_endOrientation(cur_off_block,1:trials_in_current_block) = ...
            end_orientation(block_start_idx:block_end_idx);
        alternateKinematics.off_max_pd_v(cur_off_block,1:trials_in_current_block) = ...
            max_pd_v(block_start_idx:block_end_idx);
    end
    currentBlockFlag = ~currentBlockFlag;
end

end