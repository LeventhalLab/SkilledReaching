load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0027\20140512\R0027Session20140512PawPointFiles.mat');

score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,3,1,2,sucessRate,totalNumReaches)

score = 7;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,3,1,2,sucessRate,totalNumReaches)

     

     
load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0027\20140514\R0027Session20140514PawPointFiles.mat');

score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,5,3,4,sucessRate,totalNumReaches)

score = 7;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,5,3,4,sucessRate,totalNumReaches)

     


load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0027\20140516\R0027Session20140516PawPointFiles.mat');

score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,7,5,6,sucessRate,totalNumReaches)

score = 7;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[sucessRate, failureRate,RatID,totalNumReaches] = getRatInfo(RatData)
[allCentroids]= TrajectoryCalculation(all3dPoints,score,RatID,7,5,6,sucessRate,totalNumReaches)

     