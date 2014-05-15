function plotHullVelocity()
    % 0430-crappy performance (no food restrict), 0501-files named incorrectly
% %     folderPaths = {...
% %         '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029\R0029-rawdata\R0029_20140505a\left',...
% %         '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029\R0029-rawdata\R0029_20140506a\left',...
% %         '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029\R0029-rawdata\R0029_20140507a\left',...
% %         '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029\R0029-rawdata\R0029_20140508a\left',...
% %         '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029\R0029-rawdata\R0029_20140509c\left',...
% %         '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029\R0029-rawdata\R0029_20140512a\left',...
% %         };
% %     scorePaths = {...
% %         '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029\R0029-rawdata\R0029_20140505a',...
% %         '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029\R0029-rawdata\R0029_20140506a',...
% %         '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029\R0029-rawdata\R0029_20140507a',...
% %         '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029\R0029-rawdata\R0029_20140508a',...
% %         '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029\R0029-rawdata\R0029_20140509c',...
% %         '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0029\R0029-rawdata\R0029_20140512a',...
% %         };


    folderPaths = {...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140424a\left',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140425a\left',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140426a\left',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140427a\left',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140428a\left',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140429a\left',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140502a\left',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140505a\left',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140506a\left',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140507a\left',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140508a\left',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140509a\left',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140512a\left',...
        };
    scorePaths = {...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140424a',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140425a',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140426a',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140427a',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140428a',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140429a',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140502a',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140505a',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140506a',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140507a',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140508a',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140509a',...
        '\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140512a',...
        };

    eValPeakIndexAll = NaN(100,numel(folderPaths));
    for f=1:numel(folderPaths)
        if(f>3)
            lineColor = 'magenta';
        else
            lineColor = 'blue';
        end
        disp(['Scoring: ',scorePaths{f}]);
        scoreLookup = dir(fullfile(scorePaths{f},'*.csv'));
        scoreData = scoreVideoData(fullfile(scorePaths{f},scoreLookup(1).name),folderPaths{f});
        trialData = getTrialData(fullfile(folderPaths{f},'trials'));
        if(f==1)
            hevals = figure('Position',[100 100 1000 600]);
% %             hDistance = figure('Position',[100 100 1000 600]);
% %             hVelocity = figure('Position',[150 100 1000 600]);
% %             hAvgDistance = figure('Position',[200 100 1000 600]);
% %             hAvgVelocity = figure('Position',[250 100 1000 600]);
        end
        % open one video to get x-value
        videos = dir(fullfile(folderPaths{f},'*.avi'));
        video = VideoReader(fullfile(folderPaths{f},videos(10).name));
        im = read(video,100);
        disp('Select front-outside of box, where paw extends out of...');
        h_im = figure;
        imshow(im);
        [x,y] = ginput;
        close;
        xValsAll = NaN(size(trialData,1),450); %for averaging
        for i=1:size(trialData,1)
            indexSwitch = 0;
            indexCount = 1;
            eValPeak = 0;
            if(scoreData{i,2} == 1) %if success
                load(trialData{i,2});
                xVals = NaN(size(pawHulls,2),1);
                eVals = NaN(size(pawHulls,2),1);
                for j=1:size(pawHulls,2) %loop through all frames
%                     disp(['j: ',num2str(j)]);
                    if(size(pawHulls{j},1)>2) %not NaNs
                        tempVal = min(pawHulls{j}(:,1)); %change to max for right view!
                        if(tempVal <= x) %make sure it crosses boundary, change to >= for right view!
                            xVals(indexCount) = x-tempVal; %distance from front, change to + for right view!
                            indexSwitch = 1;
                            boundaryHullIndexes = pawHulls{j}(:,1)<=x;
                            bbox = boundingBox(pawHulls{j}(boundaryHullIndexes,:));
                            width = bbox(2)-bbox(1);
                            height = bbox(4)-bbox(3);
                            eVal = width/height;
                            eVals(indexCount) = eVal;
                        end
                    end
                    if(indexSwitch==1) %used for aligning plot
                        indexCount = indexCount + 1;
                    end
                end
                hold on;
                figure(hevals);
                plot(smoothn(eVals(1:50),1),'Color',getColor(f,numel(folderPaths)));
% %                 figure(hDistance);
% %                 plot(smoothn(xVals(1:50),1,'robust'),'Color',getColor(f,numel(folderPaths)));
% %                 hold on;
% %                 figure(hVelocity);
% %                 plot(diff(smoothn(xVals(1:50),1,'robust')),'Color',getColor(f,numel(folderPaths)));
% %                 xValsSmooth = smoothn(xVals,4,'robust');
% %                 if(indexCount==1)
% %                     xValsAvg = xValsSmooth;
% %                 else
% %                     xValsAvg = mean([xVals xValsSmooth],2);
% %                 end
% %                 xValsAll(i,:) = xValsSmooth';\

                [maxValue,maxIndex] = max(eVals(1:50));
                eValPeakIndexAll(i,f) = maxIndex;
            end
        end
% %         hold on;
% %         figure(hAvgDistance);
% %         plotData = smoothn(xValsAvg(1:50),4,'robust');
% %         plot(plotData,'Color',getColor(f,numel(folderPaths)));
% %         stdData = zeros(50,1);
% %         for k=1:numel(stdData)
% %             thisStd = std(xValsAll(~isnan(xValsAll(:,k))));
% %             stdData(k) = plotData(k)+thisStd;
% %         end
% %         hold on;
% %         plot(stdData,'Color',getColor(f,numel(folderPaths)),'LineStyle','--');
% %         figure(hAvgVelocity);
% %         hold on;
% %         plot(diff(plotData),'Color',getColor(f,numel(folderPaths)));
    end
    y = NaN(1,numel(folderPaths));
    m = NaN(1,numel(folderPaths));
    e = NaN(1,numel(folderPaths));
    for i=1:numel(folderPaths)
        nonNanIndexes = ~isnan(eValPeakIndexAll(:,i));
        y(1,i) = mean(eValPeakIndexAll(nonNanIndexes,i));
        m(1,i) = median(eValPeakIndexAll(nonNanIndexes,i));
        e(1,i) = std(eValPeakIndexAll(nonNanIndexes,i));
    end
    figure;
    %plot(eValPeaks);
    %set(gca,'xtick',1:numel(folderPaths));
    errorbar(y,e);
    hold on;
    plot(m,'Color','r');
end