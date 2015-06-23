function boxMarkers = identifyBoxFront(img, register_ROI, boxMarkers, varargin)
%
% usage:
%
%
% INPUTS:
%
% VARARGS:
%
% OUTPUTS:

halfPatternWidth = 1;
uniformityThreshold = 100;
peakVarDiffThresh = 100;
normVarThresh = 0.01;

for iarg = 1 : 2 : nargin - 3
    switch lower(varargin{iarg})
        case 'peakvardiffthresh',
            peakVarDiffThresh = varargin{iarg + 1};
        case 'varthresh',
            normVarThresh = varargin{iarg + 1};
    end
end

gray_img = rgb2gray(img);
stretched_img = decorrstretch(img);
seedMask = cell(1,3);
frontPanel_x = zeros(2,5);frontPanel_y = zeros(2,5);
for ii = 1 : 2
    mirrorIdx = (ii-1)*2 + 1;
	if ii == 1
        beadLocs = boxMarkers.beadLocations.left_mirror_red_beads;
        x_step = 1;
    else
        beadLocs = boxMarkers.beadLocations.right_mirror_green_beads;
        x_step = -1;
    end
    % start with a line drawn between the two red bead/green bead centroids
    
    patternMatchBorders_x = [beadLocs(1,1) - x_step*halfPatternWidth, ...
                             beadLocs(1,1) + x_step*halfPatternWidth, ...
                             beadLocs(2,1) + x_step*halfPatternWidth, ...
                             beadLocs(2,1) - x_step*halfPatternWidth];
    patternMatchBorders_y = [beadLocs(1,2), ...
                             beadLocs(1,2), ...
                             beadLocs(2,2), ...
                             beadLocs(2,2)];

%     x = patternMatchBorders_x;
    if ii == 1
        xtop = patternMatchBorders_x(1) : x_step : ...
            register_ROI(mirrorIdx,1) + register_ROI(mirrorIdx,3) - x_step*10;
        xbot = xtop + (beadLocs(2,1) - beadLocs(1,1) + 1);
    else
        xtop = patternMatchBorders_x(1) : x_step : register_ROI(mirrorIdx,1) - x_step*10;
        xbot = xtop + (beadLocs(2,1) - beadLocs(1,1) + 1);
    end
    img_variance = zeros(1,length(xtop));
    for i_x = 1 : length(xtop)
        patternMatchBorders_x = [xtop(i_x), xtop(i_x)+2*halfPatternWidth, xbot(i_x)+2*halfPatternWidth, xbot(i_x)];
        matchPattern = poly2mask(patternMatchBorders_x, ...
                                 patternMatchBorders_y, ...
                                 size(gray_img,1), ...
                                 size(gray_img,2));
        mask_idx = find(matchPattern);
        img_variance(i_x) = var(double(gray_img(mask_idx)));
        
%         figure(3)
%         imshow(uint8(matchPattern).*gray_img);
        
    end
    % WORKING HERE, SHOULD BE ABLE TO IDENTIFY BORDER OF BOX BASED ON
    % UNIFORMITY OF VALUES ALONG THIS LINE...
    var_range = range(img_variance);
    normalized_var = (img_variance - min(img_variance)) / var_range;
%     img_variance_diff = diff(img_variance);
    frontPanelEdges = zeros(1,2);
    frontPanelEdges(1) = find(normalized_var < normVarThresh, 1, 'first');
    frontPanelEdges(2) = find(normalized_var < normVarThresh, 1, 'last');
%     minVarDiff_x = find(img_variance_diff == min(img_variance_diff)) + 2;   % add 2 because samples shift when taking the difference
%                                                                             % and because panel seems to start 1 pixel over from maximum variance slope
%     % find next peak of img_variance_diff > 100
%     peaksMask = false(1, length(img_variance_diff));
%     peaksMask(minVarDiff_x:end) = true;
%     peaks = get_peaks(img_variance_diff, 2, 'pos');
%     peaks = peaks & (img_variance_diff > peakVarDiffThresh) & peaksMask;
%     frontPanelEnd = find(peaks, 1) - 1;
    frontPanel_x(ii,:) = [xtop(frontPanelEdges(1)), xtop(frontPanelEdges(2)), xbot(frontPanelEdges(2)), xbot(frontPanelEdges(1)), xtop(frontPanelEdges(1))];
    frontPanel_y(ii,:) = [patternMatchBorders_y, patternMatchBorders_y(1)];
    
%     figure(1)
%     hold on
%     plot(normalized_var);
%     hold on
%     plot(img_variance_diff/max(abs(img_variance_diff)));
%     plot(find(logical(peaks)),img_variance_diff(logical(peaks))/max(abs(img_variance_diff)), ...
%         'marker','*','linestyle','none');
    
%     figure(2)
%     if ii == 1
%         imshow(img);
%     end
%     hold on
%     plot(frontPanel_x,frontPanel_y);
%     
%     seedMask{ii} = poly2mask(frontPanel_x, ...
%                              frontPanel_y, ...
%                              size(gray_img,1), ...
%                              size(gray_img,2));

end
boxMarkers.frontPanel_x = frontPanel_x;
boxMarkers.frontPanel_y = frontPanel_y;
% ctrBorders_x = round([size(img,2)*2, size(img,2)*3, size(img,2)*3, size(img,2)*2]/5);
% ctrBorders_y = [1,1,size(img,1),size(img,2)];
% rectangle('position',[ctrBorders_x(1), ctrBorders_y(1), range(ctrBorders_x), range(ctrBorders_y)],...
%     'edgecolor','r');
% seedMask{3} = poly2mask(ctrBorders_x, ...
%                         ctrBorders_y, ...
%                         size(img,1), ...
%                         size(img,2));
%                         
% 
% [L,P] = imseggeodesic(stretched_img, seedMask{1}, seedMask{2}, seedMask{3});

end