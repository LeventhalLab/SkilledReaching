function img_out = overlayDLCreconstruction(img_in, points3D, direct_pt, mirror_pt, direct_p, mirror_p, direct_bp, mirror_bp, bodyparts, isPointValid, ROIs, boxCal, pawPref, varargin)
%
% INPUTS:
%   img_in - 
%   points3D - 
%   direct_pt, mirror_pt - m x 2 matrices
%   direct_p, mirror_p - 
%   direct_bp, mirror_bp - 
%   bodyparts - 
%   isPointValid - 2-element cell array containing boolean vectors 
%       indicating whether each body part was deemed a valid point (true = 
%       valid). 1st array is for direct view, second array for mirror
%       view
%   boxCal - 
%   pawPref - 
%
% VARARGS:
%   markersize - size of individual markers
%   pcutoff - p-value to use as a cutoff for high vs low probability points
% OUTPUTS:
%

% associate colors with specific body parts
bodypartColor.dig = [1 0 0;
                     1 0 1;
                     1 1 0;
                     0 1 0];
bodypartColor.otherPaw = [0 1 1];
bodypartColor.paw_dorsum = [0 0 1];
bodypartColor.pellet = [0 0 0];
bodypartColor.nose = [0 0 0];

markerSize = 6;

for iarg = 1 : 2 : nargin - 13
    switch lower(varargin{iarg})
        case 'markersize'
            markerSize = varargin{iarg + 1};
    end
end
p_cutoff = 0.9;

DLC_validMarkerType = 'o';
DLC_invalidMarkerType = 's';
DLC_highProbMarkerType = '*';
DLC_lowProbMarkerType = '+';
DLC_reprojMarkerType = 

if isa(img_in,'uint8')
    img_out = double(img_in) / 255;
else
    img_out = img_in;
end

num_direct_bp = size(direct_pt,1);
num_mirror_bp = size(mirror_pt,1);
num_3D_bp = size(direct_pt,1);


% need to set colors for each of the point types

for i_directBP = 1 : num_direct_bp
    
    currentPt = direct_pt(i_directBP,:) + ROIs(1,1:2) - 1;
    currentPt = undistortPoints(currentPt, boxCal.cameraParams);
    
    markerColor = getMarkerColor(direct_bp{i_directBP}, bodypartColor, pawPref);

    if direct_p(i_directBP) > p_cutoff
        img_out = insertMarker(img_out, currentPt, DLC_highProbMarkerType,...
            'color',markerColor,'size',markerSize);
    else
        img_out = insertMarker(img_out, currentPt, DLC_lowProbMarkerType,...
            'color',markerColor,'size',markerSize);
    end
    
    if isPointValid{1}(i_directBP)
        img_out = insertMarker(img_out, currentPt, DLC_validMarkerType,...
            'color',markerColor,'size',markerSize);
    else
        img_out = insertMarker(img_out, currentPt, DLC_invalidMarkerType,...
            'color',markerColor,'size',markerSize);
    end
        
end

for i_mirrorBP = 1 : num_mirror_bp
    
    currentPt = mirror_pt(i_mirrorBP,:) + ROIs(2,1:2) - 1;
    currentPt = undistortPoints(currentPt, boxCal.cameraParams);
    
    markerColor = getMarkerColor(mirror_bp{i_mirrorBP}, bodypartColor, pawPref);

    if mirror_p(i_mirrorBP) > p_cutoff
        img_out = insertMarker(img_out, currentPt, DLC_highProbMarkerType,...
            'color',markerColor,'size',markerSize);
    else
        img_out = insertMarker(img_out, currentPt, DLC_lowProbMarkerType,...
            'color',markerColor,'size',markerSize);
    end

    if isPointValid{2}(i_mirrorBP)
        img_out = insertMarker(img_out, currentPt, DLC_validMarkerType,...
            'color',markerColor,'size',markerSize);
    else
        img_out = insertMarker(img_out, currentPt, DLC_invalidMarkerType,...
            'color',markerColor,'size',markerSize);
    end
end

switch pawPref
    case 'right'
        Pn = squeeze(boxCal.Pn(:,:,2));
        sf = mean(boxCal.scaleFactor(2,:));
    case 'left'
        Pn = squeeze(boxCal.Pn(:,:,3));
        sf = mean(boxCal.scaleFactor(3,:));
end
for i_bp = 1 : num_3D_bp
    currentPt = points3D(i_bp,:);
    if all(currentPt==0)
        % 3D point wasn't computed for this body part
        continue;
    end
    
    currentPt = currentPt / sf;
    % reproject this point into the direct view
    currPt_direct = projectPoints_DL(currentPt, boxCal.P);
    currPt_direct = unnormalize_points(currPt_direct,K);
    img_out = insertMarker(img_out, currPt_direct, DLC_reprojMarkerType,...
        'color',markerColor,'size',markerSize);
        
    % reproject this point into the mirror view
    currPt_mirror = projectPoints_DL(currentPt, Pn);
    currPt_mirror = unnormalize_points(currPt_mirror,K);
    img_out = insertMarker(img_out, currPt_mirror, DLC_reprojMarkerType,...
        'color',markerColor,'size',markerSize);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function markerColor = getMarkerColor(bodypart, bodypartColor, pawPref)

[partType, laterality, partNumber] = parseBodyPart(bodypart);

switch partType
    case 'mcp'
        markerColor = bodypartColor.dig(partNumber,:) * 1/3;
    case 'pip'
        markerColor = bodypartColor.dig(partNumber,:) * 2/3;
    case 'digit'
        markerColor = bodypartColor.dig(partNumber,:);
    case 'pawdorsum'
        if strcmpi(laterality, pawPref)
            markerColor = bodypartColor.paw_dorsum;
        else
            markerColor = bodypartColor.otherPaw;
        end
    case 'nose'
        markerColor = bodypartColor.nose;
    case 'pellet'
        markerColor = bodypartColor.pellet;
end
    
    
end