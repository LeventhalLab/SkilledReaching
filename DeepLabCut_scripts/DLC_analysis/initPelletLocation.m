function initPellet3D = initPelletLocation(pawTrajectory,bodyparts,frameRate,frameTimeLimits,triggerTime, varargin)

time_to_average_prior_to_reach = 0.1;

for iarg = 1 : 2 : nargin - 5
    switch lower(varargin{iarg})
        case 'timepriortoreach'
            time_to_average_prior_to_reach = varargin{iarg + 1};
    end
end

% figure out the trigger frame
triggerFrame = round((triggerTime + frameTimeLimits(1)) * frameRate);
preTriggerFrame = triggerFrame - round(time_to_average_prior_to_reach * frameRate);

pelletIdx3D = strcmpi(bodyparts,'pellet');

pelletPts = squeeze(pawTrajectory(:,:,pelletIdx3D));

% zeros in the pawTrajectory array represent points where the pellet wasn't
% visible in at least one view

initPelletPts = pelletPts(preTriggerFrame:triggerFrame,:);

validPelletPts = initPelletPts(initPelletPts(:,1)>0,:);

if isempty(validPelletPts)
    initPellet3D = [];
else
    initPellet3D = mean(validPelletPts);
end

end