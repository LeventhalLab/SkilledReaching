function [ PCA_paw_hist, PCA_nonpaw_hist, PCAbinEdges ] = pawPCAhists( local_relRGB, localPawMask, PCAcoeff, numHistBins )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

PCA_paw_hist = zeros(numHistBins,3);
PCA_nonpaw_hist = zeros(numHistBins,3);
PCAbinEdges = zeros(numHistBins+1,3);    % number of bins x 2 views x 3 principal components

% for iarg = 1 : 2 : nargin - 2
%     switch lower(varargin{iarg})
% 
%     end
% end
%     
paw_indices = localPawMask(:);
r = local_relRGB(:,:,1);
g = local_relRGB(:,:,2);
b = local_relRGB(:,:,3);

colorArray = [r(:),g(:),b(:)];

transformed_rgb = colorArray * PCAcoeff;


pca_paw = zeros(sum(paw_indices),3);
PCA_nonPaw = zeros(sum(~paw_indices),3);
for ii = 1 : 3
    
    % normalize pca values to be between 0 and 1
    normalized_pca = (transformed_rgb(:,ii) - min(transformed_rgb(:,ii))) / range(transformed_rgb(:,ii));
    
    pca_paw(:,ii) = normalized_pca(paw_indices);
    PCA_nonPaw(:,ii) = normalized_pca(~paw_indices);
    
%     pca_paw(:,ii) = transformed_rgb(paw_indices,ii);
%     PCA_nonPaw(:,ii) = transformed_rgb(~paw_indices,ii);
    
    % make sure we get a couple extra bins at the margins, in case the
    % image we analyze later has some values outside the current range
%     histLimits = [min(transformed_rgb(:,ii)),max(transformed_rgb(:,ii))];
%     histLimits = 0.1 * range(transformed_rgb(:,ii)) * [-1,1] + histLimits;
    
    PCAbinEdges(:,ii) = linspace(0,1,numHistBins+1)';
%     [~,PCAbinEdges(:,ii)] = histcounts(histLimits,numHistBins);
%     [fullHist,PCAbinEdges(:,ii)] = histcounts(transformed_rgb(:,ii),PCAbinEdges(:,ii));

    [pawHist,~] = histcounts(pca_paw(:,ii),PCAbinEdges(:,ii));
    PCA_paw_hist(:, ii) = pawHist/sum(pawHist);
%     PCA_paw_hist(:, ii) = pawHist/sum(fullHist);
%     PCA_paw_hist(:, ii) = smooth(PCA_paw_hist(:, ii));
    [non_pawHist,~] = histcounts(PCA_nonPaw(:,ii),PCAbinEdges(:,ii));
    PCA_nonpaw_hist(:, ii) = non_pawHist / sum(non_pawHist);
%     PCA_nonpaw_hist(:, ii) = non_pawHist / sum(fullHist);
%     PCA_nonpaw_hist(:, ii) = smooth(PCA_nonpaw_hist(:, ii));
end
    


end

