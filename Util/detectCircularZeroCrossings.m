function [idx, isLocalExtremum] = detectCircularZeroCrossings(x)

zerotol = 1e-10;

x_length = length(x);

isLocalExtremum = false(x_length, 1);
idx = false(x_length, 1);
x(abs(x)<zerotol) = 0;
if all(~x)    % all zeros
    return;
end

% make sure x is a column vector
if x_length == size(x,2)
    x = x';
end
z = [x;x];    % repeat x once so if the first point and last point have a zero crossing, it will be identified

test_sig = z .* circshift(z,-1);

idx_zeroCross = find(test_sig < 0);   % find points where the signal changes sign
if length(idx_zeroCross) == size(idx_zeroCross,2)
    idx_zeroCross = idx_zeroCross';
end
idx_zeroCross = idx_zeroCross(idx_zeroCross <= x_length);
idx_zeros = find(z==0);
idx_nonzero = find(z~=0);

% condense consecutive indices where the function is equal to zero
idx_zeros_diff = diff(idx_zeros);
zeros_separate_start_idx = idx_zeros(find(idx_zeros_diff > 1)+1);
zeros_separate_end_idx = zeros(length(zeros_separate_start_idx),1);
for ii = 1 : length(zeros_separate_end_idx)
    if ~isempty(idx_nonzero(idx_nonzero > zeros_separate_start_idx(ii)))
        zeros_separate_end_idx(ii) = ...
            min(idx_nonzero(idx_nonzero > zeros_separate_start_idx(ii)));
    else
        zeros_separate_end_idx(ii) = 1;
    end
end
zeros_separate_end_idx = zeros_separate_end_idx - 1;
zeros_separate_start_idx(zeros_separate_start_idx > length(x)) = ...
    zeros_separate_start_idx(zeros_separate_start_idx > length(x)) - length(x);
zeros_separate_end_idx(zeros_separate_end_idx > length(x)) = ...
    zeros_separate_end_idx(zeros_separate_end_idx > length(x)) - length(x);
zeros_separate_start_idx = unique(zeros_separate_start_idx(zeros_separate_start_idx > 0));
zeros_separate_end_idx = zeros_separate_end_idx(1:length(zeros_separate_start_idx));

% figure out if zero crossings that don't directly hit zero are local
% extrema or just zero crossings
for ii = 1 : length(idx_zeroCross)
    if idx_zeroCross(ii) == x_length
        temp_idx = [1,x_length];
    else
        temp_idx = idx_zeroCross(ii):idx_zeroCross(ii)+1;
    end
    if ii < length(idx_zeroCross)
        if idx_zeroCross(ii + 1) - idx_zeroCross(ii) == 1
            isLocalExtremum(temp_idx) = true;
        end
    elseif (idx_zeroCross(1) == 1) && ...
           (idx_zeroCross(end) == x_length)
               isLocalExtremum(temp_idx) = true;
    end
    idx(temp_idx) = true;
end
    
% now figure out if points where x == 0 are zero crossings or local
% extrema
for ii = 1 : length(zeros_separate_start_idx)
    if zeros_separate_start_idx(ii) == 1
        test_value = x(end) * x(zeros_separate_end_idx(ii) + 1);
    elseif zeros_separate_end_idx(ii) == length(x)
        test_value = x(end) * x(zeros_separate_start_idx(ii) - 1);
    else
        test_value = x(zeros_separate_start_idx(ii) - 1) * ...
            x(zeros_separate_end_idx(ii) + 1);
    end
    if zeros_separate_start_idx(ii) <= zeros_separate_end_idx(ii)
        temp_idx = zeros_separate_start_idx(ii) : zeros_separate_end_idx(ii);
    else
        temp_idx = [1 : zeros_separate_end_idx(ii), ...
            zeros_separate_start_idx(ii) : length(x)];
    end
    if test_value > 0
        isLocalExtremum(temp_idx) = true;
    end
    
    idx(temp_idx) = true;
    
end

