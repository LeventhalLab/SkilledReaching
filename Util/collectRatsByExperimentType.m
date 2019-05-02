function newTable = findSubTable(oldTable, varargin)
%
% 
%
% INPUTS
%   ratInfo - table containing rat information with the following column
%       headers:
%           ratID
%           Sex
%           Virus
%
% VARARGS
%   name,value pairs where the "name" entry is a column header from the
%       ratInfo table and the next entry is the value to extract
%
% OUTPUTS
%   newTable - table with the same variables as ratInfo, selecting for rows
%       that match the criteria in varargin

validRows = false(size(ratInfo,1),1);
for iarg = 2 : 2 : nargin -1
    
    varName = varargin{iarg};
    
    valueList = ratInfo.(varName);
    
    if isnumeric(valueList) || isdatetime(valueList)
        validRows = validRows || (valueList == varargin{iarg + 1});
        continue;
    end
    
    if ischar(valueList)
        validRows = validRows || (strcmpi(valueList, varargin{iarg + 1}));
        continue;
    end
    
    if iscell(valueList)
        
        if ischar(varType,valueList{1})
                validRows = validRows || (strcmpi(valueList, varargin{iarg + 1}));
        else
            validRows = validRows || (valueList == varargin{iarg + 1});
        end
        
    end
    
end

newTable = ratInfo(validRows,:);

end