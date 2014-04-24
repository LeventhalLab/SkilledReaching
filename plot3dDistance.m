function h=plot3dDistance(allAlignedXyzPawCenters)
    h = figure;
    view(37.5,30);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    grid on; 
    box on;
    
    for i=1:numel(allAlignedXyzPawCenters)
        alignedXyzPawCenters = allAlignedXyzPawCenters{i};
        if(~isempty(alignedXyzPawCenters))
            xfilt = medfilt1(alignedXyzPawCenters(:,1),4);
            yfilt = medfilt1(alignedXyzPawCenters(:,2),4);
            zfilt = medfilt1(alignedXyzPawCenters(:,3),4);
            hold on;
            colormapline(smoothn(xfilt,3,'robust'),smoothn(yfilt,3,'robust'),smoothn(zfilt,3,'robust'));
        end
    end
end