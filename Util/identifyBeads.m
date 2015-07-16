function [beadLocations, beadMasks] = identifyBeads(I, varargin)

minBeadArea = 0300;
maxBeadArea = 2000;
maxEccentricity = 0.8;

% decorrStretchMean  = [100.0 127.5 127.5
%                       200.0 127.5 200.0
%                       127.5 127.5 100.0];
% decorrStretchSigma = [050 025 025
%                       025 025 025
%                       025 025 050];
hsvBounds_beads = [0.00    0.16    0.50    1.00    0.00    1.00
                   0.33    0.16    0.00    0.50    0.00    0.50
                   0.66    0.16    0.50    1.00    0.00    1.00];
for iarg = 1 : 2 : nargin - 1
    switch lower(varargin{iarg})
        case 'minbeadarea',
            minBeadArea = varargin{iarg + 1};
        case 'maxbeadarea',
            maxBeadArea = varargin{iarg + 1};
        case 'hsvbounds',
            hsvBounds_beads = varargin{iarg + 1};
        case 'maxeccentricity',
            maxEccentricity = varargin{iarg + 1};
    end
end

I_hsv = rgb2hsv(I);

% find the beads
h_beadBlob = vision.BlobAnalysis;
h_beadBlob.AreaOutputPort = true;
h_beadBlob.CentroidOutputPort = true;
h_beadBlob.BoundingBoxOutputPort = true;
h_beadBlob.EccentricityOutputPort = true;
h_beadBlob.MinimumBlobArea = minBeadArea;
h_beadBlob.MaximumBlobArea = maxBeadArea;
h_beadBlob.LabelMatrixOutputPort = true;

beadCent = cell(1,3);
beadSortIdx = cell(1,3);
beadMasks = false(size(I,1),size(I,2), 3);
for ii = 1 : 3
    
    thresh_mask = HSVthreshold(I_hsv, hsvBounds_beads(ii,:));
    thresh_mask = imfill(thresh_mask,'holes');
    beadMasks(:,:,ii) = thresh_mask;
    
    [~,~,~,beadEcc,beadLabelMatrix] = ...
        step(h_beadBlob,thresh_mask);
    for jj = 1 : length(beadEcc)
        if beadEcc(jj) > maxEccentricity
            beadLabelMatrix(beadLabelMatrix == jj) = 0;
        end
    end
    beadMasks(:,:,ii) = (beadLabelMatrix > 0);
    [~,beadCent{ii},~,~,~] = ...
        step(h_beadBlob,squeeze(beadMasks(:,:,ii)));

    [~, beadSortIdx{ii}] = sort(beadCent{ii}(:,1));   % sort beads by centroids moving from left to right across the screen
    beadCent{ii} = round(beadCent{ii}(beadSortIdx{ii},:));

end

% map left mirror bead centroids to center view bead centroids
% top red bead is first row; bottom red bead is second row
% next blue beads above reaching slot: top blue bead is third row, bottom
%   blue bead is fourth row 

% RED BEADS
beadLocations.left_mirror_red_beads = beadCent{1}(1:2,:);
[~, idx] = sort(beadLocations.left_mirror_red_beads(:,2));
beadLocations.left_mirror_red_beads = beadLocations.left_mirror_red_beads(idx,:);
% % find the rightmost points of the red beads in the right mirror - this
% % will be useful for finding the front of the box later
% topBeadMask = (beadLabelMatrix{1} == beadSortIdx{ii}(1));
% botBeadMask = (beadLabelMatrix{1} == beadSortIdx{ii}(2));
% [y,x] = find(topBeadMask);
% max_x_idx = (x==max(x));
% topFrontPt = [x(max_x_idx),y(max_x_idx)];
% 
% [y,x] = find(botBeadMask);
% max_x_idx = (x==max(x));
% botFrontPt = [x(max_x_idx),y(max_x_idx)];

beadLocations.center_red_beads = beadCent{1}(3:4,:);
[~, idx] = sort(beadLocations.center_red_beads(:,2));
beadLocations.center_red_beads = beadLocations.center_red_beads(idx,:);

% BLUE BEADS ON THE LEFT
left_mirror_blue_beads = beadCent{3}(1:4,:);
[~, idx] = sort(left_mirror_blue_beads(:,2));
beadLocations.left_mirror_top_blue_beads = left_mirror_blue_beads(idx(1:2),:);

beadLocations.left_mirror_shelf_blue_beads = left_mirror_blue_beads(idx(3:4),:);    % the two bottom beads in the left mirror
% now sort from left to right to match with the front view beads
[~, shelf_idx] = sort(beadLocations.left_mirror_shelf_blue_beads(:,1));
beadLocations.left_mirror_shelf_blue_beads = beadLocations.left_mirror_shelf_blue_beads(shelf_idx, :);

% BLUE BEADS IN THE CENTER
% first the blue beads next to the reaching slot on top
center_blue_beads = beadCent{3}(5:8,:);
[~, idx] = sort(center_blue_beads(:, 2));
beadLocations.center_top_blue_beads = center_blue_beads(idx(1:2),:);

% now the blue beads on the shelf
beadLocations.center_shelf_blue_beads = center_blue_beads(idx(3:4),:);   % these are the bottom two blue beads
[~, idx] = sort(beadLocations.center_shelf_blue_beads(:,1));    % find left and right blue beads
beadLocations.center_shelf_blue_beads = beadLocations.center_shelf_blue_beads(idx,:);

% BLUE BEADS IN THE RIGHT MIRROR
right_mirror_blue_beads = beadCent{3}(9:12,:);
[~, idx] = sort(right_mirror_blue_beads(:,2));
beadLocations.right_mirror_top_blue_beads = right_mirror_blue_beads(idx(1:2),:);

beadLocations.right_mirror_shelf_blue_beads = right_mirror_blue_beads(idx(3:4),:);
[~, idx] = sort(beadLocations.right_mirror_shelf_blue_beads(:,1));    % sort shelf beads from left to right; right bead is the reflection of the near bead in front
beadLocations.right_mirror_shelf_blue_beads = beadLocations.right_mirror_shelf_blue_beads(idx,:);

% GREEN BEADS
if size(beadCent{2},1) > 4        % if a green bead shows up in the left mirror, ignore it
    beadCent{2} = beadCent{2}(end-3:end,:);
end
beadLocations.right_mirror_green_beads = beadCent{2}(3:4,:);
[~, idx] = sort(beadLocations.right_mirror_green_beads(:,2));    % sort from top to bottom
beadLocations.right_mirror_green_beads = beadLocations.right_mirror_green_beads(idx,:);

beadLocations.center_green_beads = beadCent{2}(1:2,:);
[~, idx] = sort(beadLocations.center_green_beads(:, 2));
beadLocations.center_green_beads = beadLocations.center_green_beads(idx,:);