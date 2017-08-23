function tf = doesLineIntersectBlob( testLine, blobMask )

[y,x] = find(blobMask);

testVals = testLine(1) * x + testLine(2) * y + testLine(3);

tf = any(abs(testVals) < 1);