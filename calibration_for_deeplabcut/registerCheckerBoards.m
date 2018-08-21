function registerCheckerBoards(img, directBorderMask, mirrorBorderMask, mirrorOrientation)
%
% INPUTS
%
% OUTPUTS

if iscell(img)
    num_img = length(img);
else
    num_img = 1;
    img{1} = img;
end

% imgMask = cell(1, num_img);


% im_eq = adapthisteq(rgb2gray(img));
% im_hsv = rgb2hsv(img);
% hsv_eq = im_hsv;
% hsv_eq(:,:,3) = im_eq;
% rgb_eq = hsv2rgb(hsv_eq);
% 
% img_stretch = decorrstretch(rgb_eq);

numMirrors = size(directBorderMask{1}, 3);

img_h = zeros(1, num_img);
img_w = zeros(1, num_img);
rgb_eq = cell(1, num_img);
for iImg = 1 : num_img
    img_h(iImg) = size(img{iImg}, 1);
    img_w(iImg) = size(img{iImg}, 2);
        
    if isa(img{iImg},'uint8')
        img{iImg} = double(img{iImg}) / 255;
    end

    im_eq = adapthisteq(rgb2gray(img{iImg}));
    im_hsv = rgb2hsv(img{iImg});
    hsv_eq = im_hsv;
    hsv_eq(:,:,3) = im_eq;
    rgb_eq{iImg} = hsv2rgb(hsv_eq);
end

for iMirror = 1 : numMirrors
    
    directBox = zeros(num_img,4);
    mirrorBox = zeros(num_img,4);
    
    % extract regions around each bounding box. Make sure they are all the
    % same size to make the checkerboard detection algorithm happy
    for iImg = 1 : num_img
        
        directStats = regionprops(directBorderMask{iImg}(:,:,iMirror),'boundingbox');
        mirrorStats = regionprops(mirrorBorderMask{iImg}(:,:,iMirror),'boundingbox');

        directBox(iImg,:) = round(directStats.BoundingBox);
        mirrorBox(iImg,:) = round(mirrorStats.BoundingBox);
        
%         new_w = max(directBox(iImg,3),mirrorBox(iImg,3));
%         max_w = max(max_w, new_w);
%         
%         new_h = max(directBox{iImg}(4),mirrorBox{iImg}(4));
%         max_h = max(max_h, new_h);
    end
    max_w = max([directBox(:,3);mirrorBox(:,3)]);
    max_h = max([directBox(:,4);mirrorBox(:,4)]);
    
    newDirectBox = zeros(num_img,4);
    newMirrorBox = zeros(num_img,4);
	for iImg = 1 : num_img
        
        extra_w = max_w - directBox(iImg,3);
        newDirectBox(iImg,1) = max(directBox(iImg,1) - round(extra_w/2), 1);
        newDirectBox(iImg,3) = max_w;
        if newDirectBox(iImg,1) + newDirectBox(iImg,3) > img_w
            newDirectBox(iImg,1) = img_w(iImg) - max_w;
        end
        
        extra_w = max_w - mirrorBox(iImg,3);
        newMirrorBox(iImg,1) = max(mirrorBox(iImg,1) - round(extra_w/2), 1);
        newMirrorBox(iImg,3) = max_w;
        if newMirrorBox(iImg,1) + newMirrorBox(iImg,3) > img_w
            newMirrorBox(iImg,1) = img_w(iImg) - max_w;
        end
        
        extra_h = max_h - directBox(iImg,4);
        newDirectBox(iImg,2) = max(directBox(iImg,2) - round(extra_h/2), 1);
        newDirectBox(iImg,4) = max_h;
        if newDirectBox(iImg,2) + newDirectBox(iImg,4) > img_h
            newDirectBox(iImg,2) = img_h(iImg) - max_h;
        end
        
        extra_h = max_h - mirrorBox(iImg,4);
        newMirrorBox(iImg,2) = max(mirrorBox(iImg,2) - round(extra_h/2), 1);
        newMirrorBox(iImg,4) = max_h;
        if newMirrorBox(iImg,2) + newMirrorBox(iImg,4) > img_h
            newMirrorBox(iImg,2) = img_h(iImg) - max_h;
        end
        
    end
    
    directCheck = zeros(max_h+1, max_w+1, size(img{1},3), num_img);
    mirrorCheck = zeros(max_h+1, max_w+1, size(img{1},3), num_img);

    for iImg = 1 : num_img
    
        directCheck(:,:,:,iImg) = img{iImg}(newDirectBox(iImg,2):newDirectBox(iImg,2)+newDirectBox(iImg,4),...
                                               newDirectBox(iImg,1):newDirectBox(iImg,1)+newDirectBox(iImg,3),:);
        mirrorCheck(:,:,:,iImg) = img{iImg}(newMirrorBox(iImg,2):newMirrorBox(iImg,2)+newMirrorBox(iImg,4),...
                                               newMirrorBox(iImg,1):newMirrorBox(iImg,1)+newMirrorBox(iImg,3),:);

        directMask = directBorderMask{iImg}(newDirectBox(iImg,2):newDirectBox(iImg,2)+newDirectBox(iImg,4),...
                             newDirectBox(iImg,1):newDirectBox(iImg,1)+newDirectBox(iImg,3),iMirror);
        mirrorMask = mirrorBorderMask{iImg}(newMirrorBox(iImg,2):newMirrorBox(iImg,2)+newMirrorBox(iImg,4),...
                             newMirrorBox(iImg,1):newMirrorBox(iImg,1)+newMirrorBox(iImg,3),iMirror);
                         
        directMask = imfill(directMask,'holes');
        mirrorMask = imfill(mirrorMask,'holes');
                         
        directCheck(:,:,:,iImg) = squeeze(directCheck(:,:,:,iImg)) .* repmat(double(directMask),1,1,3);
        mirrorCheck(:,:,:,iImg) = squeeze(mirrorCheck(:,:,:,iImg)) .* repmat(double(mirrorMask),1,1,3);
        

        switch mirrorOrientation{iMirror}
            case 'top'
                mirrorCheck(:,:,:,iImg) = flipud(squeeze(mirrorCheck(:,:,:,iImg)));
            case {'left','right'}
                mirrorCheck(:,:,:,iImg) = fliplr(squeeze(mirrorCheck(:,:,:,iImg)));
        end
        
        directPoints = detectBRISKFeatures(rgb2gray(squeeze(directCheck(:,:,:,iImg))));
        mirrorPoints = detectBRISKFeatures(rgb2gray(squeeze(mirrorCheck(:,:,:,iImg))));
        
        directFeatures = extractFeatures(rgb2gray(squeeze(directCheck(:,:,:,iImg))),directPoints);
        mirrorFeatures = extractFeatures(rgb2gray(squeeze(mirrorCheck(:,:,:,iImg))),mirrorPoints);
        
        indexPairs = matchFeatures(directFeatures,mirrorFeatures)
    
    end
                     
    [imagePoints,boardSize,pairsUsed] = detectCheckerboardPoints(directCheck)
    
end