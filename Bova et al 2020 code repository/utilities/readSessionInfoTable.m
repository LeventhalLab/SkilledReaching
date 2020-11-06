function sessionInfo = readSessionInfoTable(csvfname)
%
% function to read rat information in from a .csv spreadsheet (birth dates,
% training dates, interventions, etc.)

sessionInfo = readtable(csvfname);

sessionInfo = cleanUpSessionsTable(sessionInfo);
