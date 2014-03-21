function animate(video, saveGifAs)
    video = VideoReader(video);

    for i=1:video.NumberOfFrames
        im = read(video,i);
        [imind,cm] = rgb2ind(im,256);
        if i == 1;
          imwrite(imind,cm,saveGifAs,'gif', 'Loopcount',inf);
        else
          imwrite(imind,cm,saveGifAs,'gif','WriteMode','append');
        end
    end
end