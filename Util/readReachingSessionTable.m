function sessionsInfo = readReachingSessionTable(csvfname)
%
% function to read session information in from a .csv spreadsheet (dates,
% whether the laser was on, etc.)

sessionsInfo = readtable(csvfname);

sessionsInfo = cleanUpSessionsTable(sessionsInfo);
