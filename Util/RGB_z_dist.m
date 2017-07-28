function z_dist_from_mean = RGB_z_dist(img, mask, meanRGB, stdRGB)

z_dist_from_mean = zeros(size(mask));
for i_x = 1 : size(img,2)
    for i_y = 1 : size(img,1)
        
        if mask(i_y,i_x)
            test_pt = squeeze(img(i_y,i_x,:));
            z_dist_from_mean(i_y,i_x) = norm((test_pt - meanRGB) ./ stdRGB);
        else
            z_dist_from_mean(i_y,i_x) = 0;
        end
    end
end