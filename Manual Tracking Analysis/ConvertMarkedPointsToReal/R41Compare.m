load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0041\20150115\R0041Session20150115PawPointFiles.mat');
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,3,1,2,sucessRate)
% 
% hold on
% score = 7;
% [all3dPoints] = RatDattoReal3Dpoints(RatData,score);
% [allCentroids]= TrajectoryCalculation(all3dPoints,score,3,1,2)
     
load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0041\20150119\R0041Session20150119PawPointFiles.mat');
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate, RatID] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,5,3,4,sucessRate)

% hold on
% score = 7;
% [all3dPoints] = RatDattoReal3Dpoints(RatData,score);
% [allCentroids]= TrajectoryCalculation(all3dPoints,score,5,3,4)

load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0041\20150122\R0041Session20150122PawPointFiles.mat');
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,7,5,6,sucessRate)

% hold on
% score = 7;
% [all3dPoints] = RatDattoReal3Dpoints(RatData,score);
% [allCentroids]= TrajectoryCalculation(all3dPoints,score,7,5,6)