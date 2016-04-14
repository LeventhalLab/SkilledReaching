%This script is for taking the gross trajectory point centroids and running
%it through the triungualation methodology

%Major Side is the mirror side 

%Input
%

%Output
%The filtered version of the x,y,z and paw centers

%
function  TrajectoryTriangulationBatch(workingDirectory,P1,P2,majorSide,pxToMm)
  

x= [];
y = [];
z = [];

    workingDirectoryParts = strsplit(workingDirectory,filesep);
    trialName = workingDirectoryParts{end};
    % load all the .mat trials created for each video, from each angle
    leftTrials = dir(fullfile(workingDirectory,'left','trials','*.mat'));
    centerTrials = dir(fullfile(workingDirectory,'center','trials','*.mat'));
    rightTrials = dir(fullfile(workingDirectory,'right','trials','*.mat'));


      if(numel(leftTrials) == numel(centerTrials) && numel(leftTrials) == numel(rightTrials))
        % load the pawCenter variables from the trial files
        allLeftPawCenters = loadPawCenters(leftTrials,fullfile(workingDirectory,'left','trials'));
        allCenterPawCenters = loadPawCenters(centerTrials,fullfile(workingDirectory,'center','trials'));
        allRightPawCenters = loadPawCenters(rightTrials,fullfile(workingDirectory,'right','trials'));
      end
      
     
       %Find the one Fundemental matrix
        %[points3d,reprojectedPoints,errors,pxToMm,F,P1,P2] = FindFundMatrix(r1,r2);
      

    for i =1:length(allLeftPawCenters)
        
        %Disp the current trial 
        disp(strcat('Trial: ', num2str(i)))
        
        %Pull the reach profile from center and left for one of the reaches
        left= allLeftPawCenters{i};
        center = allCenterPawCenters{i};
        right= allRightPawCenters{i};
        
        %Chose the side to analyze
        if majorSide == 1 %1 corresponds to left
            side = left;
        elseif majorSide == 2 %2 corresponds to right
            side = right;
        end
            
        
        
        %Checks to make sure the array contains some data
        s1 = side(:,1);
        s2 = sum(isnan(s1))
        
        c1 = center(:,1);
        c2 = sum(isnan(c1))
        
        
        if c2 < 650 && s2 < 650 && s2 ~= c2
            %triangulate the rach
            [xfilt, yfilt, zfilt] = triangulateOneReach(side, center, P1, P2,pxToMm) %Trianglate one reach function
            checkX = isempty ('xfilt');
        
        
            if checkX == 0 
                    %Push the 3d points into matrix
                    x{i} = xfilt;
                    y{i} = yfilt;
                    z{i} = zfilt;
            end
            
        else
            disp('Not enough trial data')
        end
    end
    
    checkX = exist ('x');
    
    if checkX == 1
        %Save the data 
        [pathstr,name,ext] = fileparts(workingDirectory);
        mkdir(fullfile(pwd,'_3DData'));
        save(fullfile(pwd,'_3DData',name),'x','y','z')
    end
end            
             
            
% Load and return the pawCenters variable from a trial file (one video).
function allPawCenters=loadPawCenters(trials,trialsPath)
    allPawCenters = cell(1,numel(trials));
    for i=1:numel(trials)
        load(fullfile(trialsPath,trials(i).name));
        allPawCenters{i} = pawCenters; % "pawCenters" variable is loaded via .mat file
    end
end

