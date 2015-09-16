load('C:\Users\Administrator\Desktop\Rat 27 PawTracking Data\Scores 1\R0027Session20140512PawPointFiles.mat');     
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids,euclidianDistDiff,  euclidianDistDiffMean, euclidianDistDiffStd,Velocity, Acceleration, Jerk]= TrajectoryCalculation(all3dPoints,score,'Day 3',1,2);

allEuclidianDistDiff{1} = euclidianDistDiff;
allEuclidianDistDiffMean{1} = euclidianDistDiffMean;
allEuclidianDistDiffStd{1} = euclidianDistDiffStd;
allVelocity{1} = Velocity;
allAcceleration{1} = Acceleration;
allJerk{1} = Jerk;

hold on
load('C:\Users\Administrator\Desktop\Rat 27 PawTracking Data\Scores 7\R0027Session20140512PawPointFiles.mat');
score = 7;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids,euclidianDistDiff,  euclidianDistDiffMean, euclidianDistDiffStd,Velocity, Acceleration, Jerk]= TrajectoryCalculation(all3dPoints,score,'Day 3',1,2);

allEuclidianDistDiff{2} = euclidianDistDiff;
allEuclidianDistDiffMean{2} = euclidianDistDiffMean;
allEuclidianDistDiffStd{2} = euclidianDistDiffStd;
allVelocity{2} = Velocity;
allAcceleration{2} = Acceleration;
allJerk{2} = Jerk;


load('C:\Users\Administrator\Desktop\Rat 27 PawTracking Data\Scores 1\R0027Session20140514PawPointFiles.mat');     
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids,euclidianDistDiff,  euclidianDistDiffMean, euclidianDistDiffStd,Velocity, Acceleration, Jerk]= TrajectoryCalculation(all3dPoints,score,'Day 5',3,4);

allEuclidianDistDiff{3} = euclidianDistDiff;
allEuclidianDistDiffMean{3} = euclidianDistDiffMean;
allEuclidianDistDiffStd{3} = euclidianDistDiffStd;
allVelocity{3} = Velocity;
allAcceleration{3} = Acceleration;
allJerk{3} = Jerk;

hold on
load('C:\Users\Administrator\Desktop\Rat 27 PawTracking Data\Scores 7\R0027Session20140514PawPointFiles.mat');
score = 7;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids,euclidianDistDiff,  euclidianDistDiffMean, euclidianDistDiffStd,Velocity, Acceleration, Jerk]= TrajectoryCalculation(all3dPoints,score,'Day 5',3,4);

allEuclidianDistDiff{4} = euclidianDistDiff;
allEuclidianDistDiffMean{4} = euclidianDistDiffMean;
allEuclidianDistDiffStd{4} = euclidianDistDiffStd;
allVelocity{4} = Velocity;
allAcceleration{4} = Acceleration;
allJerk{4} = Jerk;

load('C:\Users\Administrator\Desktop\Rat 27 PawTracking Data\Scores 1\R0027Session20140516PawPointFiles.mat');      
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids,euclidianDistDiff,  euclidianDistDiffMean, euclidianDistDiffStd,Velocity, Acceleration, Jerk]= TrajectoryCalculation(all3dPoints,score,'Day 7',5,6);

allEuclidianDistDiff{5} = euclidianDistDiff;
allEuclidianDistDiffMean{5} = euclidianDistDiffMean;
allEuclidianDistDiffStd{5} = euclidianDistDiffStd;
allVelocity{5} = Velocity;
allAcceleration{5} = Acceleration;
allJerk{5} = Jerk;

hold on
load('C:\Users\Administrator\Desktop\Rat 27 PawTracking Data\Scores 7\R0027Session20140516PawPointFiles.mat');
score = 7;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids,euclidianDistDiff,  euclidianDistDiffMean, euclidianDistDiffStd,Velocity, Acceleration, Jerk]= TrajectoryCalculation(all3dPoints,score,'Day 7',5,6);

allEuclidianDistDiff{6} = euclidianDistDiff;
allEuclidianDistDiffMean{6} = euclidianDistDiffMean;
allEuclidianDistDiffStd{6} = euclidianDistDiffStd;
allVelocity{6} = Velocity;
allAcceleration{6} = Acceleration;
allJerk{6} = Jerk;


figure(1);xlim([1,4])