[video,im]=readVideo(117);
%figure;
%imshow(im);
[pawCenter,pawHull]=pawData(im,hsvBounds);
im2 = insertShape(im,'FilledCircle',[pawHull repmat(2,size(pawHull,1),1)],'Color','red');
im2 = insertShape(im2,'FilledCircle',[pawCenter 2]);
figure;
imshow(im2);