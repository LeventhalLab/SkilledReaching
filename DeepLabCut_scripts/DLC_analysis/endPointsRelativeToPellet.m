function endPt_wrt_pellet = endPointsRelativeToPellet(all_initPellet3D, all_endPts, validTrials, pawPartsList, valid_bodyparts, varargin)
%
% compute reach end points for selected body parts with respect to the
% pellet on each individual trial
%
% INPUTS
%   all_initPellet3D
%   all_endPts
%   validTrials
%
% OUTPUTS
%

if ~iscell(valid_bodyparts)
    valid_bodyparts = {valid_bodyparts};
end

pawPartsIdx = zeros(length(valid_bodyparts),1);
for i_part = 1 : length(valid_bodyparts)
    pawPartsIdx(i_part) = find(strcmpi(pawPartsList, valid_bodyparts{i_part}));
end

endPt_wrt_pellet = NaN(length(validTrials),3,length(pawPartsIdx));

for iTrial = 1 : length(validTrials)
    
    curPelletLoc = all_initPellet3D(validTrials(iTrial),:);
    
    if isnan(curPelletLoc(1))
        continue;
    end
    
    for i_part = 1 : length(pawPartsIdx)
        
        cur_endPt = all_endPts(pawPartsIdx(i_part),:,iTrial);
        endPt_wrt_pellet(iTrial,:,i_part) = cur_endPt - curPelletLoc;
        
    end
    
end