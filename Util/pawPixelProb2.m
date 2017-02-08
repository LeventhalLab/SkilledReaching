function [ paw_p,nonpaw_p ] = pawPixelProb2( I,pawHist,nonPawHist,binEdges )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


bin_idx = zeros(size(I,1),size(I,2),2);
smoothedPawHist = imboxfilt(pawHist,3);
smoothedNonPawHist = imboxfilt(nonPawHist,3);
% paw_p = zeros(size(I));
% nonpaw_p = zeros(size(I));
for ii = 1 : 2%size(I,3)
%     cur_pawHist = pawHist(:,ii);
%     cur_nonPawHist = nonPawHist(:,ii);
%     bin_idx(:,:,ii) = discretize(I(:,:,ii),binEdges(:,ii));
%     smoothedPawHist(:,:,ii) = imboxfilt(pawHist(:,:,ii));
    temp_bin_idx = discretize(I(:,:,ii),binEdges(:,ii));
    temp_bin_idx(isnan(bin_idx(:,:,ii))) = 1;
    bin_idx(:,:,ii) = temp_bin_idx;
end

paw_p = zeros(size(I,1),size(I,2));
nonpaw_p = zeros(size(I,1),size(I,2));


for iy = 1 : size(I,1)
    for ix = 1 : size(I,2)
%         paw_p(iy,ix) = (pawHist(bin_idx(iy,ix,1),bin_idx(iy,ix,2)) - nonPawHist(bin_idx(iy,ix,1),bin_idx(iy,ix,2))) ./ pawHist(bin_idx(iy,ix,1),bin_idx(iy,ix,2));
        
        paw_p(iy,ix) = (smoothedPawHist(bin_idx(iy,ix,1),bin_idx(iy,ix,2))) / max(smoothedPawHist(:));
        % paw_p(:,:,ii) = temp_p;

%         nonpaw_p(iy,ix) = (nonPawHist(bin_idx(iy,ix,1),bin_idx(iy,ix,2)) - pawHist(bin_idx(iy,ix,1),bin_idx(iy,ix,2))) ./ nonPawHist(bin_idx(iy,ix,1),bin_idx(iy,ix,2));
        nonpaw_p(iy,ix) = (smoothedNonPawHist(bin_idx(iy,ix,1),bin_idx(iy,ix,2))) / max(smoothedNonPawHist(:));
        
        % nonpaw_p(:,:,ii) = temp_non_paw_p;
    end
end

paw_p(isnan(bin_idx(:,:,ii))) = 0;
nonpaw_p(isnan(bin_idx(:,:,ii))) = 0;