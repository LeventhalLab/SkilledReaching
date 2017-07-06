function [ points3d ] = points2d_to_3d( points2d, boxCalibration, varargin )
%points2d_to_3d Summary of this function goes here
%   Detailed explanation goes here

refine_estimates = true;

for iarg = 1 : 2 : nargin - 4
    switch lower(varargin{iarg})
        case 'refineestimates'
            refine_estimates = varargin{iarg + 1};
    end
end



end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%