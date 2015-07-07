function I_bp = histBackProjection(I, modelHist, binLimits)
%
% usage: 
%
% INPUTS:
%   I - image for which to create the histogram backprojection
%   modelHist - n-dimensional matrix containing histogram values. If n==1,
%       the first backprojected histogram is calculated based on the first
%       channel of I. If n==2, the backprojected histogram is calculated
%       based on the first two channels of I, etc. Each row contains
%       histogram values for a single image channel.
%   binLimits - n x m matrix containing the edges of the histogram bins.
%       Each row contains the bin limits for a different channel in image
%       I.
%
% OUTPUTS:
%   I_bp - the backprojected histogram

% make sure modelHist is normalized - IS THIS A GOOD IDEA OR NOT?

if size(modelHist,1) == 1
    n = 1;
else
    n = ndims(modelHist);
end
if length(binLimits) ~= n
    error('binLimits must have n cells, where n is the number of dimensions in modelHist');
end

% WORKING HERE - NEED TO FIGURE OUT A WAY TO AVOID COUNTING BLACK PIXELS IN
% THE MASK; EXCLUDE ALL (0,0,0) POINTS? PERHAPS EXCLUDE THOSE POINTS BACK
% IN THE MAIN TRACKING ROUTINE?
I_bins = zeros(size(I,1),size(I,2),n);
for iCh = 1 : n
    numBins = length(binLimits{iCh}) - 1;    % the number of bins is actually one less than the number of bin limits
    % subtract each bin limit from the current image channel, find where
    % the sign switches from positive to negative - that tells us which bin
    % for each pixel. I think that can work efficiently
    binFlags = true(size(I,1),size(I,2));
    for ii = 2 : numBins + 1    % look for values less than the "right" border of the first bin, go from there
        temp_bins = zeros(size(I,1),size(I,2));
        binDiffs = double(I(:,:,iCh)) - binLimits{iCh}(ii);
        temp_bins(binDiffs < 0 & binFlags) = ii - 1;
        binFlags(binDiffs < 0) = false;
        I_bins(:,:,iCh) = I_bins(:,:,iCh) + temp_bins;
    end
    temp_bins = zeros(size(I,1),size(I,2));
    temp_bins(binFlags) = numBins;
    I_bins(:,:,iCh) = I_bins(:,:,iCh) + temp_bins;
    
    if iCh == 1
        evalString = 'I_bins(ii,jj,1)';
    else
        evalString = sprintf('%s, I_bins(ii,jj,%d)', evalString, iCh);
    end
end

I_bp = zeros(size(I,1),size(I,2));
for ii = 1 : size(I,1)
    for jj = 1 : size(I,2)
%         sprintf('%d, %d', ii, jj)
        I_bp(ii,jj) = eval(['modelHist(' evalString ');']);
    end
end
