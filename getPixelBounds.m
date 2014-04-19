% >> pixelBounds = getPixelBounds('r.avi', {'left','center','right'});
function [pixelBounds]=getPixelBounds(videoFile,boundNames)
    video = VideoReader(videoFile);
    pixelBounds = {};
    im = read(video,1);

    for i=1:size(boundNames,2)
       h_im = imshow(im);
       mask = createMask(imrect,h_im);
       poly = mask2poly(mask);
       pixelBounds.(boundNames{i}) = [poly(1,:),poly(size(poly,1),:)];
    end
    close;
end