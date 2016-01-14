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
            dateLimits.start = '20140513';
            dateLimits.end = '20140528';
            pawPref = 'right';
            sessionList = {'20140513a','20140514a','20140515a','20140516a','20140519a','20140520a','20140521a','20140522a','20140523a'};
        case 'r0028',
            dateLimits.start = '20140423';
            dateLimits.end = '20140509';
            pawPref = 'left';
            sessionList = {'20140423a','20140424a','20140425a','20140426a','20140427a','20140428a','20140429a','20140430a','20140501a','20140502a','20140505a','20140506a','20140507a','20140508a'};
            % note, if add 5/9, it's session b
        case 'r0029',
            dateLimits.start = '20140423';
            dateLimits.end = '20140509';
            pawPref = 'right';
            sessionList = {'20140423a','20140424a','20140426a','20140427a','20140428a','20140429a','20140430a','20140501a','20140502a','20140505a','20140506a','20140507a','20140508a'};
            % note, if add 5/9, it's session c
        case 'r0030',
            dateLimits.start = '20140423';
            dateLimits.end = '20140509';
            pawPref = 'right';
            sessionList = {'20140423a','20140425a','20140426a','20140427a','20140428a','20140429a','20140430a','20140502a','20140505a','20140506a','20140507a','20140508a'};
            % note, if add 5/1, it's session d
        case 'r0041',
            dateLimits.start = '20150113';
            dateLimits.end = '20150127';
            pawPref = 'right';
            sessionList = {'20150115a','20150116a','20150119a','20150120a','20150122a','20150126a'};
        case 'r0043',
            dateLimits.start = '20150112';
            dateLimits.end = '20150121';
            pawPref = 'left';
            sessionList = {'20150109a','20150110a','20150111a','20150112a','20150113a','20150114a','20150119a','20150120a','20150122a','20150123a'};
        case 'r0055',
            dateLimits.start = '20150112';
            dateLimits.end = '20150123';
            pawPref = 'left';
            sessionList = {'20150110a','20150111a','20150112a','20150113a','20150114a','20150116a','20150119a','20150122a','20150123a'};
    end
    sr_ratInfo(ii).date = dateLimits;
    sr_ratInfo(ii).pawPref = pawPref;
    sr_ratInfo(ii).sessionList = sessionList;
end

