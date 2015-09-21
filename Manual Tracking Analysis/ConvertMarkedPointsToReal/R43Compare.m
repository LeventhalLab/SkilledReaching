load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0043\20150109\R0043Session20150109PawPointFiles.mat');

score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,3,1,2,sucessRate)

     
 load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0043\20150111\R0043Session20150111PawPointFiles.mat');


score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,5,3,4,sucessRate)

load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0043\20150113\R0043Session20150113PawPointFiles.mat');

score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,7,5,6,sucessRate)