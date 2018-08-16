function dilatedBlob = dilateToEdge(innerBlob, outerBlob)

dilateSize = 1;

overlapCheck = innerBlob & ~outerBlob;

if any(overlapCheck(:))
    dilatedBlob = innerBlob;
    return;
end

while ~any(overlapCheck(:))
    
    SE = strel('disk', dilateSize);
    dilatedBlob = imdilate(innerBlob, SE);
    
    overlapCheck = dilatedBlob & ~outerBlob;
    
    dilateSize = dilateSize + 1;
    
end