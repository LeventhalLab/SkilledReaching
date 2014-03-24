function A = drawMatrixLine(A,p1,p2)
    x = p1(1):p2(1);
    y = round((x - p1(1)) * (p2(2) - p1(2)) / (p2(1) - p1(1)) + p1(2));
    A(sub2ind(size(A), y, x)) = 1;
end