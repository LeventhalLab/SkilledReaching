function [ points3d ] = frame_2d_to_3d( points2d, boxCalibration, pawPref, varargin )
%points2d_to_3d Summary of this function goes here
%   Detailed explanation goes here

refine_estimates = true;

for iarg = 1 : 2 : nargin - 4
    switch lower(varargin{iarg})
        case 'refineestimates'
            refine_estimates = varargin{iarg + 1};
    end
end

P1 = eye(4,3);
switch lower(pawPref)
    case 'right'
        P2 = squeeze(boxCalibration.srCal.P(:,:,1));
        sf = squeeze(boxCalibration.srCal.sf);
    case 'left'
        P2 = squeeze(boxCalibration.srCal.P(:,:,2));
        sf = squeeze(boxCalibration.srCal.sf);                     % need to figure out how I organized the scale factor matrix and comment that into the estimate scale function
                                                                   % looks like the columns are the view: 1 = left, 2 = right. The rows are the independent estimates for pairs of rubiks spacings. So, should take the mean across rows to estimate the scale factor in each mirror view
                                                    

end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%