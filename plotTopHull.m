% Matt Gaidica, mgaidica@med.umich.edu
% Leventhal Lab, University of Michigan
% --- release: beta ---

% analyzes the top-most hull point during the reach to see if the paw height changes over time
function h=plotTopHull()
    folderPaths = {'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140424a\left',...
        'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140425a\left',...
        'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140426a\left',...
        'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140427a\left',...
        'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140428a\left',...
        'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140429a\left',...
        'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140501d\left',...
        'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140502a\left'
%         'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140505a',...
        };
    h=figure;
    hue = .2;
    saturation = .4;
    value = .9;
    for f=1:numel(folderPaths)
        workingDirectory = folderPaths{f};
        matFiles = dir(fullfile(workingDirectory,'trials','*.mat'));
        videos = dir(fullfile(workingDirectory,'*.avi'));
        video = VideoReader(fullfile(workingDirectory,videos(10).name));
        im = read(video,100);
        figure;
        imshow(im);
        disp('Identify pellet, press ENTER when done...');
        [x,y] = ginput;
        close;
        for i=1:numel(matFiles)
            load(fullfile(workingDirectory,'trials',matFiles(i).name));
            if(i==1)
                yValsRunningMax = NaN(size(pawHulls,2),1);
            end
            yVals = NaN(size(pawHulls,2),1);
            for j=1:size(pawHulls,2)
                % valid pawHull
                if(size(pawHulls{j},1)>2)
                    yVals(j) = y-min(pawHulls{j}(:,2));
                    if(yVals(j) > yValsRunningMax(j) || isnan(yValsRunningMax(j)))
                        yValsRunningMax(j) = yVals(j);
                    end
                end
            end
    % %         hold on;
    % %         plot(smoothn(yVals,4,'robust'));
        end
        hold on;
        plot(smoothn(yValsRunningMax,4,'robust'),'Color',[hue,saturation,value]);
        hue = hue+.06;
        saturation = saturation+.06;
        value = value-.06;
    end
end