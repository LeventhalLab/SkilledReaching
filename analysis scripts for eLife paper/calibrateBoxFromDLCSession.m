function [boxCal_fromSession,mp_direct,mp_mirror] = calibrateBoxFromDLCSession(fullSessionDir,cameraParams,boxCal,pawPref,varargin)
%
% function to calibrate a reaching chamber (i.e., calculate fundamental
% matrix, essential matrix, camera matrices, etc) based on matched points
% discovered by DLC during reaching
%
% INPUTS:
%   fullSessionDir - directory containing DLC output for the session of
%       interest
%   cameraParams - camera parameters structure for the real camera
%   boxCal - box calibration structure with the following fields:
%       E - 3 x 3 x 3 array continaing essential matrices
%           E(:,:,1) = essential matrix for direct view, top mirror
%           E(:,:,2) = essential matrix for direct view, left mirror
%           E(:,:,3) = essential matrix for direct view, right mirror
%       F - 3 x 3 x 3 array continaing fundamental matrices
%           F(:,:,1) = fundamental matrix for direct view, top mirror
%           F(:,:,2) = fundamental matrix for direct view, left mirror
%           F(:,:,3) = fundamental matrix for direct view, right mirror
%       Pn - 3 x 3 x 3 array continaing camera matrices for virtual cameras
%           P for direct view assumed to be eye(4,3)
%           Pn(:,:,1) = camera matrix for top mirror
%           Pn(:,:,2) = camera matrix for left mirror
%           Pn(:,:,3) = camera matrix for right mirror
%       cameraParams - matlab camera parameters structure with intrinsic
%           parameters for the real camera
%       curDate - character array containing the date the calibration was 
%           performed (YYYYMMDD)
%       directChecks - ptsPerImage x 2 x number of boards x number of images
%           array. each ptsPerImage x 2 subarray contains (x,y) pairs for
%           matched points in a single image for a single mirror. For
%           example, directChecks(:,:,1,1) is the checkerboard coordinates
%           on the top panel in the first calibration image,
%           directChecks(:,:,2,2) is the checkerboard coordinates on the
%           left panel in the second calibration image,
%           directChecks(:,:,3,1) is the checkerboard coordinates on the
%           right panel in the first calibration image, etc...
%       mirrorChecks - same as directChecks but in the corresponding mirror
%           views
%       imFileList - names of the grid calibration files that went into the
%           calibration
%       scaleFactor - n x 3 array, where n is the number of calibration
%           images. scaleFactor(1,:) - scale factor for top view;
%           scaleFactor(2,:) - scale factor for left view; scaleFactor(3,:)
%           - scale factor for right view. Converts world coordinates to mm
%       boxCal_fromSession - structure array containing above fields, but based
%           on DLC output as well as calibration images
%   pawPref - 'left' or 'right'
%
% VARARGINs:
%   min_valid_p_for_calibration - minimum DLC "p" value accepted as a
%       potential correctly identified point for calibration purposes.
%       generally stricter than min_valid_p since we have lots of good
%       points for calibration (like usually set this to 1.0)
%   maxdistperframe - maximum distance a point can jump between frames
%       before we assume that at least one of the points was a
%       misidentification
%   min_valid_p - minimum DLC "p" value accepted as a potential correctly 
%       identified point
%   min_certain_p - minimum DLC "p" value accepted as certainly a correctly
%       identified point
%   maxneighbordist - for points on the paw, the farthest apart they can be
%       before at least one of them must be misidentified
%   framesize - image size (height, width). default 1024 x 2040
%       ([1024,2040])
%   usepriortrajfile - boolean. if trajectory has already been calculated
%       (meaning all valid/invalid points already identified and points
%       have been translated and undistorted), just use that file instead
%       of raw DLC data
%
% OUTPUTS:
%   boxCal_fromSession - structure containing same fields as boxCal, but
%       based on matched DLC points from this session
%   mp_direct - n x 2 array where n is the number of total identified
%       points in the direct view with clear matches in the mirror view
%   mp_mirror - n x 2 array where each row matches the points in mp_direct

usePriorTrajFile = true;   % whether or not to use previously calculated trajectory info and manually invalidated points
min_valid_p_for_calibration = 1;

if isfield(boxCal,'boxCal_fromSession')
    boxCal = rmfield(boxCal,'boxCal_fromSession');
end
boxCal_fromSession = boxCal;

[~,sessionName,~] = fileparts(fullSessionDir);

% for R0189, 10171002, a reflection in the mirror view is often mistaken
% for the pellet. So don't use the pellet for calibration in that session.
if strcmpi(sessionName,'r0189_20171002a')
    skipPelletForCalibration = true;
else
    skipPelletForCalibration = false;
end

% parameters for find_invalid_DLC_points
maxDistPerFrame = 30;
min_valid_p = 0.85;
min_certain_p = 0.97;
maxDistFromNeighbor_invalid = 70;

frameSize = [1024,2040];   % hard-coded for now

for iarg = 1 : 2 : nargin - 4
    switch lower(varargin{iarg})
        case 'min_valid_p_for_calibration'
            min_valid_p_for_calibration = varargin{iarg + 1};
        case 'maxdistperframe'
            maxDistPerFrame = varargin{iarg + 1};
        case 'min_valid_p'
            min_valid_p = varargin{iarg + 1};   % p values below this are considered to indicate poorly determined points (and exclude from subsequent analysis)
        case 'min_certain_p'
            min_certain_p = varargin{iarg + 1};   % p values above this are considered to be well-determined points (and include in subsequent analysis)
        case 'maxneighbordist'
            maxDistFromNeighbor_invalid = varargin{iarg + 1};
        case 'framesize'
            frameSize = varargin{iarg + 1};
        case 'usepriortrajfile'
            usePriorTrajFile = varargin{iarg + 1};
    end
end

switch pawPref
    case 'right'
        cam_matrix_idx = 2;
    case 'left'
        cam_matrix_idx = 3;
end
K = cameraParams.IntrinsicMatrix;

[directViewDir,mirrorViewDir,direct_csvList,mirror_csvList] = getDLC_csvList(fullSessionDir);
[~,curSession,~] = fileparts(fullSessionDir);

boxCal_fromSession.sessionName = curSession;

ratID = curSession(1:5);
ratIDnum = str2double(ratID(2:end));

C = textscan(curSession,[ratID '_%8c']);
sessionDate = C{1};

numMarkedVids = length(direct_csvList);
% ratID, date, etc. for each individual video
directVidTime = cell(1, numMarkedVids);
directVidNum = zeros(numMarkedVids,1);

% find all the direct view videos that are available
cd(directViewDir);
uniqueDateList = {};
for ii = 1 : numMarkedVids   

    [directVid_ratID(ii),directVidDate{ii},directVidTime{ii},directVidNum(ii)] = ...
        extractDLC_CSV_identifiers(direct_csvList(ii).name);

    if isempty(uniqueDateList)
        uniqueDateList{1} = directVidDate{ii};
    elseif ~any(strcmp(uniqueDateList,directVidDate{ii}))
        uniqueDateList{end+1} = directVidDate{ii};
    end
end
       
cd(mirrorViewDir)
mp_direct = zeros(0,2);
mp_mirror = zeros(0,2);
for i_mirrorcsv = 1 : length(mirror_csvList)
    
    [mirror_ratID,mirror_vidDate,mirror_vidTime,mirror_vidNum] = extractDLC_CSV_identifiers(mirror_csvList(i_mirrorcsv).name);

    % is there a corresponding paw trajectory file for this video? If so,
    % may want to find manually invalidated points, and can skip the direct
    % and mirror points undistortion because they're already in the file
    trajName = sprintf('R%04d_%s_%s_%03d_3dtrajectory_new.mat', mirror_ratID,...
                mirror_vidDate,mirror_vidTime,mirror_vidNum);
	fullTrajName = fullfile(fullSessionDir,trajName);
    if exist(fullTrajName,'file') && usePriorTrajFile
        load(fullTrajName);
        
        direct_pts_ud = final_direct_pts;
        mirror_pts_ud = final_mirror_pts;
        num_direct_bp = length(direct_bp);
        
        if ~exist('manually_invalidated_points','var')
            numFrames = size(direct_p,2);
            manually_invalidated_points = false(numFrames,num_direct_bp,2);
        end

        [invalid_mirror, ~] = find_invalid_DLC_points(mirror_pts, mirror_p,mirror_bp,pawPref,...
            'maxdistperframe',maxDistPerFrame,'min_valid_p',min_valid_p,'min_certain_p',min_certain_p,'maxneighbordist',maxDistFromNeighbor_invalid);
        [invalid_direct, ~] = find_invalid_DLC_points(direct_pts, direct_p,direct_bp,pawPref,...
            'maxdistperframe',maxDistPerFrame,'min_valid_p',min_valid_p,'min_certain_p',min_certain_p,'maxneighbordist',maxDistFromNeighbor_invalid);
        invalid_mirror = invalid_mirror | squeeze(manually_invalidated_points(:,:,2))';
        invalid_direct = invalid_direct | squeeze(manually_invalidated_points(:,:,1))';
    else
        % if points haven't been previously undistorted, do so now
        
        foundMatch = false;
        for i_directcsv = 1 : numMarkedVids
            if mirror_ratID == ratIDnum && ...      % match ratID
               strcmp(mirror_vidDate, sessionDate) && ...  % match date
               strcmp(mirror_vidTime, directVidTime{i_directcsv}) && ...  % match time
               mirror_vidNum == directVidNum(i_directcsv)                % match vid number
                foundMatch = true;
                break;
            end
        end
        if ~foundMatch
            continue;
        end
        cd(mirrorViewDir)
        [mirror_bp,mirror_pts,mirror_p] = read_DLC_csv(mirror_csvList(i_mirrorcsv).name);
        mirror_metadataName = get_metadataName(mirror_csvList(i_mirrorcsv).name,pawPref);
        mirror_metadataName = fullfile(mirrorViewDir, mirror_metadataName);
        mirror_metadata = load(mirror_metadataName);
        cd(directViewDir)
        [direct_bp,direct_pts,direct_p] = read_DLC_csv(direct_csvList(i_directcsv).name);
        direct_metadataName = get_metadataName(direct_csvList(i_directcsv).name,pawPref);
        direct_metadataName = fullfile(directViewDir, direct_metadataName);
        direct_metadata = load(direct_metadataName);
        
        % ROIs loaded from cropping metadata files
        ROIs = [direct_metadata.viewROI;mirror_metadata.viewROI];
        frameSize = direct_metadata.frameSize;
            
        [invalid_mirror, ~] = find_invalid_DLC_points(mirror_pts, mirror_p,mirror_bp,pawPref,...
            'maxdistperframe',maxDistPerFrame,'min_valid_p',min_valid_p,'min_certain_p',min_certain_p,'maxneighbordist',maxDistFromNeighbor_invalid);
        [invalid_direct, ~] = find_invalid_DLC_points(direct_pts, direct_p,direct_bp,pawPref,...
            'maxdistperframe',maxDistPerFrame,'min_valid_p',min_valid_p,'min_certain_p',min_certain_p,'maxneighbordist',maxDistFromNeighbor_invalid);
    
        direct_pts_ud = reconstructUndistortedPoints(direct_pts,ROIs(1,:),cameraParams,~invalid_direct);
        mirror_pts_ud = reconstructUndistortedPoints(mirror_pts,ROIs(2,:),cameraParams,~invalid_mirror);
        numFrames = size(direct_p,2);
        num_bodyparts = length(direct_bp);
        manually_invalidated_points = false(numFrames,num_bodyparts,2);
    end

    % match body parts between direct and mirror views
    mirror_bpMatch_idx = [];
    direct_bpMatch_idx = [];
    num_direct_bp = length(direct_bp);
    numValid_bp = 0;
    bodyparts = {};
    for i_bp = 1 : num_direct_bp
    % hard coding for now that bodypart labels are in the same order in
    % the direct and mirror views, should fix this later to make the
    % algorithm more robust to human error

        numValid_bp = numValid_bp + 1;

        mirror_bpMatch_idx(numValid_bp) = i_bp;
        direct_bpMatch_idx(numValid_bp) = i_bp;
        bodyparts{numValid_bp} = direct_bp{i_bp};
    end
    
    valid_direct = (direct_p >= min_valid_p_for_calibration) & ~isnan(direct_pts_ud(:,:,1)) & ~invalid_direct;
    valid_mirror = (mirror_p >= min_valid_p_for_calibration) & ~isnan(mirror_pts_ud(:,:,1)) & ~invalid_mirror;

    try
    validPoints = (valid_direct & valid_mirror);
    catch
        keyboard
    end
    for i_bp = 1 : num_direct_bp
        
        if strcmpi(direct_bp{i_bp},'pellet') && skipPelletForCalibration
            % for R0189, 10171002, a reflection in the mirror view is often mistaken
            % for the pellet. So don't use the pellet for calibration in that session.
            continue
        end
        if ~any(validPoints(i_bp,:));continue;end
        
        new_direct = squeeze(direct_pts_ud(i_bp,validPoints(i_bp,:),:));
        new_mirror = squeeze(mirror_pts_ud(mirror_bpMatch_idx(i_bp),validPoints(mirror_bpMatch_idx(i_bp),:),:));
        
        if iscolumn(new_direct);new_direct = new_direct';end
        if iscolumn(new_mirror);new_mirror = new_mirror';end
        
        mp_direct = [mp_direct;new_direct];
        mp_mirror = [mp_mirror;new_mirror];
        
    end
    
end

[F,~] = refineFundMatrixMirror(mp_direct,mp_mirror,frameSize);

E = K * F * K';
[rot,t] = EssentialMatrixToCameraMatrix(E);
[cRot,cT,~] = SelectCorrectEssentialCameraMatrix_mirror(...
    rot,t,mp_mirror',mp_direct',K');
Ptemp = [cRot,cT];
Pn = Ptemp';

boxCal_fromSession.F(:,:,cam_matrix_idx) = F;
boxCal_fromSession.E(:,:,cam_matrix_idx) = E;
boxCal_fromSession.Pn(:,:,cam_matrix_idx) = Pn;

end
        
        
    
    