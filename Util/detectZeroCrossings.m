function idx = detectZeroCrossings(x)

test_sig = x .* circshift(x,1);

idx = find(test_sig < 0);

if diff(idx) == 1   % if identify adjacent points, this means it's really a tangent point
    idx = idx(1);
end

zero_idx = find(x == 0);

idx = [zero_idx;idx];
idx = sort(idx);