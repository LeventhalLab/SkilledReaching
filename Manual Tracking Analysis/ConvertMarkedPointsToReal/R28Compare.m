load('Z:\SkilledReaching\R0028\R0028-processed\R0028Session20140425PawPointFiles.mat');
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,3,1,2,sucessRate,totalNumReaches)

% hold on
% score = 7;
% [all3dPoints] = RatDattoReal3Dpoints(RatData,score);
% [sucessRate, failureRate,RatID] = getRatInfo(RatData)
% [allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,3,1,2,sucessRate)
     
load('Z:\SkilledReaching\R0028\R0028-processed\R0028Session20140427PawPointFiles.mat');
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,5,3,4,sucessRate,totalNumReaches)

% hold on
% score = 7;
% [all3dPoints] = RatDattoReal3Dpoints(RatData,score);
% [sucessRate, failureRate,RatID] = getRatInfo(RatData)
% [allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,5,3,4,sucessRate)

load('Z:\SkilledReaching\R0028\R0028-processed\R0028Session20140427PawPointFiles.mat');
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,7,5,6,sucessRate,totalNumReaches)

% hold on
% score = 7;
% [all3dPoints] = RatDattoReal3Dpoints(RatData,score);
% [sucessRate, failureRate,RatID] = getRatInfo(RatData)
% [allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,7,5,6,sucessRate)