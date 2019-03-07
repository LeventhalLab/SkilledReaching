function [directImg,mirrorImg] = overlayDLC_onFrame(img_in, points3D, final_direct_pt, final_mirror_pt, direct_p, mirror_p, direct_bp, mirror_bp, bodyparts, isEstimate, boxCal, pawPref, isPointValid,ROIs,frameNumber,connectDigits,varargin)
%
% INPUTS:
%   img_in - undistorted RGB image
%   points3D - 
%   direct_pt, mirror_pt - m x 2 matrices
%   direct_p, mirror_p - 
%   direct_bp, mirror_bp - 
%   bodyparts - 
%   isPointValid - 2-element cell array containing boolean vectors 
%       indicating whether each body part was deemed a valid point (true = 
%       valid). 1st array is for direct view, second array for mirror
%       view
%   boxCal - box calibration structure with the following fields:
%       .E - essential matrix (3 x 3 x numViews) array where numViews is
%           the number of different mirror views (3 for now)
%       .F - fundamental matrix (3 x 3 x numViews) array where numViews is
%           the number of different mirror views (3 for now)
%       .Pn - camera matrices assuming the direct view is eye(4,3). 4 x 3 x
%           numViews array
%       .P - direct camera matrix (eye(4,3))
%       .cameraParams
%       .curDate - YYYYMMDD format date the data were collected
%   pawPref - 
%
% VARARGS:
%   markersize - size of individual markers
%   pcutoff - p-value to use as a cutoff for high vs low probability points
%   parts_to_show - indices of bodyparts cell array to show
%
% OUTPUTS:
%   img_out - undistorted RGB image with overlay marks added on defined by
%       the DLC_...MarkerType variables

% associate colors with specific body parts

% solid marks for DLC-identified points
% open marks for estimated points

makeKey = true;

circleRadius = 5;

bodypartColor.dig = [0 1 1;
                     1 0 0;
                     1 1 0;
                     0 1 0];
bodypartColor.otherPaw = [0 1 1];
bodypartColor.paw_dorsum = [0 0 1];
bodypartColor.pellet = [0 0 0];
bodypartColor.nose = [0.8 0.8 0.8];

colorTextLabels{1} = 'digit 1 - red';
colorTextLabels{2} = 'digit 2 - magenta';
colorTextLabels{3} = 'digit 3 - yellow';
colorTextLabels{4} = 'digit 4 - green';
colorTextLabels{5} = 'proximal dark-->distal light';

topLeftTextPosition = [20,20];
topLeftTextPosition2 = [1800,20];
textFontSize = 20;
textRowSpacing = textFontSize + 8;
textColor = 'black';

markerSize = 6;
p_cutoff = 0.9;

parts_to_show = 1 : length(bodyparts);

DLC_isEstimateType = 'o';
DLC_isEstimateFaceColor = 'none';

DLC_invalidMarkerType = '*';
DLC_highProbMarkerType = 'square';
DLC_lowProbMarkerType = '+';
DLC_reprojMarkerType = 'x';


for iarg = 1 : 2 : nargin - 16
    switch lower(varargin{iarg})
        case 'markersize'
            markerSize = varargin{iarg + 1};
        case 'makekey'
            makeKey = varargin{iarg + 1};
        case 'p_cutoff'
            p_cutoff = varargin{iarg + 1};
        case 'bodypartcolor'
            bodypartColor = varargin{iarg + 1};
        case 'parts_to_show'
            parts_to_show = varargin{iarg + 1};
    end
end

if isa(img_in,'uint8')
    img_out = double(img_in) / 255;
else
    img_out = img_in;
end

directImg = img_out(ROIs(1,2):ROIs(1,2) + ROIs(1,4),...
                    ROIs(1,1):ROIs(1,1) + ROIs(1,3),:);
mirrorImg = img_out(ROIs(2,2):ROIs(2,2) + ROIs(2,4),...
                    ROIs(2,1):ROIs(2,1) + ROIs(2,3),:);

K = boxCal.cameraParams.IntrinsicMatrix;
% need to set colors for each of the point types

for i_bp = 1 : length(parts_to_show)
    
    i_directBP = find(strcmpi(direct_bp, bodyparts{parts_to_show(i_bp)}));
    currentPt = final_direct_pt(i_directBP,:);
    currentPt = currentPt - ROIs(1,1:2) + 1;
    
    try
    markerColor = getMarkerColor(direct_bp{i_directBP}, bodypartColor, pawPref);
    catch
        keyboard
    end

    if isPointValid{1}(i_directBP)
%         if direct_p(i_directBP) > p_cutoff
            
            directImg = insertShape(directImg, 'filledcircle', [currentPt,circleRadius],...
                'color',markerColor);
%         else
%             img_out = insertMarker(img_out, currentPt, DLC_lowProbMarkerType,...
%                 'color',markerColor,'size',markerSize);
%         end
    end
    
%     if isPointValid{1}(i_directBP)
%         img_out = insertMarker(img_out, currentPt, DLC_isEstimateType,...
%             'color',markerColor,'size',markerSize);
%     else
%         img_out = insertMarker(img_out, currentPt, DLC_invalidMarkerType,...
%             'color',markerColor,'size',markerSize);
%     end
    
    if isEstimate(i_directBP,1)
        directImg = insertShape(directImg,'circle', [currentPt,circleRadius],...
            'color',markerColor);
    end
        
end

for i_bp = 1 : length(parts_to_show)
    
    i_mirrorBP = find(strcmpi(direct_bp, bodyparts{parts_to_show(i_bp)}));

    currentPt = final_mirror_pt(i_mirrorBP,:);
    currentPt = currentPt - ROIs(2,1:2) + 1;
    
    markerColor = getMarkerColor(mirror_bp{i_mirrorBP}, bodypartColor, pawPref);

    if isPointValid{2}(i_mirrorBP)
%         if mirror_p(i_mirrorBP) > p_cutoff
            try
            mirrorImg = insertShape(mirrorImg, 'filledcircle',[currentPt,circleRadius],...
                'color',markerColor);
            catch
                keyboard
            end
%         else
%             img_out = insertMarker(img_out, currentPt, DLC_lowProbMarkerType,...
%                 'color',markerColor,'size',markerSize);
%         end
    end
    
    if isEstimate(i_mirrorBP,2)
        mirrorImg = insertShape(mirrorImg, 'circle',[currentPt,circleRadius],...
            'color',markerColor);
%     else
%         img_out = insertMarker(img_out, currentPt, DLC_invalidMarkerType,...
%             'color',markerColor,'size',markerSize);
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
for i_bp = 1 : length(parts_to_show)
    currentPt = points3D(parts_to_show(i_bp),:);
    if all(currentPt==0)
        % 3D point wasn't computed for this body part
        continue;
    end
    
    
    if (isPointValid{1}(i_bp) && isPointValid{2}(i_bp)) || any(isEstimate(i_bp,:))
        currentPt = currentPt / sf;
        % reproject this point into the direct view
        currPt_direct = projectPoints_DL(currentPt, boxCal.P);
        currPt_direct = unnormalize_points(currPt_direct,K);
        
%         markerColor = getMarkerColor(direct_bp{i_bp}, bodypartColor, pawPref);
%         img_out = insertMarker(img_out, currPt_direct, DLC_reprojMarkerType,...
%             'color',markerColor,'size',markerSize);
        
        markerColor = getMarkerColor(mirror_bp{i_bp}, bodypartColor, pawPref);
        currPt_mirror = projectPoints_DL(currentPt, Pn);
        currPt_mirror = unnormalize_points(currPt_mirror,K);
        
        currPt_direct = currPt_direct - ROIs(1,1:2) + 1;
        currPt_mirror = currPt_mirror - ROIs(2,1:2) + 1;
        directImg = insertMarker(directImg, currPt_direct, DLC_reprojMarkerType,...
            'color',markerColor,'size',markerSize);
        mirrorImg = insertMarker(mirrorImg, currPt_mirror, DLC_reprojMarkerType,...
            'color',markerColor,'size',markerSize);
        
%         Img = insertMarker(img_out, currPt_mirror, DLC_reprojMarkerType,...
%             'color',markerColor,'size',markerSize);
    end
end

textStr = sprintf('frame # %03d',frameNumber);
mirrorImg = insertText(mirrorImg,[20,10],textStr,'fontsize',24,'textcolor','w',...
    'boxopacity',0);

if connectDigits
    % connect the first and fourth digits in the direct view
end
    
% insert text that gives a key for symbols and colors
% if makeKey
%     textStr = cell(5,1);
%     textStr{1} = sprintf('is marker estimate: %s', DLC_isEstimateType);
%     textStr{2} = sprintf('invalid marker: %s', DLC_invalidMarkerType);
%     textStr{3} = sprintf('marker for p > %0.2f: %s', p_cutoff, DLC_highProbMarkerType);
%     textStr{4} = sprintf('marker for p < %0.2f: %s', p_cutoff, DLC_lowProbMarkerType);
%     textStr{5} = sprintf('reconstructed from 3D position: %s', DLC_reprojMarkerType);
%     for ii = 6 : 10
%         textStr{ii} = colorTextLabels{ii-5};
%     end
%     
%     
%     textPosition = zeros(length(textStr), 2);
%     
% 
%     for iRow = 1 : size(textPosition,1)
%         textPosition(iRow,1) = topLeftTextPosition(1);
%         textPosition(iRow,2) = topLeftTextPosition(2) + (iRow-1)*textRowSpacing;
%     end
%     img_out = insertText(img_out,textPosition,textStr,'fontsize',textFontSize,'textcolor',textColor);
%     
%     textStr = cell(length(bodyparts),1);
%     textColor2 = zeros(length(bodyparts),3);
%     textPosition2 = zeros(length(textStr), 2);
%     for ii = 1 : length(textStr)
%         textStr{ii} = sprintf('%d - %s',ii,bodyparts{ii});
%         textPosition2(ii,1) = topLeftTextPosition2(1);
%         textPosition2(ii,2) = topLeftTextPosition2(2) + (ii-1)*textRowSpacing;
%         textColor2(ii,:) = getMarkerColor(bodyparts{ii}, bodypartColor, pawPref);
%     end
%     img_out = insertText(img_out,textPosition2,textStr,'fontsize',textFontSize,'textcolor',textColor2);
% end
% 
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
