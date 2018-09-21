function [partType, laterality, partNumber] = parseBodyPart(bodypart, varargin)
%
% function to parse a body part name (e.g. 'rightmcp1') into the body part
% type (e.g., 'mcp), part number (e.g., 1 for 1st digit), and laterality
% (e.g., 'right').
%
% INPUTS:
%   bodypart - body part string from DLC output
%
% VARARGS:
%
% OUTPUTS:
%   partType - string containing the type of body part (e.g., 'mcp', 'pip',
%       'pawdorsum', etc.)
%   laterality - 'left', 'right', or empty string (e.g. for pellet or nose)
%   partNumber - an integer 1-4 indicating which digit is marked, or 0 if
%       not relevant (nose, pawdorsum, pellet)

% in case these labels are modified in the future, can change them here
leftLabel = 'left';
rightLabel = 'right';
mcpLabel = 'mcp';
pipLabel = 'pip';
digitLabel = 'digit';
pawDorsumLabel = 'pawdorsum';
noseLabel = 'nose';
pelletLabel = 'pellet';

for iarg = 1 : 2 : nargin - 1
    switch lower(varargin{iarg})
        case 'leftlabel'
            leftLabel = varargin{iarg + 1};
        case 'rightlabel'
            rightLabel = varargin{iarg + 1};
        case 'mcplabel'
            mcpLabel = varargin{iarg + 1};
        case 'piplabel'
            pipLabel = varargin{iarg + 1};
        case 'digitlabel'
            digitLabel = varargin{iarg + 1};
        case 'pawdorsumlabel'
            pawDorsumLabel = varargin{iarg + 1};
        case 'noselabel'
            noseLabel = varargin{iarg + 1};
        case 'pelletlabel'
            pelletLabel = varargin{iarg + 1};
    end
end

partNumber = 0;

if any(strfind(bodypart,leftLabel))
    laterality = 'left';
elseif any(strfind(bodypart,rightLabel))
    laterality = 'right';
else
    laterality = '';
end

if any(strcmpi({noseLabel,pelletLabel},bodypart))
    partType = bodypart;
    return
end

if any(strfind(bodypart,pawDorsumLabel))
    partType = 'pawdorsum';
    return;
end


% only digit indicators are left (at least using the labels we've been
% using as of 9/21/2018
partNumber = str2double(bodypart(end));
if any(strfind(bodypart,mcpLabel))
    partType = 'mcp';
    return;
end
if any(strfind(bodypart,pipLabel))
    partType = 'pip';
    return;
end
if any(strfind(bodypart,digitLabel))
    partType = 'digit';
    return;
end


