function tableOut = extractTableRows(tableIn,varargin)
%
% extract rows from a table where specific conditions are met in selected
% columns
%
% INPUTS
%   tableIn - input table
%
% VARARGS:
%   a collection of 'name','parameter' pairs. Each 'name' is should be a
%   column header in tableIn. Each 'parameter' is a search value for that
%   column
%
% OUTPUTS
%   tableOut - output table, where only rows where search values match for
%   each 'name' column

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

validRowIdx = true(height(tableIn),1);
for iHeader = 1 : numHeaders
    
    currentEntries = tableIn.(tableHeaders{iHeader});
    validRowIdx = validRowIdx & ismember(currentEntries, searchValues{iHeader});
    
end

tableOut = tableIn(validRowIdx,:);

end