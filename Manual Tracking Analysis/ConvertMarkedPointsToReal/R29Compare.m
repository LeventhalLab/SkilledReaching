load('Z:\SkilledReaching\R0029\R0029-processed\R0029Session20140425PawPointFiles.mat');
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,3,1,2,sucessRate)

% hold on
% score = 7;
% [all3dPoints] = RatDattoReal3Dpoints(RatData,score);
% [sucessRate, failureRate,RatID] = getRatInfo(RatData)
% [allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,3,1,2,sucessRate)
     
load('Z:\SkilledReaching\R0029\R0029-processed\R0029Session20140427PawPointFiles.mat');
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,5,3,4,sucessRate)
 
% hold on
% score = 7;
% [all3dPoints] = RatDattoReal3Dpoints(RatData,score);
% [sucessRate, failureRate,RatID] = getRatInfo(RatData)
% [allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,5,3,4,sucessRate)

load('Z:\SkilledReaching\R0029\R0029-processed\R0029Session20140429PawPointFiles.mat');
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,7,5,6,sucessRate)

% hold on
% score = 7;
% [all3dPoints] = RatDattoReal3Dpoints(RatData,score);
% [sucessRate, failureRate,RatID] = getRatInfo(RatData)
% [allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,7,5,6,sucessRate)