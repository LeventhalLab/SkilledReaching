function testHsvBounds(hsvBounds,frame)
    [f,p] = uigetfile('*.avi');
    video = VideoReader([p,f]);
    im = read(video,frame);
    [pawCenter,pawHull] = pawData(im,hsvBounds);
    if(~isnan(pawHull(1)))
        im = insertShape(im,'FilledCircle',[pawHull repmat(3,size(pawHull,1),1)],'Color','red');
    end
    figure;
    imshow(im);
end