function idx = detectZeroCrossings(x)

zerotol = 1e-10;

test_sig = x .* circshift(x,1);

idx = find(test_sig < 0);   % find points where the signal changes sign

if diff(idx) == 1   % if identify adjacent points, this means it's really a tangent point
    idx = idx(1);
end

zero_idx = find(abs(x) < zerotol);

% if there are two zero points, that means there are two tangent points
% along this line, and we'll just pick the first one since both points will
% define the same tangent line.


% WORKING HERE - NEED TO FIGURE OUT HOW TO MAKE SURE THAT ONLY TANGENT
% POINTS ARE KEPT - MAKE SURE THAT POINTS ON EITHER SIDE OF THE POINT AT
% WHICH LINEVALUE = 0 HAVE THE SAME SIGN
for ii = 1 : length(zero_idx)
    % check that sign of linevalue on either side of this point is the same
    % (or equal to zero)
    
    
end
if length(zero_idx) > 1
    zero_idx = zero_idx(1);
end

idx = [zero_idx;idx];
idx = unique(idx);
idx = sort(idx);