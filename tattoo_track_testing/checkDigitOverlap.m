function checkDigitOverlap(viewMask, F)

% viewMask{1} contains masked images in the mirror view
% viewMask{2} contains masked images in the direct view
% F is the fundamental matrix going from mirror view to center view

numObjects = size(viewMask{1},3);

for ii = 1 : numObjects
    mirror_ext = bwmorph(viewMask{1}(:,:,ii),'remove');
    [y,x] = find(mirror_ext);
    epiLines = epipolarLine(F, [x,y]);
    epi_pts = lineToBorderPoints(epiLines, [size(viewMask{2},1),size(viewMask{2},2)]);
    
end