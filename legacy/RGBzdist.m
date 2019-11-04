function RGBz_dist = RGBzdist(I, RGBmean, RGBstd)
%
% usage: RGBz_dist = RGBzdist(I, RGBmean, RGBstd)
%
% INPUTS:
%
% OUTPUTS:

RGBz = zeros(size(I));
for ii = 1 : 3
    RGBz(:,:,ii) = (squeeze(I(:,:,ii)) - RGBmean(ii)) / RGBstd(ii);
end

RGBz_dist = sqrt(sum(RGBz.^2,3));