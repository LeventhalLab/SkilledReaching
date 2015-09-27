
load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0027\20140512\R0027Session20140512PawPointFiles.mat');
day = 3;

score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids,averagedCentroidsSuccess, euclidianDistDiffSuccess,  euclidianDistDiffMeanSuccess, euclidianDistDiffStdSuccess]= TrajectoryCalculation(all3dPoints,score,RatID,day,1,2,sucessRate,totalNumReaches)

score = 7;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids, averagedCentroidsFail, euclidianDistDiffFail,  euclidianDistDiffMeanFail, euclidianDistDiffStdFail]= TrajectoryCalculation(all3dPoints,score,RatID,day,1,2,sucessRate,totalNumReaches)

compareReachesEuclidDist(euclidianDistDiffMeanSuccess,euclidianDistDiffStdSuccess,euclidianDistDiffMeanFail,euclidianDistDiffStdFail,RatID,day,11)

load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0027\20140514\R0027Session20140514PawPointFiles.mat');

day = 5;

score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids,averagedCentroidsSuccess, euclidianDistDiffSuccess,  euclidianDistDiffMeanSuccess, euclidianDistDiffStdSuccess]= TrajectoryCalculation(all3dPoints,score,RatID,day,3,4,sucessRate,totalNumReaches)

score = 7;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids, averagedCentroidsFail, euclidianDistDiffFail,  euclidianDistDiffMeanFail, euclidianDistDiffStdFail]= TrajectoryCalculation(all3dPoints,score,RatID,day,3,4,sucessRate,totalNumReaches)

compareReachesEuclidDist(euclidianDistDiffMeanSuccess,euclidianDistDiffStdSuccess,euclidianDistDiffMeanFail,euclidianDistDiffStdFail,RatID,day,12)



load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0027\20140516\R0027Session20140516PawPointFiles.mat');

day = 7;

score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids,averagedCentroidsSuccess, euclidianDistDiffSuccess,  euclidianDistDiffMeanSuccess, euclidianDistDiffStdSuccess]= TrajectoryCalculation(all3dPoints,score,RatID,day,5,6,sucessRate,totalNumReaches)

score = 7;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids, averagedCentroidsFail, euclidianDistDiffFail,  euclidianDistDiffMeanFail, euclidianDistDiffStdFaill]= TrajectoryCalculation(all3dPoints,score,RatID,day,5,6,sucessRate,totalNumReaches)

compareReachesEuclidDist(euclidianDistDiffMeanSuccess,euclidianDistDiffStdSuccess,euclidianDistDiffMeanFail,euclidianDistDiffStdFail,RatID,day,13)