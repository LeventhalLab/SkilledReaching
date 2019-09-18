function [frameRange,interp_trajectory] = smoothSingleTrajectory(trajectory, varargin)
%
% INPUTS
%
% OUTPUTS
%

windowLength = 10;
smoothMethod = 'gaussian';

for iarg = 1 : 2 : nargin - 1
    switch lower(varargin{iarg})
        case 'windowlength'
            windowLength = varargin{iarg+1};
        case 'smoothmethod'
            smoothMethod = varargin{iarg+1};
    end
end
smoothedTrajectory = smoothdata(trajectory,smoothMethod,windowLength,'omitnan');

firstValidPoint = find(~isnan(trajectory(:,1)),1,'first');
lastValidPoint = find(~isnan(trajectory(:,1)),1,'last');
numPoints = lastValidPoint - firstValidPoint + 1;
interp_trajectory = zeros(numPoints,3);
for iDim = 1 : 3
    x = find(~isnan(trajectory(:,iDim)));
    xq = x(1) : x(end);
    interp_trajectory(:,iDim) = pchip(x,smoothedTrajectory(x,iDim),xq);
end

frameRange = [firstValidPoint,lastValidPoint];

%     for iDim = 1 : 3
%         figure(iDim)
%         hold off
%         plot(xq,interp_trajectory(:,iDim));
%         hold on
%         plot(fullTrajectory(:,iDim))
%         plot(smoothedTrajectory(:,iDim));
%     end