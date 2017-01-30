function [ prob_map ] = hist_backproject( I, tbins, thist )
%UNTITLED Summary of this function goes here
% INPUTS:

% OUTPUTS:

h = size(I,1); w = size(I,2);
% if ndims(I) == 2
%     numFeatures = 1;
% else
%     numFeatures = size(I,3);
% end

prob_map = zeros(h,w);

for i_y = 1 : h
    for i_x = 1 : 2
        cur_pix = I(i_y,i_x,:);
        prob_map(i_y,i_x) = getProb(cur_pix, tbins, thist);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = getProb(cur_pix, tbins, thist)

bin_idx = zeros(1,length(cur_pix));
for ii = 1 : length(cur_pix)
    test_list = tbins - cur_pix(ii);
    temp_bin_idx = find(test_list > 0, 1, 'first');
    if isempty(bin_idx)
        temp_bin_idx = size(tbins,1);
    end
    bin_idx(ii) = temp_bin_idx;
    
end

p = thist(bin_idx);

end