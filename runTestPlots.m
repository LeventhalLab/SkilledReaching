function runTestPlots() 

folderPath = {'\\141.214.45.212\RecordingsLeventhal1\Skilled Reaching Project\R0030\R0030-rawdata\R0030_20140520a'};

    h = figure('Position', [0,0,1800,800]);
    

    titles={'R30 0520'};
    for i = 1:1
        subplot(1,1,i);
        title(titles{i});
        test_plot1dDistanceScores(folderPath{i},450);
        grid on;
        hold on;
    end
    
end
