function [bodyparts,direct_bpMatch_idx,mirror_bpMatch_idx] = matchBodyPartIndices(direct_bp,mirror_bp)

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
    