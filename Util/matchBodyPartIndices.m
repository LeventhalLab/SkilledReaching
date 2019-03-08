function [bodyparts,direct_bpMatch_idx,mirror_bpMatch_idx] = matchBodyPartIndices(direct_bp,mirror_bp)
%
% match the indices of the bodyparts from the mirror and direct view DLC
% output. If you're thinking ahead, you'll keep them in the same order. If
% not, at least make sure the names are the same so this function can match
% them up.
%
% INPUTS
%   direct_bp, mirror_bp - cell array containing lis of body part
%       descriptors for the direct/mirror view
%
% OUTPUTS
%   bodyparts - cell array containing the list of bodyparts (taken from the
%       direct view list). These labels will be in the same order as the
%       arrays containing the 3D data (e.g., pawTrajectory output from 
%       calc3D_DLC_trajectory
%	direct_bpMatch_idx, mirror_bpMatch_idx - indices into the direct_bp
%       and mirror_bp arrays that match. For example, if
%       direct_bpMatch_idx(1) = 1 and mirror_bpMatch_idx(1) = 3, that means
%       that the first direct bodypart matches with the third mirror
%       bodypart


mirror_bpMatch_idx = [];
direct_bpMatch_idx = [];
num_direct_bp = length(direct_bp);
numValid_bp = 0;
bodyparts = {};
for i_bp = 1 : num_direct_bp
    
    if ~any(strcmpi(mirror_bp, direct_bp{i_bp}))
        % in some DLC runs, 'pawdorsum' is just 'paw'. For example,
        % 'rightpawdorsum' in the direct view could be 'rightpaw' in the
        % mirror view. Need to make those match up if needed.
        [cellMatchIdx,~] = findSubstringInCellArray(mirror_bp,direct_bp{i_bp});
        if ~isempty(cellMatchIdx)
            numValid_bp = numValid_bp + 1;
            mirror_bpMatch_idx(numValid_bp) = cellMatchIdx;
            direct_bpMatch_idx(numValid_bp) = i_bp;
            bodyparts{numValid_bp} = direct_bp{i_bp};
        end
        continue;
    end
    numValid_bp = numValid_bp + 1;
    try
    mirror_bpMatch_idx(numValid_bp) = find(strcmpi(mirror_bp, direct_bp{i_bp}));
    catch
        keyboard
    end
    direct_bpMatch_idx(numValid_bp) = i_bp;
    bodyparts{numValid_bp} = direct_bp{i_bp};
    
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cellMatchIdx,positionMatchIdx] = findSubstringInCellArray(cell_array, substring)

numMatches = 0;
cellMatchIdx = [];
positionMatchIdx = {};
for ii = 1 : length(cell_array)
    
    temp = strfind(cell_array{ii},substring);
    
    if isempty(temp)
        continue
    end
    
    numMatches = numMatches + 1;
    cellMatchIdx(numMatches) = ii;
    
    positionMatchIdx{numMatches} = temp;
    
end

end
    