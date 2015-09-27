load('Z:\SkilledReaching\R0029\R0029-processed\R0029Session20140425PawPointFiles.mat');
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

     
load('Z:\SkilledReaching\R0029\R0029-processed\R0029Session20140427PawPointFiles.mat');
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



load('Z:\SkilledReaching\R0029\R0029-processed\R0029Session20140429PawPointFiles.mat');
day = 7;

score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids,averagedCentroidsSuccess, euclidianDistDiffSuccess,  euclidianDistDiffMeanSuccess, euclidianDistDiffStdSuccess]= TrajectoryCalculation(all3dPoints,score,RatID,day,5,6,sucessRate,totalNumReaches)

score = 7;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids, averagedCentroidsFail, euclidianDistDiffFail,  euclidianDistDiffMeanFail, euclidianDistDiffStdFail]= TrajectoryCalculation(all3dPoints,score,RatID,day,5,6,sucessRate,totalNumReaches)
     
compareReachesEuclidDist(euclidianDistDiffMeanSuccess,euclidianDistDiffStdSuccess,euclidianDistDiffMeanFail,euclidianDistDiffStdFail,RatID,day,13)
