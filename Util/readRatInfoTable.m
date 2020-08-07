function ratInfo = readRatInfoTable(csvfname)
%
% function to read rat information in from a .csv spreadsheet (birth dates,
% training dates, interventions, etc.)

dateFormat = 'MM/dd/uuuu';

opts = detectImportOptions(csvfname);

% get all variable names that store dates

VariableNames = opts.VariableNames;
VariableTypes = opts.VariableTypes;
num_vars = length(VariableNames);

for i_var = 1 : num_vars
    if strcmpi(VariableTypes{i_var}, 'datetime')
        opts = setvaropts(opts,VariableNames{i_var},'InputFormat', dateFormat);
    end
end
% dateFields = {'virusDate',...
%               'fiberDate',...
%               'firstDatePretraining',...
%               'firstDateTraining',...
%               'lastDateRetraining',...
%               'firstDateLaser',...
%               'lastDateLaser',...
%               'firstDateOcclusion',...
%               'lastDateOcclusion'};
          

ratInfo = readtable(csvfname, opts);

ratInfo = cleanUpRatTable(ratInfo);
