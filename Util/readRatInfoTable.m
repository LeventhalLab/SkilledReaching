function ratInfo = readRatInfoTable(csvfname)
%
% function to read rat information in from a .csv spreadsheet (birth dates,
% training dates, interventions, etc.)

ratInfo = readtable(csvfname);

ratInfo = cleanUpRatTable(ratInfo);
