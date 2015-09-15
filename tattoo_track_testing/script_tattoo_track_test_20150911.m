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

cb_path = '/Users/dleventh/Documents/Leventhal_lab_github/SkilledReaching/tattoo_track_testing/intrinsics calibration images';
num_rad_coeff = 2;
est_tan_distortion = false;
estimateSkew = false;
minBeadArea = 0300;
maxBeadArea = 2000;
pointsPerRow = 4;    % for the checkerboard detection
maxBeadEcc = 0.8;

test_ratID = 44;
rat_metadata = create_sr_ratMetadata(sr_summary, test_ratID);

video = VideoReader(sampleVid);
h = video.Height;
w = video.Width;
numBGframes = 50;

gray_paw_limits = [60 125] / 255;
hsvBounds_beads = [0.00    0.16    0.50    1.00    0.00    1.00
                   0.33    0.16    0.00    0.50    0.00    0.50
                   0.66    0.16    0.50    1.00    0.00    1.00];
   
BGimg = extractBGimg( video, 'numbgframes', numBGframes);   % can comment out once calculated the first time during debugging
boxCalibration = calibrate_sr_box(BGimg, 'cb_path',cb_path,...
                                         'numradialdistortioncoefficients',num_rad_coeff,...
                                         'estimatetangentialdistortion',est_tan_distortion,...
                                         'estimateskew',estimateSkew,...
                                         'minbeadarea',minBeadArea,...
                                         'maxbeadarea',maxBeadArea,...
                                         'hsvbounds',hsvBounds_beads,...
                                         'maxeccentricity',maxBeadEcc,...
                                         'pointsperrow',pointsPerRow);

BGimg_ud = undistortImage(BGimg, boxCalibration.cameraParams);
triggerTime = identifyTriggerTime( video, BGimg_ud, rat_metadata, boxCalibration, ...
                                   'pawgraylevels',gray_paw_limits);

[initDigitMasks, init_mask_bbox, digitMarkers, refImageTime] = ...
    initialDigitID_20150910(video, triggerTime, BGimg_ud, rat_metadata, boxCalibration);

pawTrajectory = track3Dpaw_20150831(video, BGimg_ud, refImageTime, initDigitMasks, init_mask_bbox, digitMarkers, rat_metadata, boxCalibration);
% [digitImg_enh,centerImg_enh] = trackTattooedPaw(video,...
%                                                 rat_metadata,...
%                                                 F,...
%                                                 register_ROI, ...
%                                                 boxMarkers,...
%                                                 'graypawlimits',gray_paw_limits, ...
%                                                 'mask_roi',ROI_to_mask_paw, ...
%                                                 'bgimg',BGimg);
                                     
                                     
     