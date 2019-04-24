function [directViewDir,mirrorViewDir,direct_csvList,mirror_csvList] = getDLC_csvList(fullSessionDir)
%
% function to find all the deeplabcut-generated .csv files in a folder
%
% INPUTS
%   fullSessionDir
%
% OUTPUTS
%   directViewDir
%   mirrorViewDir
%   direct_csvList
%   mirror_csvList

vidView = {'direct','right','left'};
numViews = length(vidView);

[~,curSession,~] = fileparts(fullSessionDir);

directViewDir = fullfile(fullSessionDir, [curSession '_direct']);

cd(directViewDir);
direct_csvList = dir('*.csv');
if isempty(direct_csvList)
    mirror_csvList = direct_csvList;
    return;
end

numMarkedVids = length(direct_csvList);
% ratID, date, etc. for each individual video
directVidTime = cell(1, numMarkedVids);
directVidNum = cell(numMarkedVids,1);

% find all the direct view videos that are available
uniqueDateList = {};
for ii = 1 : numMarkedVids   
    [directVid_ratID(ii),directVidDate{ii},directVidTime{ii},directVidNum{ii}] = ...
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