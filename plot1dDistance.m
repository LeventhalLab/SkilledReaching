function h=plot1dDistance(allAlignedXyzDistPawCenters)
    h = figure;
    xlabel('x');
    ylabel('y');
    zlabel('z');
    grid on; 
    box on;
    
    for i=1:numel(allAlignedXyzDistPawCenters)
        alignedXyzDistPawCenters = allAlignedXyzDistPawCenters{i};
        % [] (empty) means that data wasn't ran for a video, this can be used to filter bad data
        if(~isempty(alignedXyzDistPawCenters))
            hold on;
            colormapline(1:numel(alignedXyzDistPawCenters),smoothn((alignedXyzDistPawCenters),10,'robust'),[]);
        end
    end
end