function runPlot()
    folderPaths = {'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140424a',...
        'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140425a',...
        'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140426a',...
        'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140427a',...
        'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140428a',...
        'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140429a',...
        'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140501d',...
        'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140502a',...
%         'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140505a',...
        };
    
    hue = (150/360):((170/360)/(numel(folderPaths)-1)):(320/360);
    saturation = .2:(.70/(numel(folderPaths)-1)):.9;
    value = fliplr(saturation);
    plotFrames = 150;
    hs = zeros(numel(folderPaths),1);
    
    % 1d
% %     superTitle = 'Distance vs. Frames';
% %     for i=1:numel(folderPaths)
% %         hs(i) = plot1dDistanceScores(folderPaths{i},plotFrames,superTitle,hsv2rgb([hue(i),saturation(i),value(i)]),0);
% %         superTitle = '';
% %     end
% %     legend(hs,folderPaths);
% %     
% %     superTitle = 'Velocity vs. Frames';
% %     for i=1:numel(folderPaths)
% %         hs(i) = plot1dDistanceScores(folderPaths{i},plotFrames,superTitle,hsv2rgb([hue(i),saturation(i),value(i)]),1);
% %         superTitle = '';
% %     end
% %     legend(hs,folderPaths);
    
% %     superTitle = 'Acceleration vs. Frames';
% %     for i=1:numel(folderPaths)
% %         hs(i) = plot1dDistanceScores(folderPaths{i},plotFrames,superTitle,hsv2rgb([hue(i),saturation(i),value(i)]),2);
% %         superTitle = '';
% %     end
% %     legend(hs,folderPaths);
    
    % 3d
    superTitle = '3D Distance';
    for i=1:numel(folderPaths)
        % [az,el] - side:[90,0] front:[180,0] top:[180,90]
        hs(i) = plot3dDistanceScores(folderPaths{i},plotFrames,superTitle,[90,0],hsv2rgb([hue(i),saturation(i),value(i)]));
        superTitle = '';
    end
    %legend(hs,folderPaths);
end