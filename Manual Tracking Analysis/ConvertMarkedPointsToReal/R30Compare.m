load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0030\20140423\R0030Session20140423PawPointFiles.mat')

score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,3,1,2,sucessRate)

     
load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0030\20140424\R0030Session20140424PawPointFiles.mat');

score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,5,3,4,sucessRate)

load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0030\20140425\R0030Session20140425PawPointFiles.mat')

score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,7,5,6,sucessRate)