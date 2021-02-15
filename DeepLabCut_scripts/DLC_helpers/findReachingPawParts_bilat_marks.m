function [mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts_bilat_marks(bodyparts,pawPref,varargin)
%
% find the indices of paw parts from the list output by DLC
%
% INPUTS
%   bodyparts - cell array containing strings describing each bodypart in
%       the same order as in the pawTrajectory array
%   pawPref - 'left' or 'right'
%
% VARARGS:
%   mcpstring - string that defines mcp body part labels from DLC
%   pipstring - string that defines pip body part labels from DLC
%   digitstring - string that defines digit tip body part labels from DLC
%   pawdorsumstring - string that defines paw dorsum lables from DLC
%
% OUTPUTS
%   mcpIdx - indices of mcp's in bodyparts
%   pipIdx - indices of pip's in bodyparts
%   digIdx - indices of digit tips in bodyparts
%   pawDorsumIdx - index of reaching paw dorsum in bodyparts

if iscategorical(pawPref)
    pawPref = char(pawPref);
end

mcpString = 'mcp';
pipString = 'pip';
digitString = 'digit';
pawDorsumString = 'pawdorsum';

for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'mcpstring'
            mcpString = varargin{iarg + 1};
        case 'pipstring'
            pipString = varargin{iarg + 1};
        case 'digitstring'
            digitString = varargin{iarg + 1};
        case 'pawdorsumstring'
            pawDorsumString = varargin{iarg + 1};
    end
end
mcpIdx = zeros(4,1);
pipIdx = zeros(4,1);
digIdx = zeros(4,1);

for iDigit = 1 : 4
    % find mcp indices
    testString = sprintf('%s%d',mcpString,iDigit);
    mcpFind = strfind(bodyparts,testString);
    
    testString = sprintf('%s%d',pipString,iDigit);
    pipFind = strfind(bodyparts,testString);
    
    testString = sprintf('%s%d',digitString,iDigit);
    digFind = strfind(bodyparts,testString);
    
    for ii = 1 : length(bodyparts)
        
        if ~isempty(mcpFind{ii})
            mcpIdx(iDigit) = ii;
        end
        if ~isempty(pipFind{ii})
            pipIdx(iDigit) = ii;
        end
        if ~isempty(digFind{ii})
            digIdx(iDigit) = ii;
        end
    end
    
end

reachingPawString = [pawPref,pawDorsumString];
pawFind = strfind(bodyparts,reachingPawString);

for ii = 1 : length(bodyparts)

    if ~isempty(pawFind{ii})
        pawDorsumIdx = ii;
    end

end