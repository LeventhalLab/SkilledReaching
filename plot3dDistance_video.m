% Matt Gaidica, mgaidica@med.umich.edu
% Leventhal Lab, University of Michigan
% --- release: beta ---

function h=plot3dDistance_video(allAlignedXyzPawCenters,plotFrames,saveFile)
    doVideo = true;
    im_legend = imread('/Users/mattgaidica/Dropbox/Presentations/2017 NGP Symposium/assets/SkilledReaching/ReachStartEnd.jpg');
    
    h = figure('position',[0 0 900 900]);
    view(30,0);
%     view(37.5,30);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    grid on; 
    box on;
    set(gcf,'color','w');
    xlim([-5 25]); ylim([-60 10]); zlim([-20 15]);
    startFrame = 10;
    
    frMult = 5;
    all_az = linspace(30,50,numel(allAlignedXyzPawCenters)*frMult);
    all_el = linspace(0,40,numel(allAlignedXyzPawCenters)*frMult);
    all_axisColors = linspace(0.25,1,numel(allAlignedXyzPawCenters)*frMult);
    all_gridColors = linspace(.5,1,numel(allAlignedXyzPawCenters)*frMult);
    iFrame = 1;
    
    if doVideo
        newVideo = VideoWriter(saveFile,'Motion JPEG AVI');
        newVideo.Quality = 100;
        newVideo.FrameRate = 30;
        open(newVideo);
    end
    
    for ii=1:numel(allAlignedXyzPawCenters)
        alignedXyzPawCenters = allAlignedXyzPawCenters{ii};
        if(size(alignedXyzPawCenters,1) > 5)
            xfilt = medfilt1(alignedXyzPawCenters(startFrame:plotFrames,1),4);
            yfilt = medfilt1(alignedXyzPawCenters(startFrame:plotFrames,2),4);
            zfilt = medfilt1(alignedXyzPawCenters(startFrame:plotFrames,3),4);
            hold on;
            colormapline(smoothn(xfilt,3,'robust'),smoothn(yfilt,3,'robust'),smoothn(zfilt,3,'robust'),jet(128));
            drawnow;
            xlim([-5 25]); ylim([-60 10]); zlim([-20 15]);
        end
        
        for jj = 1:frMult
            im = frame2im(getframe(gcf));
            im = placeLegend(im,im_legend);
            if doVideo
                writeVideo(newVideo,im);
            end

            view(all_az(iFrame),all_el(iFrame));
            set(gca,'xcolor',[all_axisColors(iFrame) all_axisColors(iFrame) all_axisColors(iFrame)]);
            set(gca,'ycolor',[all_axisColors(iFrame) all_axisColors(iFrame) all_axisColors(iFrame)]);
            set(gca,'zcolor',[all_axisColors(iFrame) all_axisColors(iFrame) all_axisColors(iFrame)]);
            set(gca,'gridColor',[all_gridColors(iFrame) all_gridColors(iFrame) all_gridColors(iFrame)]);
            iFrame = iFrame + 1;
        end
    end
    
    all_az = linspace(50,120,200);
    all_el = linspace(40,10,200);
    for ii = 1:numel(all_az)
        im = frame2im(getframe(gcf));
        im = placeLegend(im,im_legend);
        if doVideo
            writeVideo(newVideo,im);
        end
        view(all_az(ii),all_el(ii));
        drawnow;
    end
    if doVideo
        close(newVideo);
    end
end

function im = placeLegend(im,im_legend)
    im_w = size(im,2);
    im_legend_w = size(im_legend,2);
    diff_hw = round((im_w - im_legend_w) / 2);
    im(end-size(im_legend,1)+1:end,diff_hw:diff_hw+size(im_legend,2)-1,:) = im_legend;
end