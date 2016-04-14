function shiftAmount = detectCircShift(m1,m2,dim)

shiftAmount = [];

if size(m1) ~= size(m2); return; end

for ii = 1 : size(m1,dim) - 1
    
    temp = circshift(m1,ii, dim);
    if temp == m2
        shiftAmount = ii;
        break;
    end
end