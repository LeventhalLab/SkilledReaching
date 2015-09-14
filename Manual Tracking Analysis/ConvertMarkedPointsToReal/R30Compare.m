load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0030\20140423\R0030Session20140423PawPointFiles.mat')
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids]= TrajectoryCalculation(all3dPoints,score,1,2)

% hold on
% score = 7;
% [all3dPoints] = RatDattoReal3Dpoints(RatData,score);
% [allCentroids]= TrajectoryCalculation(all3dPoints,score,1,2)
     
load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0030\20140424\R0030Session20140424PawPointFiles.mat');
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids]= TrajectoryCalculation(all3dPoints,score,3,4)

% hold on
% score = 7;
% [all3dPoints] = RatDattoReal3Dpoints(RatData,score);
% [allCentroids]= TrajectoryCalculation(all3dPoints,score,3,4)

load('C:\Users\Administrator\Documents\Paw_Point_Marking_Data\R0030\20140425\R0030Session20140425PawPointFiles.mat')
score = 1;
[all3dPoints] = RatDattoReal3Dpoints(RatData,score);
[allCentroids]= TrajectoryCalculation(all3dPoints,score,5,6)

% hold on
% score = 7;
% [all3dPoints] = RatDattoReal3Dpoints(RatData,score);
% [allCentroids]= TrajectoryCalculation(all3dPoints,score,5,6)