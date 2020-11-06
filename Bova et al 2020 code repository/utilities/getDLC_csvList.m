function [directViewDir,mirrorViewDir,direct_csvList,mirror_csvList] = getDLC_csvList(fullSessionDir)
%
% function to find all the deeplabcut-generated .csv files in a folder
%
% INPUTS
%   fullSessionDir - directory containing DLC output for the session of
%       interest
%
% OUTPUTS
%   directViewDir - directory containing the .csv DLC output files for the
%       direct camera view
%   mirrorViewDir - directory containing the .csv DLC output files for the
%       mirror view
%   direct_csvList - list of direct view .csv files
%   mirror_csvList - list of mirror view .csf files

vidView = {'direct','right','left'};
numViews = length(vidView);

[~,curSession,~] = fileparts(fullSessionDir);

directViewDir = fullfile(fullSessionDir, [curSession '_direct']);

cd(directViewDir);
direct_csvList = dir('*.csv');
if isempty(direct_csvList)
    mirror_csvList = direct_csvList;
    mirrorViewDir = '';
    return;
end

% eliminate hidden files whose name starts with '._'. Not sure where those
% come from but it's annoying...
new_csvList = direct_csvList(1);
numValidNames = 0;
for ii = 1 : length(direct_csvList)
    if strcmp(direct_csvList(ii).name(1:2),'._')
        continue;
    end
    numValidNames = numValidNames + 1;
    new_csvList(numValidNames) = direct_csvList(ii);
end
direct_csvList = new_csvList;

numMarkedVids = length(direct_csvList);
% ratID, date, etc. for each individual video
directVidTime = cell(1, numMarkedVids);
directVidNum = zeros(numMarkedVids,1);

% find all the direct view videos that are available
uniqueDateList = {};
for ii = 1 : numMarkedVids   
    [directVid_ratID(ii),directVidDate{ii},directVidTime{ii},directVidNum(ii)] = ...
                extractDLC_CSV_identifiers(direct_csvList(ii).name);
    if isempty(uniqueDateList)
        uniqueDateList{1} = directVidDate{ii};
    elseif ~any(strcmp(uniqueDateList,directVidDate{ii}))
        uniqueDateList{end+1} = directVidDate{ii};
    end
end

cd(fullSessionDir);
for iView = 1 : numViews
    possibleMirrorDir = [curSession '_' vidView{iView}];
    if ~exist(possibleMirrorDir,'dir') || contains(lower(possibleMirrorDir),'direct')
        % if this view doesn't exist or if it's the direct view, skip
        % forward (already found the direct view files)
        continue;
    end
    mirrorViewDir = fullfile(fullSessionDir, possibleMirrorDir);
    break
end

cd(mirrorViewDir)
mirror_csvList = dir('*.csv');
% eliminate hidden files whose name starts with '._'. Not sure where those
% come from but it's annoying...
new_csvList = mirror_csvList(1);

numValidNames = 0;
for ii = 1 : length(mirror_csvList)
    if strcmp(mirror_csvList(ii).name(1:2),'._')
        continue;
    end
    numValidNames = numValidNames + 1;
    new_csvList(numValidNames) = mirror_csvList(ii);
end
mirror_csvList = new_csvList;

end