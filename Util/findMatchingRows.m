function rowIdx = findMatchingRows(testRow, testMatrix)

numRows = size(testMatrix,1);
rowIdx = false(numRows,1);
for ii = 1 : size(testMatrix,1)
    
    if norm(testRow - testMatrix(ii,:)) == 0
        rowIdx(ii) = true;
    end
    
end