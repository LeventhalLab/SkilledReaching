function matchedDates = matchSessionDates(sessionTables,sessions_to_match)
%
% function to match session dates across rats - for example, last training
% day with last training day, nth laser day with nth laser day, etc.

numRats = length(sessionTables);

numSessions = length(sessions_to_match);
matchedDates = cell(numRats, numSessions);

for i_session = 1 : numSessions
    
    for i_rat = 1 : numRats

        thisRatInfo = ratList(i_rat,:);
        sessionType = determineSessionType(thisRatInfo, allSessionDates);
        for ii = 1 : length(sessionType)
            sessionType(ii).typeFromScoreSheet = reachScores(ii).sessionType;
        end