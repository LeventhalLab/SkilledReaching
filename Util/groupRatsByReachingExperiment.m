function tableOut = groupRatsByReachingExperiment(ratInfo,varargin)
%
%
%
% INPUTS
%
% OUTPUTS
%

numHeaders = (nargin - 1) / 2;
if numHeaders ~= round(numHeaders)
    error('must have an even number of name-value pairs')
end

tableHeaders = cell(numHeaders,1);
searchValues = cell(numHeaders,1);
curHeader = 0;
for iarg = 1 : 2 : nargin - 1
    curHeader = curHeader + 1;
    tableHeaders{curHeader} = varargin{iarg};
    searchValues{curHeader} = varargin{iarg+1};
end

validRowIdx = true(height(ratInfo),1);
for iHeader = 1 : numHeaders
    
    currentEntries = ratInfo.(tableHeaders{iHeader});
    validRowIdx = validRowIdx & ismember(currentEntries, searchValues{iHeader});
    
end

tableOut = ratInfo(validRowIdx,:);

end