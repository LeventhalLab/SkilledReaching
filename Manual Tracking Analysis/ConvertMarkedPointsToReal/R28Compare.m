load('Z:\SkilledReaching\R0029\R0029-processed\R0029Session20140425PawPointFiles.mat');
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids]= TrajectoryCalculation(all3dPoints,score,1,2)

hold on
score = 7;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids]= TrajectoryCalculation(all3dPoints,score,1,2)
     
load('Z:\SkilledReaching\R0029\R0029-processed\R0029Session20140427PawPointFiles.mat');
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids]= TrajectoryCalculation(all3dPoints,score,3,4)

hold on
score = 7;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids]= TrajectoryCalculation(all3dPoints,score,3,4)

load('Z:\SkilledReaching\R0029\R0029-processed\R0029Session20140427PawPointFiles.mat');
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids]= TrajectoryCalculation(all3dPoints,score,5,6)

hold on
score = 7;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids]= TrajectoryCalculation(all3dPoints,score,5,6)