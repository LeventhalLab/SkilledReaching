function [ paw_p,nonpaw_p ] = pawPixelProb( I,pawHist,nonPawHist,binEdges )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


bin_idx = zeros(size(I));
paw_p = zeros(size(I));
nonpaw_p = zeros(size(I));
for ii = 1 : size(I,3)
    cur_pawHist = pawHist(:,ii);
    cur_nonPawHist = nonPawHist(:,ii);
    bin_idx(:,:,ii) = discretize(I(:,:,ii),binEdges(:,ii));
    temp_bin_idx = bin_idx(:,:,ii);
    temp_bin_idx(isnan(bin_idx(:,:,ii))) = 1;
    
    temp_p = (cur_pawHist(temp_bin_idx) - cur_nonPawHist(temp_bin_idx)) ./ cur_pawHist(temp_bin_idx);
    temp_p(isnan(bin_idx(:,:,ii))) = 0;
    paw_p(:,:,ii) = temp_p;
    
    temp_non_paw_p = (cur_nonPawHist(temp_bin_idx) - cur_pawHist(temp_bin_idx)) ./ cur_nonPawHist(temp_bin_idx);
    temp_non_paw_p(isnan(bin_idx(:,:,ii))) = 0;
    nonpaw_p(:,:,ii) = temp_non_paw_p;
end

end