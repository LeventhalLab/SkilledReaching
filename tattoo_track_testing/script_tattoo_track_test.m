% scipt_tattoo_track_test
% testing identification of tattooed paw and digits

% algorithm outline:
% first issue: correctly identify colored paw regions

% 1) calibrate based on rubiks image to get fundamental matrix
%       - mark matching points either manually or automatically. manually
%       is probably going to be more accurate until we put clearer markers
%       in.
%       - create matrices of matching points coordinates and calculate F
%       for left to center and right to center
% 2) 


% criteria we can use to identify the paw:
%   1 - the paw is moving
%   2 - dorsum of the paw is (mostly) green
%   3 - palmar aspect is (mostly) pink
%   4 - it's different from the background image   
%%
% sampleVid  = fullfile('/Volumes/RecordingsLeventhal04/SkilledReaching/R0030/R0030-rawdata/R0030_20140430a','R0030_20140430_13-09-15_023.avi');
sampleVid  = fullfile('/Volumes/RecordingsLeventhal3/SkilledReaching/R0044/R0044-rawdata/R0044_20150416a', 'R0044_20150416_12-11-45_034.avi');
sr_summary = sr_ratList();

minBeadArea = 0300;
maxBeadArea = 1500;
pointsPerRow = 4;    % for the checkerboard detection

test_ratID = 44;
% rat_idx = find(sr_summary.ratID == 44);
rat_metadata = create_sr_ratMetadata(sr_summary, test_ratID);

video = VideoReader(sampleVid);
frame_h = video.Height;
frame_w = video.Width;
numFrames = video.numberOfFrames;
numBGframes = 50;
ROI_to_find_trigger_frame = [0210         0590         0050         0070
                             1740         0560         0050         0070];

left_ROI_left  = 0001;ctr_ROI_left = 0930;rgt_ROI_left = 1730;
left_ROI_top   = 0001;ctr_ROI_top  = 0001;rgt_ROI_top  = 0001;
left_ROI_width = 0269;ctr_ROI_width = 0180;
ROI_to_mask_paw = [left_ROI_left      left_ROI_top	  left_ROI_width            frame_h-left_ROI_top
                   ctr_ROI_left       ctr_ROI_top 	  ctr_ROI_width             frame_h-ctr_ROI_top
                   rgt_ROI_left       rgt_ROI_top     frame_w-rgt_ROI_left-1    frame_h-rgt_ROI_top];

%WORKING HERE - NEED TO FIGURE OUT THE BOUNDARIES OF THE REGION OF INTEREST
%FOR FINDING THE TRANSFORMATION BETWEEN THE LEFT/RIGHT MIRRORS AND THE
%CENTER IMAGE
% left_ROI_left   = 0001;ctr_ROI_left = 280;rgt_ROI_left = 1730;
% left_ROI_top    = 0001;ctr_ROI_top  = 0001;rgt_ROI_top  = 0001;
% left_ROI_width  = 0269;ctr_ROI_width = 1400;
% left_ROI_height = 1024-left_ROI_top;
% register_ROI   = [left_ROI_left      left_ROI_top	  left_ROI_width            frame_h-left_ROI_top
%                   ctr_ROI_left       ctr_ROI_top 	  ctr_ROI_width             frame_h-ctr_ROI_top
%                   rgt_ROI_left       rgt_ROI_top     frame_w-rgt_ROI_left-1    frame_h-rgt_ROI_top];
               


gray_paw_limits = [60 125];
hsvBounds_beads = [0.00, 0.15, 0.55, 1.00, 0.30, 1.00
                   0.40, 0.15, 0.10, 0.50, 0.00, 0.50
                   0.62, 0.15, 0.50, 1.00, 0.20, 1.00];
hsvBounds_paw   = [];
% first row - red digits
% second row - green digits
% third row - purple digits
               
% BGimg = extractBGimg( video, 'numbgframes', numBGframes);   % can comment out once calculated the first time during debugging
boxMarkers.beadLocations = identifyBeads(BGimg, hsvBounds_beads, ...
                                         'minbeadarea',minBeadArea, ...
                                         'maxbeadarea',maxBeadArea);
register_ROI(1,1) = 1; register_ROI(1,2) = 1;   % top left corner of left mirror region of interest
register_ROI(1,3) = round(min(beadLocations.center_red_beads(:,1))) - 5;  % right edge, move just to the left to make sure red bead centroids can be included in the center image
register_ROI(1,4) = size(BGimg,1) - register_ROI(1,2);  % bottom edge

register_ROI(2,1) = register_ROI(1,3) + 2; register_ROI(2,2) = 1;   % top left corner of left mirror region of interest
register_ROI(2,4) = size(BGimg,1) - register_ROI(2,2);  % bottom edge

register_ROI(3,1) = round(max(beadLocations.center_green_beads(:,1))) + 5;   % left edge
register_ROI(3,2) = 1;   % top edge of right mirror region of interest
register_ROI(3,3) = size(BGimg,2) - register_ROI(3,1);  % right edge, extend to edge of the image
register_ROI(3,4) = size(BGimg,1) - register_ROI(1,2);  % bottom edge

register_ROI(2,3) = register_ROI(3,1) - register_ROI(2,1) - 2;  % right edge, move just to the left to make sure green bead centroids can be included in the center image

BG_lft = uint8(BGimg(register_ROI(1,2):register_ROI(1,2) + register_ROI(1,4), ...
                     register_ROI(1,1):register_ROI(1,1) + register_ROI(1,3), :));
BG_ctr = uint8(BGimg(register_ROI(2,2):register_ROI(2,2) + register_ROI(2,4), ...
                     register_ROI(2,1):register_ROI(2,1) + register_ROI(2,3), :));
BG_rgt = uint8(BGimg(register_ROI(3,2):register_ROI(3,2) + register_ROI(3,4), ...
                     register_ROI(3,1):register_ROI(3,1) + register_ROI(3,3), :));
BG_leftctr  = uint8(BGimg(register_ROI(2,2):register_ROI(2,2) + register_ROI(2,4), ...
                    register_ROI(2,1):round(frame_w/2), :));
BG_rightctr = uint8(BGimg(register_ROI(2,2):register_ROI(2,2) + register_ROI(2,4), ...
                    round(frame_w/2):register_ROI(2,1) + register_ROI(2,3), :));
                
% find the checkerboard points
% cbLocations.left_mirror_cb  = detect_SR_checkerboard(BG_lft);
% cbLocations.right_mirror_cb = detect_SR_checkerboard(BG_rgt);
% cbLocations.left_center_cb  = detect_SR_checkerboard(BG_leftctr);
% cbLocations.right_center_cb = detect_SR_checkerboard(BG_rightctr);
boxMarkers.cbLocations = cbLocations;
boxMarkers = identifyBoxFront(BGimg, register_ROI, boxMarkers);

F = fundMatrixFromBGimg(BGimg, ...
                        boxMarkers, ...
                        register_ROI, ...
                        'pointsperrow', pointsPerRow);
% [Fleft, Fright, matchedPoints] = fundMatrixFromBGimg(BGimg, register_ROI, hsvBounds_beads, ...
%                                                  'minbeadarea',minBeadArea, ...
%                                                  'maxbeadarea',maxBeadArea, ...
%                                                  'pointsperrow', pointsPerRow);

% [Fleft, Fright] = fundMatrixFromBGimg(BGimg, register_ROI, hsvBounds_beads, ...
%                                       'minbeadarea',minBeadArea, ...
%                                       'maxbeadarea',maxBeadArea, ...
%                                       'pointsperrow', pointsPerRow);
                                  
% calculate epipolar lines and see if they line up correctly
% leftLines   = epipolarLine(Fleft, matchedPoints{1});
% righttLines = epipolarLine(Fright, matchedPoints{2});

[digitImg_enh,centerImg_enh] = trackTattooedPaw(video,...
                                                rat_metadata,...
                                                F,...
                                                register_ROI, ...
                                                boxMarkers,...
                                                'trigger_roi',ROI_to_find_trigger_frame, ...
                                                'graypawlimits',gray_paw_limits, ...
                                                'mask_roi',ROI_to_mask_paw, ...
                                                'bgimg',BGimg);


% hsvBounds_grn = [0.3300    0.4300    0.2500    0.7500    0.2300    1];
% hsvBounds_paw = [0    0.4    .15    0.67    0.45 .65]; % from Titus' code
% rgbBounds_paw = [100 255 100 200 90 170];

% the hsv boundaries to create the mask to identify the beads in the
% background image. First row - red, second row - blue, third row - green.
% First column - center of hue values, second column - range of hue values,
% 3rd column - lower saturation bound, 4th column - upper saturation bound,
% 5th column - lower value bound, 6th column - upper value bound

% the rgb boundaries for the checkerboards. first row - black squares,
% second row - white squares. first col - min r value, second col - max r
% values, third col - min g value, fourth col - max g value, fifth col -
% min b value, sixth col - max b value
rgbBounds_checkers = [000 050 000 050 000 050
                      220 255 220 255 220 255];
% the acceptable locations for each set of beads/checkerboards in the raw
% image. first row - red, second row - green, third row - blue left, fourth
% row - blue center, fifth row - blue right. First and second columns
% are min and max horizontal locations, third and fourth columns are min
% and max vertical values.
locBounds_beads = [0150, 0500, 0200, 0850
                   1500, 1850, 0200, 0850
                   0001, 0300, 0300, 0750
                   0450, 1500, 0200, 0800
                   1700, 2040, 0300, 0750];
locBounds_checkers = [0050, 0300, 0375, 0600
                      0600, 0775, 0300, 0600
                      1200, 1400, 0300, 0600
                      1750, 1950, 0350, 0575];
ROI = zeros(3,4);
%%

register_ROI(1,:) = [1 150 300 780];
register_ROI(2,:) = [400 150 1300 780];
register_ROI(3,:) = [1700 150 300 780];

% find the fundamental matrix based on the rubiks cube calibration
% [Fleft, Fright] = fundamentalMatricesFromRubiks(rubiksName, register_ROI);

% ROI(1,:) = [70 530 140 100];
% ROI(2,:) = [920 550 200 100];
% ROI(3,:) = [1775,530,145,100];

% ROI to find the trigger frame should exclude the pellet
ROI_to_find_trigger_frame = [  0030         0570         0120         0095
                               0850         0580         0340         0150
                               1880         0550         0120         0095];
    %%
% cal_img     = imread(rubiksName);
% lftFrame_bg = cal_img(register_ROI(1,2):register_ROI(1,2) + register_ROI(1,4), ...
%                       register_ROI(1,1):register_ROI(1,1) + register_ROI(1,3), :);
% ctrFrame_bg = cal_img(register_ROI(2,2):register_ROI(2,2) + register_ROI(2,4), ...
%                       register_ROI(2,1):register_ROI(2,1) + register_ROI(2,3), :);
% rtFrame_bg  = cal_img(register_ROI(3,2):register_ROI(3,2) + register_ROI(3,4), ...
%                       register_ROI(3,1):register_ROI(3,1) + register_ROI(3,3), :);
%                   
% lftFrame_bg = fliplr(lftFrame_bg);
% rtFrame_bg  = fliplr(rtFrame_bg);
% 
BGframes = uint8(zeros(numBGFrames, video.Height, video.Width, 3));
for ii = 1 : numBGFrames
    BGframes(ii,:,:,:) = read(video, ii);
end
BGimg = uint8(squeeze(mean(BGframes, 1)));
BGimg_hsv = rgb2hsv(BGimg);
BG_r = squeeze(BGimg(:,:,1));
BG_g = squeeze(BGimg(:,:,2));
BG_b = squeeze(BGimg(:,:,3));



% find the beads
beadMask = false(size(BGimg, 1),size(BGimg,2),3);
SE_beads = strel('disk',2);   % smoothing element for bead analysis
bead_blobs = vision.BlobAnalysis('CentroidOutputPort', true, ...
                                 'AreaOutputPort', true, ...
                                 'MinimumBlobAreaSource', 'Property',...
                                 'MinimumBlobArea',500, ...
                                 'MaximumBlobArea',2000);
for ii = 1 : 3
    beadMask(:,:,ii) = HSVthreshold(BGimg_hsv, hsvBounds_beads(ii,:));
   
    switch ii,
        case 1,    % red beads, left mirror
            % criteria to identify red beads:
            %    1) pixels are in the mask
            %    2) are on the left side of the image
            %    3) have an area of at least 500 but less than 2000 (set in
            %    bead_blobs - vision.BlobAnalysis...
            locMask = createLocationMask(size(beadMask,2),size(beadMask,1), locBounds_beads(1,:));
            mask = beadMask(:,:,ii) & locMask;
            
            mask = imopen(mask,SE_beads);
            mask = imclose(mask,SE_beads);
            mask = imfill(mask,'holes');
            
            % detect blobs
            [rbead_area, rbead_centroids] = step(bead_blobs, mask);
            
        case 2,     % green beads
            % criteria to identify red beads:
            %    1) pixels are in the mask
            %    2) are on the left side of the image
            %    3) have an area of at least 500 but less than 2000 (set in
            %    bead_blobs - vision.BlobAnalysis...
            locMask = createLocationMask(size(beadMask,2),size(beadMask,1), locBounds_beads(2,:));
            mask = beadMask(:,:,ii) & locMask;
            
            mask = imopen(mask,SE_beads);
            mask = imclose(mask,SE_beads);
            mask = imfill(mask,'holes');
            
            % detect blobs
            [gbead_area, gbead_centroids] = step(bead_blobs, mask);
            
        case 3,     % blue beads
            
            % THIS PART ISN'T WORKING RIGHT............
            
            
            % find blue beads in the left mirror
            locMask = createLocationMask(size(beadMask,2),size(beadMask,1), locBounds_beads(3,:));
            lft_mask = beadMask(:,:,ii) & locMask;
            
            lft_mask = imopen(lft_mask,SE_beads);
            lft_mask = imclose(lft_mask,SE_beads);
            lft_mask = imfill(lft_mask,'holes');
            
            % detect blobs
            [lft_bbead_area, lft_bbead_centroids] = step(bead_blobs, mask);
            
            % find blue beads in the center view
            locMask = createLocationMask(size(beadMask,2),size(beadMask,1), locBounds_beads(4,:));
            ctr_mask = beadMask(:,:,ii) & locMask;
            
            ctr_mask = imopen(ctr_mask,SE_beads);
            ctr_mask = imclose(ctr_mask,SE_beads);
            ctr_mask = imfill(ctr_mask,'holes');
            
            % detect blobs
            [ctr_bbead_area, ctr_bbead_centroids] = step(bead_blobs, mask);
            
            % find blue beads in the right view
            locMask = createLocationMask(size(beadMask,2),size(beadMask,1), locBounds_beads(5,:));
            rgt_mask = beadMask(:,:,ii) & locMask;
            
            rgt_mask = imopen(rgt_mask,SE_beads);
            rgt_mask = imclose(rgt_mask,SE_beads);
            rgt_mask = imfill(rgt_mask,'holes');
            
            % detect blobs
            [rgt_bbead_area, rgt_bbead_centroids] = step(bead_blobs, mask);           
    end
end
% find the left (red beads) and right (green beads) edges of the boxn in the center view
rbead_x = rbead_centroids(:,1);
lft_mirror_rt_edge = round(mean(rbead_x(rbead_x > 0300))) - 20;   % 300 chosen because it's between the red beads and their images in the left mirror

gbead_x = gbead_centroids(:,1);
rt_mirror_lft_edge = round(mean(gbead_x(gbead_x < 1650))) + 20;   % 300 chosen because it's between the red beads and their images in the left mirror

% hardcode the top and bottom of the mirror images, for now
lft_mirror_top_edge = round(max(rbead_centroids(:,2)));
rt_mirror_top_edge  = round(max(gbead_centroids(:,2)));
lft_mirror_bot_edge = 0880;
rt_mirror_bot_edge  = 0850;

% WORKING HERE - NEED TO EXTRACT THE MIRROR IMAGES AND WORK ON GETTING THE
% FUNDAMENTAL MATRIX USING THE AUTOMATED MATLAB ROUTINES FOR CODE

% find the checkerboard points
for ii = 1 : 4
    locMask = createLocationMask(size(beadMask,2),size(beadMask,1), locBounds_checkers(ii,:));
    
    blk_mask = (BG_r >= rgbBounds_checkers(1,1) & BG_r <= rgbBounds_checkers(1,2));
    blk_mask = blk_mask & (BG_g >= rgbBounds_checkers(1,3) & BG_g <= rgbBounds_checkers(1,4));
    blk_mask = blk_mask & (BG_b >= rgbBounds_checkers(1,5) & BG_b <= rgbBounds_checkers(1,6));
    blk_mask = blk_mask & locMask;

    wht_mask = (BG_r >= rgbBounds_checkers(2,1) & BG_r <= rgbBounds_checkers(2,2));
    wht_mask = wht_mask & (BG_g >= rgbBounds_checkers(2,3) & BG_g <= rgbBounds_checkers(2,4));
    wht_mask = wht_mask & (BG_b >= rgbBounds_checkers(2,5) & BG_b <= rgbBounds_checkers(2,6));
    wht_mask = wht_mask & locMask;
end

% now match up the bead centroids
% first, match up the left mirror view with the center view, using the
% original image coordinates
lft_matched_points = zeros(6,2);
% WORKING HERE...


% 
% BG_lft = BGimg(register_ROI(1,2):register_ROI(1,2) + register_ROI(1,4), ...
%                register_ROI(1,1):register_ROI(1,1) + register_ROI(1,3), :);
% BG_ctr = BGimg(register_ROI(2,2):register_ROI(2,2) + register_ROI(2,4), ...
%                register_ROI(2,1):register_ROI(2,1) + register_ROI(2,3), :);
% BG_rgt = BGimg(register_ROI(3,2):register_ROI(3,2) + register_ROI(3,4), ...
%                register_ROI(3,1):register_ROI(3,1) + register_ROI(3,3), :);
%            
% BG_lft = fliplr(BG_lft);
% BG_rgt = fliplr(BG_rgt);
% 

lftFrame = uint8(zeros(numFrames, ROI(1,4)+1, ROI(1,3)+1, 3));
ctrFrame = uint8(zeros(numFrames, ROI(2,4)+1, ROI(2,3)+1, 3));
rtFrame  = uint8(zeros(numFrames, ROI(3,4)+1, ROI(3,3)+1, 3));

lftFrame_hsv = double(zeros(numFrames, ROI(1,4)+1, ROI(1,3)+1, 3));
ctrFrame_hsv = double(zeros(numFrames, ROI(2,4)+1, ROI(2,3)+1, 3));
rtFrame_hsv  = double(zeros(numFrames, ROI(3,4)+1, ROI(3,3)+1, 3));
%%
% for iFrame = 1 : numFrames
%     iFrame
%     curFrame = read(video, iFrame);
%     lftFrame(iFrame, :, :, :) = fliplr(curFrame(ROI(1,2):ROI(1,2)+ROI(1,4), ...
%                                                 ROI(1,1):ROI(1,1)+ROI(1,3), :));
%     ctrFrame(iFrame, :, :, :) = curFrame(ROI(2,2):ROI(2,2)+ROI(2,4), ...
%                                          ROI(2,1):ROI(2,1)+ROI(2,3), :);
%     rtFrame(iFrame, :, :, :)  = fliplr(curFrame(ROI(3,2):ROI(3,2)+ROI(3,4), ...
%                                                 ROI(3,1):ROI(3,1)+ROI(3,3), :));
%                                             
%     lftFrame_hsv(iFrame,:,:,:) = rgb2hsv(squeeze(lftFrame(iFrame,:,:,:)));
%     ctrFrame_hsv(iFrame,:,:,:) = rgb2hsv(squeeze(ctrFrame(iFrame,:,:,:)));
%     rtFrame_hsv(iFrame,:,:,:)  = rgb2hsv(squeeze(rtFrame(iFrame,:,:,:)));
%                   
%     % use algorithm from pawData to find the frame in which the paw is
%     % best seen. *** Does this mean max eccentricity? max ability to
%     % distinguish fingers?
%     
% end


% BG_subt_test = uint8(imabsdiff(double(test_img), BGimg));
% BG_subt_lft_test = uint8(imabsdiff(double(lftFrame_test), BG_lft));
% BG_subt_ctr_test = uint8(imabsdiff(double(ctrFrame_test), BG_ctr));
% BG_subt_rgt_test = uint8(imabsdiff(double(rtFrame_test), BG_rgt));

% BG_subt_test     = uint8(abs(double(test_img) - BG_lft));
% BG_subt_lft_test = uint8(abs(double(lftFrame_test) - BG_lft));
% BG_subt_ctr_test = uint8(abs(double(ctrFrame_test) - BG_ctr));
% BG_subt_rgt_test = uint8(abs(double(rtFrame_test) - BG_rgt));
                     
% lftFrame_test_hsv = rgb2hsv(lftFrame_test);
% ctrFrame_test_hsv = rgb2hsv(ctrFrame_test);
% rtFrame_test_hsv  = rgb2hsv(rtFrame_test);
% 
% lftFrame_test_h = squeeze(lftFrame_test_hsv(:,:,1));
% lftFrame_test_s = squeeze(lftFrame_test_hsv(:,:,2));
% lftFrame_test_v = squeeze(lftFrame_test_hsv(:,:,3));

grnCenter = NaN(3,2);   % view x x,y matrix
pawHull = NaN(3,2);

% identify the frames where the paw is visible over the shelf
BG_lft = uint8(BGimg(ROI_to_find_trigger_frame(1,2):ROI_to_find_trigger_frame(1,2) + ROI_to_find_trigger_frame(1,4), ...
                     ROI_to_find_trigger_frame(1,1):ROI_to_find_trigger_frame(1,1) + ROI_to_find_trigger_frame(1,3), :));
BG_rgt = uint8(BGimg(ROI_to_find_trigger_frame(3,2):ROI_to_find_trigger_frame(3,2) + ROI_to_find_trigger_frame(3,4), ...
                     ROI_to_find_trigger_frame(3,1):ROI_to_find_trigger_frame(3,1) + ROI_to_find_trigger_frame(3,3), :));

mean_BG_subt_values = zeros(numFrames, 2);
for iFrame = 1 : numFrames
    img = read(video, iFrame);
    
    lft_mirror_img = img(ROI_to_find_trigger_frame(1,2):ROI_to_find_trigger_frame(1,2) + ROI_to_find_trigger_frame(1,4), ...
                         ROI_to_find_trigger_frame(1,1):ROI_to_find_trigger_frame(1,1) + ROI_to_find_trigger_frame(1,3), :);
    rgt_mirror_img = img(ROI_to_find_trigger_frame(3,2):ROI_to_find_trigger_frame(3,2) + ROI_to_find_trigger_frame(3,4), ...
                         ROI_to_find_trigger_frame(3,1):ROI_to_find_trigger_frame(3,1) + ROI_to_find_trigger_frame(3,3), :);
                     
    lft_mirror_BG = imabsdiff(lft_mirror_img, BG_lft);
    rgt_mirror_BG = imabsdiff(rgt_mirror_img, BG_rgt);
                     
	lft_mirror_gry = rgb2gray(lft_mirror_BG);
    rgt_mirror_gry = rgb2gray(rgt_mirror_BG);
    
    % WORKING HERE...
    % INSTEAD OF USING MEAN BACKGROUND SUBTRACTED VALUES, TRY THE MAXIMUM
    % NUMBER OF PIXELS THAT DEVIATE FROM THE BACKGROUND BY SOME THRESHOLD.
    % PROBLEM IS TO KEEP FROM IDENTIFYING A FRAME WHERE THE PELLET AND THE
    % PAW OVERLAP - MESSES UP THE BLOB IDENTIFICATION FROM BACKGROUND
    % SUBTRACTION.
    % NEXT STEP IS TO IDENTIFY INDIVIDUAL DIGITS, THEN TRACK THEM WITH
    % KALMAN FILTER OR SOMETHING SIMILAR. ALSO, NEED TO USE INFORMATION
    % FROM MULTIPLE VIEWS TO FIND THE DIGITS IN A SINGLE VIEW
    
    lft_values = reshape(rgb2gray(lft_mirror_BG), [1, numel(lft_mirror_gry)]);
    rgt_values = reshape(rgb2gray(rgt_mirror_BG), [1, numel(rgt_mirror_gry)]);
    mean_BG_subt_values(1, iFrame) = mean(lft_values);
    mean_BG_subt_values(2, iFrame) = mean(rgt_values);
    
%     figure(5);imshow(lft_mirror_gry);
%     figure(6);imshow(rgt_mirror_gry);
    
end

%%
maxFrame = zeros(1,2);
for ii = 1 : 2
    maxFrame(ii) = find(squeeze(mean_BG_subt_values(ii,:)) == max(mean_BG_subt_values(ii,:)));
end
test_frame_idx = round(mean(maxFrame));
test_img = read(video, test_frame_idx);

lftFrame_test = test_img(register_ROI(1,2):register_ROI(1,2) + register_ROI(1,4), ...
                         register_ROI(1,1):register_ROI(1,1) + register_ROI(1,3), :);
lftFrame_test = fliplr(lftFrame_test);
ctrFrame_test = test_img(register_ROI(2,2):register_ROI(2,2) + register_ROI(2,4), ...
                         register_ROI(2,1):register_ROI(2,1) + register_ROI(2,3), :);
rtFrame_test  = test_img(register_ROI(3,2):register_ROI(3,2) + register_ROI(3,4), ...
                         register_ROI(3,1):register_ROI(3,1) + register_ROI(3,3), :);
rtFrame_test  = fliplr(rtFrame_test);

lftFrame_closeup = test_img(ROI(1,2):ROI(1,2) + ROI(1,4), ...
                            ROI(1,1):ROI(1,1) + ROI(1,3), :);
ctrFrame_closeup = test_img(ROI(2,2):ROI(2,2) + ROI(2,4), ...
                            ROI(2,1):ROI(2,1) + ROI(2,3), :);
rgtFrame_closeup = test_img(ROI(3,2):ROI(3,2) + ROI(3,4), ...
                            ROI(3,1):ROI(3,1) + ROI(3,3), :);


%%
% LOOK TO SEE IF DIFFERENT COLOR SCHEMES (HSV, YCRCB, ETC.) ALLOW BETTER
% BETTER BACKGROUND SUBTRACTION THAN RGB. ALSO, DO WE NEED A DIFFERENT
% COLOR BACKGROUND? GREEN LOOKS LIKE THE GRAY BACKGROUND

for iView = 3 : 3
    % FROM pawData:
    % bound the hue element using all three bounds
    
    switch iView,
        case 1,
            test_im = lftFrame_test;
        case 2,
            test_im = ctrFrame_test;
        case 3,
            test_im = rtFrame_test;
    end
    test_im_gray = rgb2gray(test_im);
    test_im_hsv  = rgb2hsv(test_im);
    
%     test_im_hsv = rgb2hsv(test_im);
%     
%     test_im_h = squeeze(test_im_hsv(:,:,1));
%     test_im_s = squeeze(test_im_hsv(:,:,2));
%     test_im_v = squeeze(test_im_hsv(:,:,3));
%     
%     h_mask = ~(test_im_h < hsvBounds_grn(1) | test_im_h > hsvBounds_grn(2));
%     h_mask(test_im_s < hsvBounds_grn(3) | test_im_s > hsvBounds_grn(4)) = 0;
%     h_mask(test_im_v < hsvBounds_grn(5) | test_im_v > hsvBounds_grn(6)) = 0;
%     
%     mask = bwdist(h_mask) < 2;   % find all pixels less than 2 pixels away from another pixel
%     SE = strel('disk',2);
%     mask = imopen(mask,SE);   % "open" the image - gets rid of edge fuzzies, I think
%     mask = imclose(mask,SE);  % "close" the image - 
%     mask = imfill(mask,'holes');   % fill in holes - background pixels that can't be reached from the edge
%     
    grn_mask = findPawMask(test_im_hsv, hsvBounds_grn);
    % find "center of gravity" of the green region
    bwmask = bwdist(~grn_mask);
    [maxGravityValue,~] = max(bwmask(:));   % center of gravity taken as the point most distant from the closest edge of the paw mask
    
    [centerGravityColumns,centerGravityRows] = find(bwmask == maxGravityValue);
    centerGravityRow = round(mean(centerGravityRows));
    centerGravityColumn = round(mean(centerGravityColumns));
    grnCenter(iView,:) = [centerGravityRow centerGravityColumn];
    
    sigma = 1.0;
    grad_W = gradientweight(squeeze(test_im_hsv(:,:,3)),sigma, 'weightcutoff',0.25);
    seedGray = grnCenter(iView,:);
    grayDiff = graydiffweight(squeeze(test_im_hsv(:,:,3)), test_im_hsv(seedGray(1),seedGray(2),3));
    
    thresh = 0.2;
    [BW,D] = imsegfmm(grad_W, seedGray(1), seedGray(2), thresh);
    % now start with the green region and grow it into paw-colored regions
    
    hsv_paw_mask = findPawMask(rgb2hsv(test_im), hsvBounds_paw);
    rgb_paw_mask = findPawMask(test_im, rgbBounds_paw);
            
    full_paw_mask = (hsv_paw_mask & rgb_paw_mask) | grn_mask;
    
    figure(1);imshow(test_im);
%     figure(2);imshow(grn_mask);title('green mask')
%     figure(3);imshow(hsv_paw_mask);title('hsv paw');
%     figure(4);imshow(rgb_paw_mask);title('rgb paw');
%     figure(5);imshow(full_paw_mask);title('full mask');
%     figure(6);imshow(uint8(repmat(full_paw_mask, [1 1 3])) .* test_im);
    figure(7);imshow(grad_W)
%     figure(8);imshow(grayDiff/max(max(grayDiff)));
    figure(9);imshow(BW);
    
end
%     rtFrame_test_
% 
%     
%     h_mask = ~(lftFrame_test_h < hsvBounds_grn(1) | lftFrame_test_h > hsvBounds_grn(2));
%     h_mask(lftFrame_test_s < hsvBounds_grn(3) | lftFrame_test_s > hsvBounds_grn(4)) = 0;
%     h_mask(lftFrame_test_v < hsvBounds_grn(5) | lftFrame_test_v > hsvBounds_grn(6)) = 0;
%     lftFrame_test_h(lftFrame_test_s < hsvBounds_grn(3) | lftFrame_test_s > hsvBounds_grn(4)) = 0;
%     lftFrame_test_h(lftFrame_test_v < hsvBounds_grn(5) | lftFrame_test_v > hsvBounds_grn(6)) = 0;
%     
%     lftFrame_test_
%     pawCenter = NaN(3,2);
%     pawHull = NaN(3,2);
%     
% end    % for iView
% identify the blob from each angle


% 
% %%
% shapeInserter = vision.ShapeInserter('BorderColor','Black');
% detector = vision.ForegroundDetector;
% blob = vision.BlobAnalysis('CentroidOutputPort', true, 'AreaOutputPort', false, 'BoundingBoxOutputPort', true, 'MinimumBlobAreaSource', 'Property','MinimumBlobArea',250);
% videoPlayer = vision.VideoPlayer();
% vid = vision.VideoFileReader(sampleVid);
% %%
% shapeInserter.release();
% detector.release();
% blob.release();
% videoPlayer.release();
% vid.reset();
% 
% frameNum = 0;
% while ~isDone(vid)
%     frameNum = frameNum + 1
%     frame = step(vid);
%     fgMask = step(detector, frame(530:630,70:210,:));
%     bbox = step(blob, fgMask);
%     if ~isempty(bbox);
%         out = step(shapeInserter, frame(530:630,70:210,:), bbox);
%     else
%         out = frame(530:630,70:210,:);
%     end
% %     out = fgMask;
%     step(videoPlayer, out);
% end