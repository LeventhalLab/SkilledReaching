clc
clear
close all


load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0043\20150109\R0043Session20150109PawPointFiles.mat');
day = 3;

score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids,averagedCentroidsSuccess, euclidianDistDiffSuccess,  euclidianDistDiffMeanSuccess, euclidianDistDiffStdSuccess]= TrajectoryCalculation(all3dPoints,score,RatID,day,1,2,sucessRate,totalNumReaches)

score = 7;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids, averagedCentroidsFail, euclidianDistDiffFail,  euclidianDistDiffMeanFail, euclidianDistDiffStdFail]= TrajectoryCalculation(all3dPoints,score,RatID,day,1,2,sucessRate,totalNumReaches)

[averagedEuclidDistSuccess,  averagedEuclidDistFail,averagedEuclidDistSuccessStd,averagedEuclidDistFailStd]  = compareReachesEuclidDist(euclidianDistDiffMeanSuccess,euclidianDistDiffStdSuccess,euclidianDistDiffMeanFail,euclidianDistDiffStdFail,RatID,day,11)

allAveragedEuclidDistSuccess{1} = averagedEuclidDistSuccess;
allAveragedEuclidDistFail{1} = averagedEuclidDistFail;
allAveragedEuclidDistSuccessStd{1}= averagedEuclidDistSuccessStd;
allAveragedEuclidDistFailStd{1} = averagedEuclidDistFailStd; 




load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0043\20150111\R0043Session20150111PawPointFiles.mat');
day = 5;

score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids,averagedCentroidsSuccess, euclidianDistDiffSuccess,  euclidianDistDiffMeanSuccess, euclidianDistDiffStdSuccess]= TrajectoryCalculation(all3dPoints,score,RatID,day,3,4,sucessRate,totalNumReaches)

score = 4;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids, averagedCentroidsFail, euclidianDistDiffFail,  euclidianDistDiffMeanFail, euclidianDistDiffStdFail]= TrajectoryCalculation(all3dPoints,score,RatID,day,3,4,sucessRate,totalNumReaches)

[averagedEuclidDistSuccess,  averagedEuclidDistFail,averagedEuclidDistSuccessStd,averagedEuclidDistFailStd]  = compareReachesEuclidDist(euclidianDistDiffMeanSuccess,euclidianDistDiffStdSuccess,euclidianDistDiffMeanFail,euclidianDistDiffStdFail,RatID,day,12)


allAveragedEuclidDistSuccess{2} = averagedEuclidDistSuccess;
allAveragedEuclidDistFail{2} = averagedEuclidDistFail;
allAveragedEuclidDistSuccessStd{2}= averagedEuclidDistSuccessStd;
allAveragedEuclidDistFailStd{2} = averagedEuclidDistFailStd; 

load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0043\20150113\R0043Session20150113PawPointFiles.mat');
day = 7;

score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids,averagedCentroidsSuccess, euclidianDistDiffSuccess,  euclidianDistDiffMeanSuccess, euclidianDistDiffStdSuccess]= TrajectoryCalculation(all3dPoints,score,RatID,day,5,6,sucessRate,totalNumReaches)

score = 7;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids, averagedCentroidsFail, euclidianDistDiffFail,  euclidianDistDiffMeanFail, euclidianDistDiffStdFail]= TrajectoryCalculation(all3dPoints,score,RatID,day,5,6,sucessRate,totalNumReaches)
    

[averagedEuclidDistSuccess,  averagedEuclidDistFail,averagedEuclidDistSuccessStd,averagedEuclidDistFailStd]  = compareReachesEuclidDist(euclidianDistDiffMeanSuccess,euclidianDistDiffStdSuccess,euclidianDistDiffMeanFail,euclidianDistDiffStdFail,RatID,day,13)

allAveragedEuclidDistSuccess{3} = averagedEuclidDistSuccess;
allAveragedEuclidDistFail{3} = averagedEuclidDistFail;
allAveragedEuclidDistSuccessStd{3}= averagedEuclidDistSuccessStd;
allAveragedEuclidDistFailStd{3} = averagedEuclidDistFailStd; 