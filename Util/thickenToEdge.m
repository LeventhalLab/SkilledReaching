function thickenedBlob = thickenToEdge(innerBlob, outerBlob)

thickenSize = 1;

overlapCheck = innerBlob & ~outerBlob;

if any(overlapCheck(:))
    thickenedBlob = innerBlob;
    return;
end

while ~any(overlapCheck(:))
    
    thickenedBlob = bwmorph(innerBlob, 'thicken', thickenSize);
    
    overlapCheck = thickenedBlob & ~outerBlob;
    
    thickenSize = thickenSize + 1;
    
end