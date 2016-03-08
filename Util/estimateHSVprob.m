function meanHSVdist = estimateHSVprob(prevVals, img)

nbins = 100;
bins = zeros(3,nbins);
n = zeros(3,nbins);
for iCh = 1 : 3
    [n(iCh,:),bins(iCh,:)] = hist(prevVals(:,iCh),nbins);
    n(iCh,:) = smooth(n(iCh,:),3);
    n(iCh,:) = n(iCh,:) / sum(n(iCh,:));
end
    
    
h = circMean(prevVals(:,1),0,1);
meanVal = [h,mean(prevVals(:,2:3))];
meanHSVdist = HSVdiff(meanVal, img);

% for i_x = 1 : size(img,2)
%     for i_y = 1 : size(img,1)
% %        fprintf('%d,%d\n',i_x,i_y)
%         temp = HSVdiff(squeeze(img(i_y,i_x,:))',prevVals);
%         meanHSVdist(i_y,i_x,:) = mean(temp,1);
%         
%     end
%     
% end
            
            
            
    