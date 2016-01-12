function plotSessionTrajectories(sr_ratInfo, sessionName, scores, varargin)
%
% INPUTS:
%
% OUTPUTS:
%

h_axes = 0;
for iarg = 1 : 2 : nargin - 3
    switch lower(varargin{iarg})
        case 'axes',
            h_axes = varargin{iarg + 1};
    end
end


ratID = sr_ratInfo.ID;
            
processed_rootDir = sr_ratInfo.directory.processed;
rawdata_rootDir = sr_ratInfo.directory.rawdata;

reconstructionName = [ratID '_' sessionName '_trajectories.mat'];
processedDir = [ratID '_' sessionName];
reconstructionName = fullfile(processed_rootDir, processedDir, reconstructionName);

load(reconstructionName);

if h_axes == 0
    figure;
else
    axes(h_axes);
end

validTrialIdx = ismember(trajectory_metadata.csv_scores,scores);
validTrialNumbers = trajectory_metadata.csv_trialNums(find(validTrialIdx));


% plot3(points3d

end