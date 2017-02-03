function [ PCAcoeff, PCA_paw_hist, PCA_nonpaw_hist, PCAbinEdges ] = pawPCAregions( image_ud, pawMask, varargin )
% function [ PCAcoeff, PCAmean, PCAmean_nonPaw, PCAcovar ] = pawPCAregions( image_ud, pawMask, varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

imFiltWidth = 5;
pawDilation = 30;
numHistBins = 25;

for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'imfiltwidth'
            imFiltWidth = varargin{iarg + 1};
    end
end


PCAcoeff = zeros(3,3,2);
% PCAmean = zeros(2,3);
% PCAcovar = zeros(3,3,2);
% PCAmean_nonPaw = zeros(2,3);
PCA_paw_hist = zeros(numHistBins,3,2);
PCA_nonpaw_hist = zeros(numHistBins,3,2);
PCAbinEdges = zeros(numHistBins+1,3,2);    % number of bins x 2 views x 3 principal components

filt_im = imboxfilt(image_ud,imFiltWidth);
bbox = zeros(2,4);
for iView = 1 : 2
    temp_pawMask = bwconvhull(pawMask{iView},'union');
    temp = regionprops(imdilate(temp_pawMask,strel('disk',pawDilation)),'BoundingBox');
    bbox(iView,:) = round(temp.BoundingBox);
    
    localPawMask = pawMask{iView}(bbox(iView,2):bbox(iView,2)+bbox(iView,4),...
                                  bbox(iView,1):bbox(iView,1)+bbox(iView,3));
    
    paw_img = filt_im(bbox(iView,2):bbox(iView,2)+bbox(iView,4),...
                      bbox(iView,1):bbox(iView,1)+bbox(iView,3),:);
	rel_paw_img = relativeRGB(paw_img);
    
    r = rel_paw_img(:,:,1);
    g = rel_paw_img(:,:,2);
    b = rel_paw_img(:,:,3);
    
    colorArray = [r(:),g(:),b(:)];
    PCAcoeff(:,:,iView) = pca(colorArray);
    
    [PCA_paw_hist(:,:,iView),PCA_nonpaw_hist(:,:,iView),PCAbinEdges(:,:,iView)] = pawPCAhists(rel_paw_img, localPawMask, PCAcoeff(:,:,iView), numHistBins);
    
%     transformed_rgb = colorArray * PCAcoeff(:,:,iView);
%     
%     pca_paw = zeros(sum(paw_indices),3);
%     PCA_nonPaw = zeros(sum(~paw_indices),3);
%     for ii = 1 : 3
%         pca_paw(:,ii) = transformed_rgb(paw_indices,ii);
%         PCA_nonPaw(:,ii) = transformed_rgb(~paw_indices,ii);
%         
%         [fullHist,PCAbinEdges(:,iView,ii)] = histcounts(transformed_rgb(:,ii),numHistBins);
%         
%         [pawHist,~] = histcounts(pca_paw(:,ii),PCAbinEdges(:,iView,ii));
%         PCA_paw_hist(:,iView, ii) = pawHist/sum(fullHist);
%         [non_pawHist,~] = histcounts(PCA_nonPaw(:,ii),PCAbinEdges(:,iView,ii));
%         PCA_nonpaw_hist(:,ii,iView) = non_pawHist / sum(fullHist);
%     end
    
    
    
%     PCAmean_nonPaw(iView,:) = mean(PCA_nonPaw);
%     PCAmean(iView,:) = mean(pca_paw);
%     PCAcovar(:,:,iView) = cov(pca_paw);

    
end

