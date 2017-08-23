function findLikelyPawPointsAlongLine(img, mask, searchLine)

borderpts = lineToBorderPoints(searchLine, size(mask));

testValue = ones(size(mask));
[y,x] = find(imdilate(mask,strel('disk',50)));
for i_x = 1 : length(x)
        testValue(y(i_x),x(i_x)) = distanceToLine(borderpts([1,2]),borderpts([3,4]),[x(i_x),y(i_x)]);
        %searchLine(1) * x + searchLine(2) * y + searchLine(3);
end
validLineMask = abs(testValue) < 1;

test_img = repmat(double(validLineMask),[1,1,3]) .* img;

% first, look to see if there are any green pixels along the line
test_img_hsv = rgb2hsv(test_img);
greenVals = [0.33,0.16];
satRange = [0.8,1];
valRange = [0.5,1];



% target_rg_mean = 0.5;

% color_costFunction = zeros(size(img));
% for i_colPlane = 1 : 3
%     color_costFunction(:,:,i_colPlane) = abs(img(:,:,i_colPlane) - targetColor(i_colPlane));
% end
% color_costFunction = sqrt(color_costFunction(:,:,1).^2 + color_costFunction(:,:,2).^2 + color_costFunction(:,:,3).^2);

mean_rg = mean(img(:,:,1:2),3);
mean_rg_paw = double(mask) .* mean_rg;
paw_vals = mean_rg_paw(:);
paw_vals = paw_vals(paw_vals > 0);
mean_paw_rg = mean(paw_vals);

rgdist = abs(mean_rg - mean_paw_rg);

dist_from_pawMask = bwdist(mask);





overall_cost = double(validLineMask) .* (rgdist * 20 + dist_from_pawMask);

% look for green points first


% if that doesn't work, look for red points
end
