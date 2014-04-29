function h=plot1dDistanceScores(allAlignedXyzDistPawCenters,plotFrames,superTitle)
    disp('Select the scoring CSV file...');
    %[scoreFile,scorePath] = uigetfile({'.csv'});
    scoreFile = 'Quant scoring R28 20140426.csv'; %REMOVE
    scorePath = 'C:\Users\Spike Sorter\Documents\MATLAB\SkilledReaching\videos\R0030_20140426a\'; %REMOVE
    scoreData = csvread(fullfile(scorePath,scoreFile));
    
    h = figure('Position', [0,0,1800,800]);
    suptitle(superTitle);

    startFrame = 2;
    plot1Avg = [];
    plot2Avg = [];
    for i=1:numel(allAlignedXyzDistPawCenters)
        alignedXyzDistPawCenters = allAlignedXyzDistPawCenters{i};
        distfilt = smoothn(alignedXyzDistPawCenters(startFrame:plotFrames),10,'robust');
        hold on;
        
        if(isa(alignedXyzDistPawCenters,'double'))
            if(ismember(scoreData(i,2),[1,2,3,4,7]))
                switch(scoreData(i,2))
                    case 1
                        subplot(1,2,1);
                        if(isempty(plot1Avg))
                            plot1Avg = distfilt;
                        else
                            plot1Avg = (distfilt+plot1Avg)/2;
                        end
                    case {2,3,4,7}
                        subplot(1,2,2);
                        if(isempty(plot2Avg))
                            plot2Avg = distfilt;
                        else
                            plot2Avg = (distfilt+plot2Avg)/2;
                        end
                end
                colormapline(startFrame:plotFrames,distfilt,[]);
            end
        end
    end
    
    for k=1:2
        h(k) = subplot(1,2,k);
        %view(h(k),[37.5,30]); % az,el
        %view(h(k),azel); % az,el
        xlabel(h(k),'frames');
        ylabel(h(k),'distance (mm)');
        %zlabel(h(k),'z');
        %legend on;
        grid(h(k));
        box(h(k));
        axis(h(k),[0 plotFrames 0 70]); % x y z
        
        switch k
            case 1
                title(h(k),'First Trial Success - 1');
                plot(startFrame:plotFrames,plot1Avg,'Color','magenta','Marker','o');
            case 2
                title(h(k),'Unsuccessful - {2,3,4,7}');
                plot(startFrame:plotFrames,plot2Avg,'Color','magenta','Marker','o');
        end
    end
end