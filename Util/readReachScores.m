function reachScores = readReachScores(fname,varargin)
%
% INPUTS
%   fname - 
%
% OUTPUTS
%   reachScores - structure with the following fields:
%       .
%

maxTrialNum = 100;

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

scoresTable = readtable(fname);

numValidSessions = 0;

numCols = size(scoresTable,2);
% numRows = size(scoresTable,1);

for iCol = 2 : numCols
    
     temp = table2cell(scoresTable(1,iCol));
     if isempty(temp)
         continue;
     end
     numValidSessions = numValidSessions + 1;
     
     reachScores(numValidSessions).date = temp{1};
     
     temp = table2cell(scoresTable(3:end,iCol));
     reachScores(numValidSessions).scores = NaN(length(temp),1);
     for ii = 1 : length(temp)
         reachScores(numValidSessions).scores(ii) = str2double(temp{ii});
     end
     
end