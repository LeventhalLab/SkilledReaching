function [ sr_ratInfo ] = get_sr_RatList(  )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% INPUTS:
%
% OUTPUTS:
%   sr_ratInfo

SRparentDir_a = '/Volumes/RecordingsLeventhal04/SkilledReaching';
SRparentDir_b = '/Volumes/RecordingsLeventhal3/SkilledReaching';
ratIDlist = ['R0027';'R0028';'R0029';'R0030';'R0041';'R0043';'R0055'];
% ratIDlist_a = ratIDlist(1:4,:);
% ratIDlist_b = ratIDlist(5:end,:);
for ii = 1 : size(ratIDlist,1)
    ratID = ratIDlist(ii,:);
    sr_ratInfo(ii).ID = ratID;
    sr_ratInfo(ii).ratNum = str2num(ratID(2:end));
    sr_ratInfo(ii).shortID = ['R' num2str(sr_ratInfo(ii).ratNum)];
    if ii < 5
        sr_ratInfo(ii).directory.parent = fullfile(SRparentDir_a, ratID);
    else
        sr_ratInfo(ii).directory.parent = fullfile(SRparentDir_b, ratID);
    end
    sr_ratInfo(ii).directory.rawdata = fullfile(sr_ratInfo(ii).directory.parent,[ratID, '-rawdata']);
    sr_ratInfo(ii).directory.processed = fullfile(sr_ratInfo(ii).directory.parent,[ratID, '-processed']);
    
    switch lower(ratID)
        case 'r0027',
            sr_ratInfo(ii).date.start = '20140513';
            sr_ratInfo(ii).date.end = '20140528';
            sr_ratInfo(ii).pawPref = 'right';
        case 'r0028',
            sr_ratInfo(ii).date.start = '20140423';
            sr_ratInfo(ii).date.end = '20140509';
            sr_ratInfo(ii).pawPref = 'left';
        case 'r0029',
            sr_ratInfo(ii).date.start = '20140423';
            sr_ratInfo(ii).date.end = '20140509';
            sr_ratInfo(ii).pawPref = 'right';
        case 'r0030',
            sr_ratInfo(ii).date.start = '20140423';
            sr_ratInfo(ii).date.end = '20140509';
            sr_ratInfo(ii).pawPref = 'right';
        case 'r0041',
            sr_ratInfo(ii).date.start = '20150113';
            sr_ratInfo(ii).date.end = '20150127';
            sr_ratInfo(ii).pawPref = 'right';
        case 'r0043',
            sr_ratInfo(ii).date.start = '20150112';
            sr_ratInfo(ii).date.end = '20150121';
            sr_ratInfo(ii).pawPref = 'left';
        case 'r0055',
            sr_ratInfo(ii).date.start = '20150112';
            sr_ratInfo(ii).date.end = '20150123';
            sr_ratInfo(ii).pawPref = 'left';
    end
end

