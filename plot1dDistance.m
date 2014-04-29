function h=plot1dDistance(allAlignedXyzDistPawCenters,plotFrames)
    h = figure;
    xlabel('x');
    ylabel('y');
    zlabel('z');
    grid on; 
    box on;
    startFrame = 10;
    for i=1:numel(allAlignedXyzDistPawCenters)
        alignedXyzDistPawCenters = allAlignedXyzDistPawCenters{i};
        % [] (empty) means that data wasn't ran for a video, this can be used to filter bad data
        if(isa(alignedXyzDistPawCenters,'double'))
            hold on;
            %colormapline(1:numel(alignedXyzDistPawCenters),smoothn((alignedXyzDistPawCenters),10,'robust'),[]);
            colormapline(startFrame:plotFrames,smoothn((alignedXyzDistPawCenters(startFrame:plotFrames)),10,'robust'),[]);
        end
    end
end