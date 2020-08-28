function newTable = findSubTable(oldTable, varargin)
%
% extract elements of a table based on specific values in specified columns
%
% INPUTS
%   oldTable - table containing rat information with the following column
%       headers:
%           ratID
%           Sex
%           Virus
%
% VARARGS
%   name,value pairs where the "name" entry is a column header from the
%       oldTable table and the next entry is the value to extract
%
% OUTPUTS
%   newTable - table with the same variables as oldTable, selecting for rows
%       that match the criteria in varargin

validRows = true(size(oldTable,1),1);
for iarg = 1 : 2 : nargin -1
    
    varName = varargin{iarg};
    valueList = oldTable.(varName);
    
    if iscategorical(valueList)
        valueList = cellstr(valueList);
    end
    if iscell(valueList)
        if ischar(valueList{1})
            valueList = lower(valueList);
        end
    end
    if iscell(varargin{iarg + 1})
        if ischar(varargin{iarg + 1}{1})
            testValue = lower(varargin{iarg + 1});
        else
            testValue = varargin{iarg + 1};
        end
    end
    if ischar(valueList)
        valueList = lower(valueList);
    end
    if ischar(varargin{iarg + 1})
        testValue = lower(varargin{iarg + 1});
    end
    
    validRows = validRows & ismember(valueList,testValue);
    
end

newTable = oldTable(validRows,:);

end