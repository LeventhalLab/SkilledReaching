function [direct_mask_b, mirror_mask_b] = matchSilhouettes(direct_mask, mirror_mask, fundmat, bboxes)
%
% INPUTS:
%
% OUTPUTS:
%

[direct_tangentPoints, direct_tangentLines] = findTangentToEpipolarLine(direct_mask, fundmat, bboxes(1,:));
[mirror_tangentPoints, mirror_tangentLines] = findTangentToEpipolarLine(mirror_mask, fundmat', bboxes(2,:));

end