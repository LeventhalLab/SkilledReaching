function [x,y] = TomasiShiCornerDetector(img)
%----------------------------------------------------------
%      Author: Diego Cheda
% Affiliation: CVC - UAB
%        Date: 03/06/2008
%----------------------------------------------------------
    % detect points using Tomasi/Shi or Harris
    method = 'MinimumEigenvalue'; % Shi/Thomasi %'Harris'

    cornerness = cornermetric(img, method, 'FilterCoefficients', fspecial('gaussian',[1 9],9));

    corner_peaks = imregionalmax(cornerness);

    corner_idx = find(corner_peaks == true);
    
    [x,y] = ind2sub(size(img),corner_idx);
    
    