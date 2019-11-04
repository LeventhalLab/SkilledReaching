function summaryStats = summarize3DendPts(lastTrainingAnalyisis, laserAnalysis, occlusionAnalysis, ratInfo)
%
% INPUTS
%
% OUTPUTS

% find rats with ChR2, during reach stimulation
duringReach_ChR2 = find(ratInfo.laserTiming == 'During Reach' & ratInfo.Virus == 'ChR2');
betweenReach_ChR2 = find(ratInfo.laserTiming == 'Between Reach' & ratInfo.Virus == 'ChR2');


duringReachChR2_table = ratInfo(duringReach_ChR2,:);
betweenReachChR2_table = ratInfo(duringReach_ChR2,:);

% collect During Reach data

for i_rat = 1 : size(duringReachChR2_table,1)