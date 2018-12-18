function smoothed_trajectory = smoothTrajectory(rawTrajectory,varargin)
% function smoothed_trajectory = smoothTrajectory(rawTrajectory,trialEstimate,varargin)
%
% INPUTS
%   rawTrajectory - 
%
% OUTPUTS
%
%

numTrajectoryPoints = 100;

if nargin > 1
    numTrajectoryPoints = varargin{1};
end

step1 = zeros(size(rawTrajectory));
% temp = zeros(size(rawTrajectory));
% numFrames = size(rawTrajectory,1);
% isEstimate = trialEstimate(:,1) | trialEstimate(:,2);   % left over from
% trying to weight estimates
% w = ones(numFrames,1);
% w(isEstimate) = 0.2;
for iDim = 1 : size(rawTrajectory,2)
    step1(:,iDim) = smooth(rawTrajectory(:,iDim),'rlowess');
%     temp(:,iDim) = csaps(1:numFrames,rawTrajectory(:,iDim),[],1:numFrames,w);
end

smoothed_trajectory = evenlySpacedPointsAlongTrajectory(step1,numTrajectoryPoints);
% temp2 = evenlySpacedPointsAlongTrajectory(temp,numTrajectoryPoints);

% figure
% for ii = 1 : 3
%     subplot(3,1,ii)
%     plot(smoothed_trajectory(:,ii))
%     hold on
%     plot(temp2(:,ii))
% %     scatter(rawTrajectory(:,1))
% end
% 
% figure
% plot3(smoothed_trajectory(:,1),smoothed_trajectory(:,3),smoothed_trajectory(:,2))
% hold on
% plot3(temp2(:,1),temp2(:,3),temp2(:,2))
% scatter3(rawTrajectory(:,1),rawTrajectory(:,3),rawTrajectory(:,2))



% MAYBE THERE'S SOME FANCY STUFF STILL TO DO FOR INTERPOLATING...WE'LL SEE
end

