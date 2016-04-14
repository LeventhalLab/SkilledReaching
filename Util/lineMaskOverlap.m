function overlapMask = lineMaskOverlap(mask, lineCoeff, varargin)
%
% INPUTS:
%   mask - bw mask of an image in which to find overlap with a line
%   lineCoeff - [A,B,C] where Ax + By + C = 0
%
% OUTPUTS:

distThresh = 2;

for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'distthresh',
            distThresh = varargin{iarg + 1};
    end
end

overlapMask = false(size(mask));

% while all(overlapMask(:) == 0)
    [y,x] = find(mask);


    for ii = 1 : length(y)

        lineValue = lineCoeff(1) * x(ii) + ...
                    lineCoeff(2) * y(ii) + ...
                    lineCoeff(3);
        if abs(lineValue) < distThresh
            overlapMask(y(ii),x(ii)) = true;
        end
    end
%     mask = imdilate(mask,strel('disk',1));   % grow mask until there is overlap
    
% end