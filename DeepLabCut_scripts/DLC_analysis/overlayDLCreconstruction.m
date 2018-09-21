function img_out = overlayDLCreconstruction(img_in, points3D, direct_pt, mirror_pt, direct_p, mirror_p, direct_bp, mirror_bp, bodyparts, isPointValid, ROIs, boxCal, pawPref)
%
% INPUTS:
%   img_in - 
%   points3D - 
%   direct_pt, mirror_pt - m x 2 matrices
%   direct_p, mirror_p - 
%   
%
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

p_cutoff = 0.9;

DLC_validMarkerType = 'o';
DLC_invalidMarkerType = 's';
DLC_highProbMarkerType = '*';
DLC_lowProbMarkerType = '+';

img_out = img_in;

num_direct_bp = size(direct_pt,1);
num_mirror_bp = size(mirror_pt,1);
num_3D_bp = size(direct_pt,1);


% need to set colors for each of the point types

for i_directBP = 1 : num_direct_bp
    
    currentPt = direct_pt(i_directBP,:) + ROIs(1,1:2) - 1;
    currentPt = undistortPoints(currentPt, boxCal.cameraParams);
    
    markerColor = getMarkerColor(bodypart, bodypartColor, pawPref);

    if direct_p(i_directBP) > p_cutoff
        img_out = insertMarker(img_out, currentPt, DLC_highProbMarkerType,...
            'color',markerColor);
    else
        img_out = insertMarker(img_out, currentPt, DLC_lowProbMarkerType,...
            'color',markerColor);
    end
        
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