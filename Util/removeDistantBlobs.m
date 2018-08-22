function newMask = removeDistantBlobs(refBlob, oldMask, maxSeparation)

otherBlobs = oldMask & ~refBlob;

L = bwlabel(otherBlobs);

newMask = oldMask;
for ii = 1 : max(L(:))
    
    d = distBetweenBlobs(refBlob, L==ii);
    
    if d > maxSeparation
        newMask = newMask & ~(L==ii);
    end
end

