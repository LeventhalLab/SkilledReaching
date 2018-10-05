function [mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref,varargin)
%
% INPUTS
%
% OUTPUTS
%

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