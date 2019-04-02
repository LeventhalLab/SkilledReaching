function reachScores = readReachScores(fname, varargin)
%
% INPUTS
%   fname - name of .csv file containing reach scores for each session
%
% OUTPUTS
%   reachScores - structure array with an entry for each test session with
%       the following fields:
%           .date - session date as a datetime object
%           .scores - score for each reach

% REACHING SCORES:
%
% 0 ? No pellet, mechanical failure
% 1 -  First trial success (obtained pellet on initial limb advance)
% 2 -  Success (obtain pellet, but not on first attempt)
% 3 -  Forelimb advance -pellet dropped in box
% 4 -  Forelimb advance -pellet knocked off shelf
% 5 -  Obtain pellet with tongue
% 6 -  Walk away without forelimb advance, no forelimb advance
% 7 -  Reached, pellet remains on shelf
% 8 - Used only contralateral paw
% 9 - Laser fired at the wrong time
% 10 ?Used preferred paw after obtaining or moving pellet with tongue

csvDateFormat = 'MM/dd/yyyy';
for iarg = 1 : 2 : nargin - 1
    switch lower(varargin{iarg})
        case 'csvdateformat'
            csvDateFormat = varargin{iarg + 1};
    end
end


scoresTable = readtable(fname);

numValidSessions = 0;

numCols = size(scoresTable,2);
% numRows = size(scoresTable,1);

for iCol = 2 : numCols
    
     temp = table2cell(scoresTable(1,iCol));
     if isempty(temp)
         continue;
     end
     
     sessionDate = temp{1};
     if isnumeric(sessionDate)
         sessionDate = num2str(sessionDate);
     end
     if ~isdatetime(sessionDate)
         if ischar(sessionDate)
             if strcmp(sessionDate,'NaN')
                 continue;
             end
             sessionDate = datetime(sessionDate,'inputformat',csvDateFormat);
             numValidSessions = numValidSessions + 1;
         else
             continue;
%              sessionDate = NaT;
         end
     end
     if sessionDate.Year < 100
         sessionDate.Year = sessionDate.Year + 2000;
     end

     reachScores(numValidSessions).date = sessionDate;
     temp = table2cell(scoresTable(2,iCol));
     reachScores(numValidSessions).sessionType = temp{1};
     
     temp = table2cell(scoresTable(3:end,iCol));
     reachScores(numValidSessions).scores = NaN(length(temp),1);
     for ii = 1 : length(temp)
         if ischar(temp{ii})
             reachScores(numValidSessions).scores(ii) = str2double(temp{ii});
         else
             reachScores(numValidSessions).scores(ii) = temp{ii};
         end
     end
     
end

end    % function