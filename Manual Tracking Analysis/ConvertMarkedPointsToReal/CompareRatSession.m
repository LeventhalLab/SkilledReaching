load('C:\Users\Administrator\Desktop\Rat 27 PawTracking Data\Scores 1\R0027Session20140512PawPointFiles.mat');     
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids]= TrajectoryCalculation(all3dPoints,score,1,2)

hold on
load('C:\Users\Administrator\Desktop\Rat 27 PawTracking Data\Scores 7\R0027Session20140512PawPointFiles.mat');
score = 7;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids]= TrajectoryCalculation(all3dPoints,score,1,2)


load('C:\Users\Administrator\Desktop\Rat 27 PawTracking Data\Scores 1\R0027Session20140514PawPointFiles.mat');     
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids]= TrajectoryCalculation(all3dPoints,score,3,4)

hold on
load('C:\Users\Administrator\Desktop\Rat 27 PawTracking Data\Scores 7\R0027Session20140514PawPointFiles.mat');
score = 7;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids]= TrajectoryCalculation(all3dPoints,score,3,4)

load('C:\Users\Administrator\Desktop\Rat 27 PawTracking Data\Scores 1\R0027Session20140516PawPointFiles.mat');      
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids]= TrajectoryCalculation(all3dPoints,score,5,6)

hold on
load('C:\Users\Administrator\Desktop\Rat 27 PawTracking Data\Scores 7\R0027Session20140516PawPointFiles.mat');
score = 7;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids]= TrajectoryCalculation(all3dPoints,score,5,6)