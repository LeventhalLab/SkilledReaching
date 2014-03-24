function [mask] = createMask(coords, sourceImage)
    % could also do it without image tools: http://stackoverflow.com/questions/14585965/drawing-a-line-of-ones-on-a-matrix
    im = sourceImage;
    im(im>0) = 0; % black image
    coords = reshape(coords',1,numel(coords)); % create vector
    im = insertShape(im,'Line',coords,'Color','w'); % white line
    im = im2bw(im); % to single frame
    im = bwdist(im) < 60; % dilate
    mask = logical(im);
end