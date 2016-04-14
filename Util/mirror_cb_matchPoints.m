function mp = mirror_cb_matchPoints(cb_file, cameraParams, varargin)

leftMirrorEdge = 250;
rightMirrorEdge = 1600;

for iarg = 1 : 2 : nargin - 2
    switch lower(varargin{iarg})
        case 'leftmirroredge',
            leftMirrorEdge = varargin{iarg + 1};
        case 'rightmirroredge',
            rightMirrorEdge = varargin{iarg + 1};
    end
end

mp = [];

if ~exist(cb_file,'file'); return; end

cal_image = imread(cb_file, 'png');
cal_image_ud = undistortImage(cal_image, cameraParams);
h = size(cal_image_ud,1);
w = size(cal_image_ud,2);

imSegment = zeros(size(cal_image_ud),'like',cal_image_ud);
for iView = 1 : 3    % 1 is the direct view, 2 is the left mirror, 3 is the right mirror

    switch iView
        case 1,
            leftEdge = leftMirrorEdge;
            rightEdge = rightMirrorEdge;
        case 2,
            leftEdge = 1;
            rightEdge = leftMirrorEdge;
        case 3,
            leftEdge = rightMirrorEdge;
            rightEdge = w;    % image width
    end   
    
    imSegment(1:h,leftEdge:rightEdge,:,iView) = cal_image_ud(1:h,leftEdge:rightEdge,:);
%     [cb_points, boardSize] = detectCheckerboardPoints(imSegment);
    
%     mp{iView} = [cb_points(:,1) + leftEdge - 1,cb_points(:,2)];

end
    
[cb_points, boardSize, pairsUsed] = detectCheckerboardPoints(squeeze(imSegment(:,:,:,1)),...
    squeeze(imSegment(:,:,:,2)));

end