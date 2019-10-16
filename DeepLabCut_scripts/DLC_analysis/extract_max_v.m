function [max_pd_v] = extract_max_v(reachData)
%
% for now, assume extracting the endpoints for the first reach
%

num_trials = length(reachData);
max_pd_v = NaN(num_trials,1);

for iTrial = 1 : num_trials
    if isempty(reachData(iTrial).pd_v)
        continue;
    end
    max_pd_v(iTrial) = max(reachData(iTrial).pd_v{1});
end