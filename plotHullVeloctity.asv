function plotHullVeloctity()
    folderPaths = {'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140424a\left'...
        'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140428a\left'...
        'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140502a\left'...
        };
    scorePaths = {'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140424a'...
        'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140428a'...
        'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140502a'...
        };

    for f=1:numel(folderPaths)
        scoreLookup = dir(fullfile(scorePaths{f},'*.csv'));
        scoreData = scoreVideoData(fullfile(scorePaths{f},scoreLookup(1).name),folderPaths{f});
        if(f==1)
            figure('Position',[300 300 1000 600]);
        end
        % open one video to get x-value
        matFiles = dir(fullfile(folderPaths{f},'trials','*.mat'));
        videos = dir(fullfile(folderPaths{f},'*.avi'));
        video = VideoReader(fullfile(folderPaths{f},videos(10).name));
        im = read(video,100);
        disp('Select front-outside of box, where paw extends out of...');
        h_im = figure;
        imshow(im);
        [x,y] = ginput;
        close;

        for i=1:numel(matFiles)
            trialScoreIndex = [scoreData{:,1}]==1;
            if(scoreData{trialScoreIndex,2} == 1)
                load(fullfile(folderPaths{f},'trials',matFiles(i).name));
                xVals = NaN(size(pawHulls,2),1);
                indexSwitch = 0;
                indexCount = 1;
                for j=1:size(pawHulls,2) %loop through all frames
                    if(size(pawHulls{j},1)>2) %not NaNs
                        tempVal = min(pawHulls{j}(:,1)); %change to max for right view!
                        if(tempVal <= x) %make sure it crosses boundary, change to >= for right view!
                            xVals(indexCount) = x-tempVal; %distance from front, change to + for right view!
                            indexSwitch = 1;
                        end
                    end
                    if(indexSwitch==1) %used for aligning plot
                        indexCount = indexCount + 1;
                    end
                end
                hold on;
                plot(diff(smoothn(xVals(1:50),4,'robust')),'Color',getColor(f));
                xValsSmooth = smoothn(xVals,4,'robust');
                if(indexCount==1)
                    xValsAvg = xValsSmooth;
                else
                    xValsAvg = mean([xVals xValsSmooth],2);
                end
            end
        end
        %plot(diff(smoothn(xValsAvg(1:50),4,'robust')),'Color',getColor(f));
    end
end