%input is the folder of the traingluated data that you want to analyze



function [allDiffrenceFrames,pelletTouchesAll,barrierBreaksAll] = plotGrossTrajectoryChanges(triDataFolder,scoreDataFolder,ScoresToReturn)  
close all
DaysPresent = [1,2,3,4,5,6,7,8,9,10,11,12,13,14];


 
        all_x_avg = [];
        all_x_var = [];
        
        all_y_avg = [];
        all_y_var = [];
        
        all_z_avg = [];
        all_z_var = [];



figProps.m =7; figProps.n = 3;
figProps.panelWidth = 5 * ones(1,3);
figProps.panelHeight = 2 * ones(1,figProps.m);
figProps.colSpacing = 1 * ones(1,2);
figProps.rowSpacing = 1.5 * ones(1,figProps.m-1);
figProps.width = 8.5 * 2.54;
figProps.height = 11 * 2.54;
figProps.topMargin = 1;
fullPanelWidth = sum(figProps.panelWidth) + sum(figProps.colSpacing);
ltMargin = (figProps.width - fullPanelWidth) / 2;
fullPanelHeight = sum(figProps.panelHeight) + sum(figProps.rowSpacing);
botMargin = (figProps.height - figProps.topMargin - fullPanelHeight);

figUnits = 'centimeters';



% 
% triDataFolder = uigetdir;
 triDataFiles = dir(fullfile(triDataFolder))
 triDataFiles(1:2) = [];
% 
% 
% scoreDataFolder = uigetdir
 scoreDataFiles = dir(fullfile(scoreDataFolder))
 scoreDataFiles(1:2) = [];
% 
% %Define the scores to return
% ScoresToReturn = 1; 


    for j = 1:length(triDataFiles)
        
        
       if mod(j,7) == 1
        current_h_fig = strcat('h_fig',num2str(j))
        current_h_axes =  strcat('h_axes',num2str(j))
        [current_h_fig, current_h_axes, figProps] = createFigPanels5(figProps, 'units', figUnits);
       end



        
        
        
        
        
        Day = DaysPresent (j);
        rowNum = mod(j,7);
        if rowNum == 0
            rowNum = 7;
        end
        
        h_axes = current_h_axes
        
        
        filenameTriData = triDataFiles(j).name
        filenameScoreData = scoreDataFiles(j).name
        
        
        load (filenameTriData)
        load (filenameScoreData)
        
        
        RatNum = cat(2,filenameScoreData(2),filenameScoreData(3));
        
      
       
       
       [x_avg,x_var,x_new,y_avg,y_var,y_new,z_avg,z_var,z_new,diffrenceFrames,pelletTouches,barrierBreaks] = plotGrossTrajectoryTriangulation(x,y,z,Scores,ScoresToReturn);
        allDiffrenceFrames {j} = {diffrenceFrames};
        pelletTouchesAll{j}  = {pelletTouches};
        barrierBreaksAll{j} = {barrierBreaks}; 
        [totalReaches, numSucess, numFail,SucessP, FailP]  =  ScoreInfo(Scores);
        plotAxisDisplacement(Day,rowNum,h_axes,x_avg,x_var,y_avg,y_var,z_avg,z_var,totalReaches, numSucess, numFail,SucessP,FailP,ScoresToReturn,RatNum);
        
        
        
        all_x_avg(:,j) = x_avg; 
        all_x_var(:,j) = x_var; 
        
        all_y_avg(:,j) = y_avg; 
        all_y_var(:,j) = y_var;
        
        all_z_avg(:,j) = z_avg; 
        all_z_var(:,j) = z_var; 
        
    end
% 
%     
%  
%  
%  
% 
% if ScoresToReturn == 1
%     reachMode = '-Success Reaches';
% elseif ScoresToReturn == 7
%     reachMode = '-Failures Reaches';
% end
% 
% filepathSaving = 'C:\Users\Administrator\Documents\GitHub\SkilledReaching\Manual Tracking Analysis\ConvertMarkedPointsToReal\PlotGrossTrajectory\ResultsPellet\';
% filename = strcat(filepathSaving,num2str(RatNum),'xyzData',reachMode);
%   
% figure(1)
% export_fig(filename,'-pdf')
% figure(2)
% export_fig(filename,'-pdf','-append')
% 
% 
%   
% 
% 
% 
% 
%     x_avg = nanmean(all_x_avg);
%     x_var = nanmean(all_x_var);
%  
%     y_avg = nanmean(all_y_avg);
%     y_var = nanmean(all_y_var);
%  
%     z_avg = nanmean(all_z_avg);
%     z_var = nanmean(all_z_var);
%   
%     
%     
% %     xFrames = (1:9);
% %     figure(3)
% %     subplot(3,1,1)
% %     shadedErrorBar(xFrames,x_avg,x_var,{'r','LineWidth',2})
% % 
% %   
% %     
% %     subplot(3,1,2)
% %     shadedErrorBar(xFrames,y_avg,y_var,{'b','LineWidth',2})
% %     
% %     
% %     subplot(3,1,3)
% %     shadedErrorBar(xFrames,z_avg,z_var,{'g','LineWidth',2})
% %     
%     
%     save(fullfile(filename),'all_x_avg','all_y_avg','all_z_avg','all_x_var','all_y_var','all_z_var')
    
    


end